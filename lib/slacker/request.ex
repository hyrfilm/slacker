defmodule Request do
  require Logger

  @name             "slacker"
  @version          "0.01"

  @cmd_quit         "QUIT"
  @cmd_nick         "NICK"
  @cmd_privmsg      "PRIVMSG"
  @cmd_join         "JOIN"

  @msg_welcome      "001"
  @msg_motd         "376"
  @no_such_target   "401"
  @msg_nick_taken   "433"

  def handle_event(type, data) do
    case type do
    :priv_msg
      -> on_priv_msg(data)
    _
      -> noop([type, data])
    end
  end

  def handle_command(data) do
    [command, args] = Line.parse(data)

    case command do
    @cmd_quit
      -> quit()

    @cmd_nick
      -> nick(args)

    @cmd_privmsg
      -> priv_msg(args)

    @cmd_join
      -> join(args)

    _
      -> noop(args)
    end
  end

  defp reply(msg_id, msg_str) do
    Line.format(":#{@name} #{msg_id} :#{msg_str}")
  end

  defp say(src_nick, command, dst, text) do
    Line.format(":#{src_nick} #{command} #{dst} :#{text}")
  end

  defp quit() do
    {:stop}
  end

  defp nick(args) do
    [nick, _] = Str.pop_left(args)
    case NickService.register(nick) do
      {:ok, _} ->
        welcome_reply(nick)
      {:error, _} ->
        nick_taken_reply(nick)
    end
  end

  defp welcome_reply(nick) do
    {:ok,
      [reply(@msg_welcome, "Welcome to #{@name} v#{@version} #{nick}"),
      reply(@msg_motd, "End of MOTD command.")]}
  end

  defp nick_taken_reply(nick) do
    {:ok, [reply(@msg_nick_taken, "Nickname #{nick} is already in use")]}
  end

  defp priv_msg(args) do
    # unpack destination & text
    [name, text] = Str.pop_left(args)
    # find the destination pid
    result = case find_destination(name) do
      {:ok, pid} ->
        # send the text to that pid & add the source pid
        GenServer.cast(pid, {:priv_msg, {self(), name, text}})
        {:ok, []}

      {:error, _} ->
        {:ok, [say(@name, @no_such_target, name, "No such nick/channel")]}
    end
    result
  end

  defp on_priv_msg({src_pid, dst, text}) do
    # find the source nick
    src_nick = NickService.lookup(src_pid)
    {:ok, [say(src_nick, @cmd_privmsg, dst, text)]}
  end

  defp join(args) do
    # unpack channel name
    [channel, _] = Str.pop_left(args)
    # join it
    response = case ChanService.join(channel) do
      {:ok, :joined, _chan_pid}
        -> {:ok, ["TODO TOPIC TODO :TODO"]}
      {:ok, :already_joined, _chan_pid}
        -> {[]}
    end
    response
  end

  defp noop(args) do
    Logger.info("Ignoring: #{args}")
    {:ok, []}
  end

  defp find_destination(name) do
    cond do
      ChanService.member?(name)
        -> {:ok, ChanService.lookup(name)}
      NickService.exists?(name)
        -> {:ok, NickService.lookup(name)}
      true
        -> {:error, :not_found}
    end
  end
end

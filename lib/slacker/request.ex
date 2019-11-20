defmodule Request do
  require Logger

  @name         "slacker"
  @version      "0.01"

  @cmd_quit     "QUIT"
  @cmd_nick     "NICK"
  @cmd_privmsg  "PRIVMSG"
  @cmd_join     "JOIN"

  @msg_welcome  {"001", ":Welcome to #{@name} v#{@version}"}
  @msg_motd     {"376", ":End of MOTD command."}

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

  defp reply([msg, nick]) do
    {msg_id, msg_str} = msg
    reply = ":#{@name} #{msg_id} #{msg_str} #{nick}"
    Line.format(reply)
  end

  defp quit() do
    {:stop}
  end

  defp nick(args) do
    [nick, ""] = Str.pop_left(args)
    NickService.register(nick)
    {:ok, [reply([@msg_welcome, nick]), reply([@msg_motd, nick])]}
  end

  defp priv_msg(args) do
    # unpack destination & text
    [name, text] = Str.pop_left(args)
    # find the destination pid
    dst_pid = find_destination(name)
    # send the text to that pid & add the source pid
    GenServer.cast(dst_pid, {:priv_msg, {self(), name, text}})
    {:ok, []}
  end

  defp on_priv_msg({src_pid, dst, text}) do
    # find the source nick
    src_nick = NickService.lookup(src_pid)
    {:ok, Line.format([Line.format(":#{src_nick} PRIVMSG #{dst} :#{text}")])}
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
      ChanService.member?(name, NickService.lookup(name))
        -> ChanService.lookup(name)
      NickService.exists?(name)
        -> NickService.lookup(name)
    end
  end
end

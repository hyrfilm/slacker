defmodule Request do
  require Logger

  @name         "slacker"
  @version      "0.01"

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

  defp nick(args) do
    [nick, ""] = Str.pop_left(args)
    UserService.login(self(), nick)
    {:ok, [reply([@msg_welcome, nick]), reply([@msg_motd, nick])]}
  end

  defp priv_msg(args) do
    # unpack destination & text
    [dst_nick, text] = Str.pop_left(args)
    # find the destination pid
    {:ok, dst_pid} = UserService.find_pid(dst_nick)
    # send the text to that pid & add the source pid
    GenServer.cast(dst_pid, {:priv_msg, {self(), dst_nick, text}})
    {:ok, []}
  end

  defp join(args) do
    # unpack channel name
    [channel, _] = Str.pop_left(args)
    # try to join it
    ChanService.join(channel)
  end

  defp noop(args) do
    Logger.info("Ignoring: #{args}")
    {:ok, []}
  end

  defp on_priv_msg({src_pid, dst, text}) do
    # find the source nick
    {:ok, src_nick} = UserService.find_nick(src_pid)
    {:ok, [Line.format(":#{src_nick} PRIVMSG #{dst} :#{text}")]}
  end
end

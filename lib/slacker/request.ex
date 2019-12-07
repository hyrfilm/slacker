defmodule Request do
  require Logger

  @name             "slacker"
  @version          "0.01"

  @cmd_quit         "QUIT"
  @cmd_nick         "NICK"
  @cmd_privmsg      "PRIVMSG"
  @cmd_join         "JOIN"
  @cmd_part         "PART"

  @msg_welcome      "001"
  @msg_motd         "376"
  @no_such_target   "401"
  @msg_nick_taken   "433"
  @msg_not_on_chan  "442"

  def handle_event(type, data) do
    case type do
    :priv_msg
      -> on_priv_msg(data)
    :announcement
      -> on_announcement(data)
    _
      -> noop([type, data])
    end
  end

  def handle_command(data) do
    [command | args] = Str.parse(data)

    case command do
    @cmd_quit
      -> quit(args)

    @cmd_nick
      -> nick(args)

    @cmd_privmsg
      -> priv_msg(args)

    @cmd_join
      -> join(args)

    @cmd_part
      -> part(args)

    _
      -> noop(data)
    end
  end

  defp quit(_) do
    {:stop}
  end

  defp nick([nick]) do
    case NickService.register(nick) do
      {:ok, _} ->
        welcome_reply(nick)
      {:error, _} ->
        nick_taken_reply(nick)
    end
  end

  defp welcome_reply(nick) do
    {:ok,
      [
        Str.format([@name, @msg_welcome, nick, "Welcome to #{name_version()}"]),
        Str.format([@name, @msg_motd, "End of MOTD command."])
      ]
    }
  end

  defp nick_taken_reply(nick) do
    {:ok, [Str.format([@name, @msg_nick_taken, "Nickname #{nick} is already in use"])]}
  end

  defp priv_msg([name, text]) do
    # find the destination pid
    result = case find_destination(name) do
      {:ok, pid} ->
        # send the text to that pid & add the source pid
        GenServer.cast(pid, [:priv_msg, self(), self_nick(), name, text])
        {:ok, []}

      {:error, _} ->
        {:ok, [Str.format([@name, @no_such_target, name, "No such nick/channel"])]}
    end
    result
  end

  defp on_priv_msg([src_pid, src_name, dst_name, text]) do
    case src_pid == self() do
      false
        -> {:ok, [Str.format([src_name, @cmd_privmsg, dst_name, text])]}
      true
        # ignore messages from yourself
        -> {:ok, []}
    end
  end

  defp on_announcement([text]) do
    {:ok, [text]}
  end

  defp join([channel]) do
    # join it
    response = case ChanService.join(channel) do
      {:ok, :joined, chan_pid} ->
        channel_msg = Str.format([self_nick(), @cmd_join, channel])
        ChannelHelper.announce(chan_pid, channel_msg)
        {:ok, [Str.format(["dude", "TOPIC", channel, "No topic"])]}
      {:ok, :already_joined, _chan_pid} ->
        {:ok, []}
    end
    response
  end

  defp part([channel]) do
    part([channel, ""])
  end
  defp part([channel, msg]) do
    case ChanService.leave(channel) do
      {:ok, :left, pid}
      ->
        channel_msg = Str.format([self_nick(), @cmd_part, channel, msg])
        ChannelHelper.announce(pid, channel_msg)
        {:ok, [channel_msg]}
      {:ok, :not_joined, _pid}
      ->
        response = Str.format([@name, channel, @msg_not_on_chan, "You're not on that channel"])
        {:ok, [response]}
    end
  end

  defp noop(args) do
    Logger.debug("Ignoring: #{args}")
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

  defp name_version() do
    "#{@name} v#{@version}"
  end

  defp self_nick() do
    "#{NickService.lookup(self())}"
  end

end

defmodule ChanService do
  def start() do
    {:ok, _} = Registry.start_link(keys: :unique, name: ChanService)
  end

  def join(channel) do
    case create_channel(channel) do
      {:ok, pid}
        -> join_channel(pid)

      {:error, {:already_started, pid}}
        -> join_channel(pid)

      _
        -> {:err, nil}
    end
  end

  def lookup(channel) when is_binary(channel) do find_by_name(channel) end

  def member?(channel, nick) do
    chan_pid = lookup(channel)
    case chan_pid do
      nil -> false
      _ -> Channel.member?(chan_pid, nick)
    end
  end

  defp find_by_name(channel) do
    result = case Registry.lookup(ChanService, channel) do
      # found the channel, return its pid
      [{pid, _} | []] -> pid
      # channel doesn't exist
      _ -> nil
    end
    result
  end

  defp create_channel(chan_name) do
    pid_name = {:via, Registry, {ChanService, chan_name}}
    Channel.start(pid_name, chan_name)
  end

  defp join_channel(pid) do
    # what's my name again?
    nick = NickService.lookup(self())
    {:ok, status} = Channel.join(pid, nick, self())
    {:ok, status, pid}
  end
end
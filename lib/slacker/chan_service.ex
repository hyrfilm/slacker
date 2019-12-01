defmodule ChanService do
  require Logger

  def start() do
    Logger.info "[#{__MODULE__}]: started."
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

  def leave(chanel) do leave_channel(lookup(chanel)) end

  def lookup(channel) when is_binary(channel) do find_by_name(channel) end

  def member?(channel) do
    chan_pid = lookup(channel)
    case chan_pid do
      nil -> false
      _ -> ChannelHelper.is_member?(chan_pid)
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
    {:ok, status} = ChannelHelper.join(pid)
    {:ok, status, pid}
  end

  defp leave_channel(pid) do
    ChannelHelper.leave(pid)
  end
end
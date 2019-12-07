defmodule ChanService do
  require Logger

  def start() do
    Logger.info "[#{__MODULE__}]: started."
    # keeps track of what channels exists
    {:ok, _} = Registry.start_link(keys: :unique, name: :AllChannels)
    # keeps track of which clients are in which channels
    {:ok, _} = Registry.start_link(keys: :duplicate, name: :AllClients)
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

  def client_channels(pid) do
    # returns all channels the calling pid is registered in
    Registry.keys(:AllClients, pid)
  end

  defp find_by_name(channel) do
    result = case Registry.lookup(:AllChannels, channel) do
      # found the channel, return its pid
      [{pid, _} | []] -> pid
      # channel doesn't exist
      _ -> nil
    end
    result
  end

  defp create_channel(chan_name) do
    pid_name = {:via, Registry, {:AllChannels, chan_name}}
    Channel.start(pid_name, chan_name)
  end

  defp join_channel(pid) do
    {:ok, status} = ChannelHelper.join(pid)
    register_client_in_channel(pid)
    {:ok, status, pid}
  end

  defp leave_channel(pid) do
    {:ok, status, pid} = ChannelHelper.leave(pid)
    unregister_client_in_channel(pid)
    {:ok, status, pid}
  end

  defp register_client_in_channel(channel_pid) do
    channel_name = ChannelHelper.name(channel_pid)
    Registry.register(:AllClients, channel_name, nil)
  end

  defp unregister_client_in_channel(channel_pid) do
    channel_name = ChannelHelper.name(channel_pid)
    Registry.unregister(:AllClients, channel_name)
  end
end
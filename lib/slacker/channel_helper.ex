defmodule ChannelHelper do
  @moduledoc false

  def is_member?(channel_pid) do
    {:ok, is_member, _} = GenServer.call(channel_pid, {:is_member})
    is_member
  end


  def join(channel_pid) do
    {:ok, result, _} = GenServer.call(channel_pid, {:join})
    result
  end


  def leave(channel_pid) do
    {:ok, result, _} = GenServer.call(channel_pid, {:leave})
    result
  end


  def get_members(channel_pid) do
    {:ok, result, _} = GenServer.call(channel_pid, {:get_members})
    MapSet.to_list(result)
  end

end

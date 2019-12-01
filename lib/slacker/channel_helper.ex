defmodule ChannelHelper do
  def is_member(channel_pid) do
    {:ok, is_member, _} = GenServer.call(channel_pid, {:is_member})
    {:ok, is_member}
  end

  def is_member?(channel_pid) do
    {:ok, is_member, _} = GenServer.call(channel_pid, {:is_member})
    is_member
  end


  def join(channel_pid) do
    {:ok, result, _} = GenServer.call(channel_pid, {:join})
    {:ok, result}
  end


  def leave(channel_pid) do
    {:ok, result, _} = GenServer.call(channel_pid, {:leave})
    {:ok, result}
  end


  def get_members(channel_pid) do
    {:ok, result, _} = GenServer.call(channel_pid, {:get_members})
    {:ok, MapSet.to_list(result)}
  end

  def priv_msg(channel_pid, nick, msg) do
    {:ok, :sent} = GenServer.call(channel_pid, {:priv_msg, nick, msg})
  end

end

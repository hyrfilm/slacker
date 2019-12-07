defmodule ChannelHelper do
  def is_member(channel_pid) do
    {:ok, is_member, _} = GenServer.call(channel_pid, {:is_member})
    {:ok, is_member}
  end

  def is_member?(channel_pid) do
    {:ok, is_member, _} = GenServer.call(channel_pid, {:is_member})
    is_member
  end

  def name(channel_pid) do
    {:ok, name, _} = GenServer.call(channel_pid, {:get_name})
    name
  end

  def join(channel_pid) do
    {:ok, result, _} = GenServer.call(channel_pid, {:join})
    {:ok, result}
  end


  def leave(channel_pid) do
    GenServer.call(channel_pid, {:leave})
  end


  def get_members(channel_pid) do
    {:ok, result, _} = GenServer.call(channel_pid, {:get_members})
    {:ok, MapSet.to_list(result)}
  end

  def priv_msg(channel_pid, src_nick, dst_nick, msg) do
    GenServer.cast(channel_pid, [:priv_msg, self(), src_nick, dst_nick, msg])
  end

  def announce(channel_pid, msg) do
    GenServer.cast(channel_pid, [:announce, msg])
  end

end

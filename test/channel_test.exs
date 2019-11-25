defmodule ChannelTest do
  use ExUnit.Case
  doctest Channel

  test "joins a channel" do
    # create the channel
    {:ok, channel_pid} = Channel.start(:my_channel, "#my_channel")
    # join it
    {:ok, :joined, _} = GenServer.call(channel_pid, {:join, self()})
    # verify that we're in it
    assert as_set([self()]) == GenServer.call(channel_pid, {:get_members})
    # leave it
    {:ok, :left, _} = GenServer.call(channel_pid, {:leave, self()})
    # it should now be empty
    assert as_set([]) == GenServer.call(channel_pid, {:get_members})

    Process.exit(channel_pid, :kill)
  end

  test "joining a channel when already joined" do
    # create the channel
    {:ok, channel_pid} = Channel.start(:my_channel, "#my_channel")
    # join it
    {:ok, :joined, _} = GenServer.call(channel_pid, {:join, self()})
    # join it again, we should get a response that we've joined it already
    {:ok, :already_joined, _} = GenServer.call(channel_pid, {:join, self()})

    Process.exit(channel_pid, :kill)
  end

#  test "creates a channel & sends some chat messages" do
#    Enum.each(["jonas", "simon"], spawn fn -> chat_receiver end)
#  end

  defp as_set(collection) do
    MapSet.new(collection)
  end
end

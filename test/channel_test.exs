defmodule ChannelTest do
  use ExUnit.Case
  doctest Channel

  test "joins and leave a channel" do
    # create the channel
    {:ok, channel_pid} = Channel.start(:my_channel, "#my_channel")

    # we're not a member yet
    assert false == ChannelHelper.is_member?(channel_pid)

    # join the channel
    assert :joined == ChannelHelper.join(channel_pid)

    # now we're a member
    assert true == ChannelHelper.is_member?(channel_pid)
    assert [self()] == ChannelHelper.get_members(channel_pid)

    # leave the channel
    assert :left == ChannelHelper.leave(channel_pid)

    # channel is empty now
    assert [] == ChannelHelper.get_members(channel_pid)

    Process.exit(channel_pid, :kill)
  end

  test "joining a channel when already joined" do
    # create the channel
    {:ok, channel_pid} = Channel.start(:my_channel, "#my_channel")

    # join the channel
    assert :joined == ChannelHelper.join(channel_pid)

    # join the channel again
    assert :already_joined == ChannelHelper.join(channel_pid)

    Process.exit(channel_pid, :kill)
  end


  test "leaving a channel that haven't been joined" do
    # create the channel
    {:ok, channel_pid} = Channel.start(:my_channel, "#my_channel")

    # leave the channel
    assert :not_joined == ChannelHelper.leave(channel_pid)

    Process.exit(channel_pid, :kill)
  end


#  test "creates a channel & sends some chat messages" do
#    Enum.each(["jonas", "simon"], spawn fn -> chat_receiver end)
#  end

  defp as_set(collection) do
    MapSet.new(collection)
  end
end

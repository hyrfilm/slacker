defmodule ChannelTest do
  use ExUnit.Case
  doctest Channel

  test "channel: join & leave" do
    # create the channel
    {:ok, channel_pid} = Channel.start(:my_channel, "#my_channel")

    # we're not a member yet
    assert false == ChannelHelper.is_member?(channel_pid)

    # join the channel
    assert {:ok, :joined} == ChannelHelper.join(channel_pid)

    # now we're a member
    assert true == ChannelHelper.is_member?(channel_pid)
    assert {:ok, [self()]} == ChannelHelper.get_members(channel_pid)

    # leave the channel
    assert {:ok, :left} == ChannelHelper.leave(channel_pid)

    # channel is empty now
    assert {:ok, []} == ChannelHelper.get_members(channel_pid)

    Process.exit(channel_pid, :kill)
  end

  test "channel: joining twice" do
    # create the channel
    {:ok, channel_pid} = Channel.start(:my_channel, "#my_channel")

    # join the channel
    assert {:ok, :joined} == ChannelHelper.join(channel_pid)

    # join the channel again
    assert {:ok, :already_joined} == ChannelHelper.join(channel_pid)

    Process.exit(channel_pid, :kill)
  end


  test "channel: leaving un-joined channel" do
    # create the channel
    {:ok, channel_pid} = Channel.start(:my_channel, "#my_channel")

    # leave the channel
    assert {:ok, :not_joined} == ChannelHelper.leave(channel_pid)

    Process.exit(channel_pid, :kill)
  end


  test "channel: chatting" do
    # create the channel
    {:ok, channel_pid} = Channel.start(:my_channel, "#my_channel")

    # create some fake users
    {:ok, pid1} = FakeUser.start("nick1")
    {:ok, pid2} = FakeUser.start("nick2")
    {:ok, pid3} = FakeUser.start("nick3")

    # join the channel
    FakeUser.join(pid1, channel_pid)
    FakeUser.join(pid2, channel_pid)
    FakeUser.join(pid3, channel_pid)

    # send a message
    ChannelHelper.priv_msg(channel_pid, "st0ner93", "dude!")

    # verify that it was received
    assert FakeUser.priv_messages(pid1) == [[self(), "st0ner93", "#my_channel", "dude!"]]
    assert FakeUser.priv_messages(pid1) == [[self(), "st0ner93", "#my_channel", "dude!"]]
    assert FakeUser.priv_messages(pid1) == [[self(), "st0ner93", "#my_channel", "dude!"]]
  end
end

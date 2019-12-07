defmodule RequestTest do
  use ExUnit.Case

  setup() do
    {:ok, pid1} = Registry.start_link(keys: :unique, name: NickService)
    {:ok, pid2} = Registry.start_link(keys: :unique, name: :AllChannels)
    {:ok, pid3} = Registry.start_link(keys: :unique, name: :AllClients)

    pids = [pid1, pid2, pid3]

    #TODO: This is a hack, we don't have a guarantee that all processes have been killed before
    #TODO: a new test is run, which can make them sporadically fail. FIX!
    on_exit(fn -> kill_all(pids) end)
    :ok
  end

  test "request: NICK" do
    assert false == NickService.exists?("dude")

    {:ok, responses} = Request.handle_command("NICK dude")

    assert responses == [":slacker 001 dude :Welcome to slacker v0.01\r\n", ":slacker 376 :End of MOTD command.\r\n"]
    assert true == NickService.exists?("dude")
  end

  test "request: JOIN" do
    {:ok, responses} = Request.handle_command("JOIN #swecan")

    assert [":dude TOPIC #swecan :No topic\r\n"] == responses

    assert true == ChannelHelper.is_member?(ChanService.lookup("#swecan"))

    Request.handle_command("JOIN #420")

    assert Enum.sort(["#420", "#swecan"]) == Enum.sort(ChanService.client_channels(self()))
  end

  test "request: PRIVMSG" do
    {:ok, pid} = FakeUser.start("dude")
    FakeUser.nick(pid, "dude")
    NickService.register("jones")

    Request.handle_command("PRIVMSG dude :wazup?")

    assert [[self(), "jones", "dude", "wazup?"]] == FakeUser.priv_messages(pid)
  end

  defp kill_all(pids) do
    Enum.each(pids, &Process.exit(&1, :kill))
  end
end
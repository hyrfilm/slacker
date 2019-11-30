defmodule ParseTest do
  use ExUnit.Case

  test "parsing" do
    welcome_msg = ":Hell 001 dude :Welcome to Hell v1.0, you're here for life."
    priv_msg = ":dude PRIVMSG #swecan :legalize it!"
    motd_msg = ":slacker 376 dude :End of MOTD command."

    assert Str.parse(welcome_msg)
           == ["Hell", "001", "dude", "Welcome to Hell v1.0, you're here for life."]

    assert Str.parse(priv_msg)
           == ["dude", "PRIVMSG", "#swecan", "legalize it!"]

    assert Str.parse(motd_msg)
           == ["slacker", "376", "dude", "End of MOTD command."]
  end

  test "formatting" do
    assert Str.format(["Hell", "001", "dude", "Welcome to Hell v1.0, you're here for life."])
           == ":Hell 001 dude :Welcome to Hell v1.0, you're here for life."

    assert Str.format(["dude", "TOPIC", "#swecan", "Legalize it"])
           == ":dude TOPIC #swecan :Legalize it"

    assert Str.format(["dude", "NICK", "dude93"])
           == ":dude NICK :dude93"

    assert Str.format(["dude", "PRIVMSG", "dude93", "zup?"])
           == ":dude PRIVMSG dude93 :zup?"
  end
end
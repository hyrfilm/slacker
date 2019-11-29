defmodule ParseTest do
  use ExUnit.Case

  test "parsing" do
    welcome_msg = ":Hell 001 dude :Welcome to Hell v1.0, you're here for life."

    assert ["Hell", "001", "dude", "Welcome to Hell v1.0, you're here for life."] == Str.parse(welcome_msg)
    assert ["dude", "PRIVMSG", "#swecan", "legalize it!"] == Str.parse(":dude PRIVMSG #swecan :legalize it!")
  end
end
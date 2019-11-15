defmodule Slacker.Main do
  use Application

  def start(_type, _args) do
    UserService.start
    ChanService.start
    Acceptor.start 6667
  end
end
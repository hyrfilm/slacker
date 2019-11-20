defmodule Slacker.Main do
  use Application

  def start(_type, _args) do
    NickService.start
    ChanService.start
    Acceptor.start 6667
  end
end
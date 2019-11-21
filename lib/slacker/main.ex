defmodule Slacker.Main do
  use Application

  def start(_type, _args) do
    children =
    [
      %{
        id: NickService,
        start: {NickService, :start, []}
      },
      %{
        id: ChanService,
        start: {ChanService, :start, []}
      },
      %{
        id: Acceptor,
        start: {Acceptor, :start, [6667]}
      }
    ]

    {:ok, _} = Supervisor.start_link(children, strategy: :one_for_one)
  end
end
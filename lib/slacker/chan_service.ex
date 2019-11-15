defmodule ChanService do
  use GenServer
  require Logger

  # client-side API
  def start do
    GenServer.start_link(__MODULE__, [], name: ChanService)
    Logger.info "#{__MODULE__}: started."
  end

  def join(pid, channel) do
    GenServer.call(ChanService, {:join, {pid, channel}})
  end

  def leave(pid, channel) do
    GenServer.call(ChanService, {:leave, {pid, channel}})
  end

  # Server (callbacks)
  @impl true
  def init(_) do
    channels = %{}
    {:ok, channels}
  end
end
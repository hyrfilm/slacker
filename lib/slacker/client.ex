defmodule Client do
  require Logger
  use GenServer

  def start(socket) do
    GenServer.start(__MODULE__, %{socket: socket})
  end

  def init(%{socket: socket} = state) do
    IO.puts("Creating client connection...")
    IO.puts("#{inspect self()}")
    :inet.setopts(socket, active: true)
    {:ok, %{state | socket: socket}}
  end

#  def handle_info({:tcp, socket, data}, state) do
#    Logger.info "Received #{data}"
#    Logger.info "Sending it back"
#
#    :ok = :gen_tcp.send(socket, data)
#
#    Process.sleep(3000)
#
#    :ok = :gen_tcp.send(socket, "Zup?")
#
#    {:noreply, state}
#  end

  def handle_cast({:msg, msg}, state) do
    IO.puts "#{msg}"
    %{socket: socket} = state
    :gen_tcp.send(socket, msg)
    {:noreply, state}
  end

  def handle_info({:tcp, _socket, data}, state) do
    [p_id, msg] = String.split(data, ",")
    GenServer.cast(IEx.Helpers.pid(p_id), {:msg, msg})
    {:noreply, state}
  end
  def handle_info({:tcp_closed, _}, state), do: {:stop, :normal, state}
  def handle_info({:tcp_error, _}, state), do: {:stop, :normal, state}
end
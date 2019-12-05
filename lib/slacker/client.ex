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

  def handle_cast([type | data], %{socket: socket} = state) do
    # handle an *event* initiated by the server
    {:ok, responses} = Request.handle_event(type, data)
    # send back each response
    Enum.each(responses, socket_send(socket))
    {:noreply, state}
  end

  def handle_info({:tcp, socket, data}, state) do
    # handle a *command* initiated by the user
    IO.puts("COMMAND: '#{data}'")
    result = case Request.handle_command(data) do
      {:ok, responses} ->
        # send back each response...
        Enum.each(responses, socket_send(socket))
        {:noreply, state}
      {:stop} ->
        # ... unless the user wants to quit
        {:stop, :normal, state}
    end
    result
  end
  def handle_info({:tcp_closed, _}, state), do: {:stop, :normal, state}
  def handle_info({:tcp_error, _}, state), do: {:stop, :normal, state}

  defp socket_send(socket) do
    # takes a socket and returns a function that writes to that socket
    &(:gen_tcp.send(socket, &1))
  end
end
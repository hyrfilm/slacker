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

  def handle_cast({:msg, msg}, state) do
    #:gen_tcp.send(socket, msg)
    {:noreply, state}
  end

  def handle_info({:tcp, _socket, data}, state) do
    [command, args] = data |> String.trim("\r\n") |> Str.pop_left
    _response = handle_command(command, args)
    {:noreply, state}
  end
  def handle_info({:tcp_closed, _}, state), do: {:stop, :normal, state}
  def handle_info({:tcp_error, _}, state), do: {:stop, :normal, state}

  def handle_command(command, args) do
    case command do
      "NICK" -> change_nick(args)
      _ -> "?"
    end
  end

  def change_nick(args) do
    [nick, ""] = Str.pop_left(args)
    UserService.login(self(), nick)
    {:ok}
  end

end
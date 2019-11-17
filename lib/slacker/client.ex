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

  def handle_cast({:priv_msg, {src_pid, dst, text}}, state) do
    # find the source nick
    {:ok, src_nick} = UserService.find_nick(src_pid)
    %{socket: socket} = state
    :ok = :gen_tcp.send(socket, ":#{src_nick} PRIVMSG :#{dst} :#{text}")
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
      "NICK" -> nick(args)
      "PRIVMSG" -> priv_msg(args)
      _ -> "?"
    end
  end

  def nick(args) do
    [nick, ""] = Str.pop_left(args)
    UserService.login(self(), nick)
    {:ok}
  end

  def priv_msg(args) do
    # unpack destination & text
    [dst_nick, text] = Str.pop_left(args)
    # find the destination pid
    {:ok, dst_pid} = UserService.find_pid(dst_nick)
    # send the text to that pid & add the source pid
    GenServer.cast(dst_pid, {:priv_msg, {self(), dst_nick, text}})
  end

end
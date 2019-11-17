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
    :ok = :gen_tcp.send(socket, ":#{src_nick} PRIVMSG #{dst} :#{text}\r\n")
    Logger.info("Delivered message #{src_nick} -> #{dst}")
    {:noreply, state}
  end

  def handle_info({:tcp, socket, data}, state) do
    [command, args] = data |> String.trim("\r\n") |> Str.pop_left
    _response = handle_command(socket, command, args)
    {:noreply, state}
  end
  def handle_info({:tcp_closed, _}, state), do: {:stop, :normal, state}
  def handle_info({:tcp_error, _}, state), do: {:stop, :normal, state}

  def handle_command(socket, command, args) do
    case command do
      "NICK" -> nick(socket, args)
      "PRIVMSG" -> priv_msg(args)
      _ -> "?"
    end
  end

  def nick(socket, args) do
    [nick, ""] = Str.pop_left(args)
    UserService.login(self(), nick)
    :gen_tcp.send(socket, ":slacker 001 #{nick} :Welcome to slacker v0.01 #{nick}\r\n")
    :gen_tcp.send(socket, ":slacker 376 #{nick} :End of MOTD command.\r\n")
    {:ok}
  end

  def priv_msg(args) do
    Logger.info("Got privmsg #{args}")

    # unpack destination & text
    [dst_nick, text] = Str.pop_left(args)
    # find the destination pid
    {:ok, dst_pid} = UserService.find_pid(dst_nick)
    # send the text to that pid & add the source pid
    GenServer.cast(dst_pid, {:priv_msg, {self(), dst_nick, text}})
  end

end
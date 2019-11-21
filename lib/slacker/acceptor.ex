defmodule Acceptor do
  require Logger

  def start(port) do
    Logger.info "[#{__MODULE__}]: started."
    {:ok, socket} = :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])
    Logger.info "Accepting connections on port #{port}"
    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    {:ok, client_socket} = :gen_tcp.accept(socket)
    Logger.info "Got connection"
    # Spawn of a new Client process for handling this socket
    {:ok, pid} = Client.start(client_socket)
    # transfer the ownership of the to this process
    :ok = :gen_tcp.controlling_process(client_socket, pid)
    # and repeat
    loop_acceptor(socket)
  end
end

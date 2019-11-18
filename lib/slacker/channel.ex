defmodule Channel do
  use GenServer

  def start(pid_name, chan_name) do
    GenServer.start_link(Channel, chan_name, name: pid_name)
  end

  @impl true
  def init(chan_name) do
    state = %{:name => chan_name, :members => %{}}
    {:ok, state}
  end

  def join(channel_pid, user_nick, user_pid) do
    GenServer.call(channel_pid, {:join, user_nick, user_pid})
  end

  @impl true
  def handle_call({:join, nick, pid}, _from, state) do
    state = put_in(state, [:members, nick], pid)
    {:reply, :ok, state}
  end
end

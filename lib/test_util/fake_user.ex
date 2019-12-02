defmodule FakeUser do
  use GenServer

  def start(name) do
    GenServer.start_link(FakeUser, name: name)
  end

  def join(user_pid, channel_pid) do
    GenServer.call(user_pid, {:join, channel_pid})
  end

  def nick(user_pid, nick) do
    GenServer.call(user_pid, {:nick, nick})
  end

  def priv_messages(user_pid) do
    GenServer.call(user_pid, {:priv_messages})
  end

  @impl true
  def init(_) do
    state = %{:priv_messages => []}
    {:ok, state}
  end

  @impl true
  def handle_call({:join, channel_pid}, _from, state) do
    GenServer.call(channel_pid, {:join})
    {:reply, :ok, state}
  end

  @impl true
  def handle_call({:nick, nick}, _from, state) do
    {:ok, _} = NickService.register(nick)
    {:reply, :ok, state}
  end

  @impl true
  def handle_call({:priv_messages}, _from, state) do
    {:reply, state[:priv_messages], state}
  end

  @impl true
  def handle_cast([:priv_msg | payload], state) do
    priv_messages = get_in(state, [:priv_messages])
    priv_messages = [payload | priv_messages]
    state = put_in(state, [:priv_messages], priv_messages)
    {:noreply, state}
  end
end

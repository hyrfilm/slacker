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

  def join(a, b, c) when a==nil or b==nil or c==nil do
    {:error, :invalid_params}
  end

  def join(channel_pid, user_nick, user_pid) do
    GenServer.call(channel_pid, {:join, user_nick, user_pid})
  end

  def get_members(nil) do {:error, :not_found} end
  def get_members(channel_pid) do
    GenServer.call(channel_pid, {:get_members})
  end

  def member?(channel_pid, nick) do
    GenServer.call(channel_pid, {:is_member, nick})
  end

  def handle_call({:is_member, nick}, _from, state) do
    {:reply, is_member?(state, nick), state}
  end

  @impl true
  def handle_call({:join, nick, pid}, _from, state) when nick !==nil do
    key = [:members, nick]
    response = case is_member?(state, nick) do
      false ->
        {:ok, :joined}
      true ->
        {:ok, :already_joined}
    end

    state = put_in(state, key, pid)
    {:reply, response, state}
  end

  @impl true
  def handle_call({:get_members}, _from, state) do
    {:reply, state[:members], state}
  end

  defp is_member?(state, nick) do
    key = [:members, nick]
    result = case get_in(state, key) do
      nil -> false
      _ -> true
    end
    result
  end
end

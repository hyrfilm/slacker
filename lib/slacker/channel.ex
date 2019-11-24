defmodule Channel do
  use GenServer

  def start(process_name, chan_name) do
    GenServer.start_link(Channel, chan_name, name: process_name)
  end

  @impl true
  def init(chan_name) do
    state = %{:name => chan_name, :members => MapSet.new}
    {:ok, state}
  end

  def handle_call({:is_member, user_pid}, _from, state) do
    {:reply, is_member?(state, user_pid), state}
  end

  @impl true
  def handle_call({:join, pid}, _from, state) do
    join(state, pid)
  end

  @impl true
  def handle_call({:leave, pid}, _from, state) do
    leave(state, pid)
  end

  @impl true
  def handle_call({:get_members}, _from, state) do
    {:reply, get_members(state), state}
  end

  @impl true
  def handle_cast({:priv_msg, {src_pid, msg}}, state) do
    get_members(state) |> broadcast_msg(src_pid, self(), msg)
    {:noreply, state}
  end

  defp join(state, user_pid) do
    case is_member?(state, user_pid) do
      true ->
        {:reply, :already_joined, state}
      false ->
        state = put_member(state, user_pid)
        IO.puts "#{inspect state}"
        {:reply, :joined, state}
    end
  end

  defp leave(state, user_pid) do
    case is_member?(state, user_pid) do
      false ->
        {:reply, :not_joined, state}
      true ->
        state = pop_member(state, user_pid)
        {:reply, :left, state}
    end
  end

  defp is_member?(state, user_pid) do
    MapSet.member?(state[:members], user_pid)
  end

  defp get_members(state) do
    get_in(state, [:members])
  end

  defp broadcast_msg(pids, src_pid, channel, msg) do
    Enum.each(pids, send_priv_msg(src_pid, channel, msg))
  end

  defp send_priv_msg(src_pid, channel, msg) do
    &(GenServer.cast(&1, {:priv_msg, {src_pid, channel, msg}}))
  end

  defp put_member(state, user_pid) do
    members = MapSet.put(state[:members], user_pid)
    put_in(state[:members], members)
  end

  defp pop_member(state, user_pid) do
    members = MapSet.delete(state[:members], user_pid)
    put_in(state[:members], members)
  end
end

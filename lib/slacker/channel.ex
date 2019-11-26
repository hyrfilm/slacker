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

  @impl true
  def handle_call({:join}, {pid, _}, state) do
    case is_member?(state, pid) do
      true ->
        {:reply, {:ok, :already_joined, self()}, state}
      false ->
        state = put_member(state, pid)
        {:reply, {:ok, :joined, self()}, state}
    end
  end

  @impl true
  def handle_call({:leave}, {pid, _}, state) do
    case is_member?(state, pid) do
      false ->
        {:reply, {:ok, :not_joined, self()}, state}
      true ->
        state = pop_member(state, pid)
        {:reply, {:ok, :left, self()}, state}
    end
  end

  def handle_call({:is_member}, {pid, _}, state) do
    {:reply, {:ok, is_member?(state, pid), self()}, state}
  end

  @impl true
  def handle_call({:get_members}, _from, state) do
    {:reply, {:ok, get_members(state), self()}, state}
  end

  @impl true
  def handle_call({:priv_msg, src_nick, msg}, {src_pid, _}, state) do
    get_members(state) |> broadcast_msg(src_pid, src_nick, self(), state[:name], msg)
    {:reply, {:ok, :sent}, state}
  end

  defp is_member?(state, user_pid) do
    MapSet.member?(state[:members], user_pid)
  end

  defp get_members(state) do
    get_in(state, [:members])
  end

  defp broadcast_msg(pids, src_pid, src_nick, channel_pid, channel_name, msg) do
    Enum.each(pids, send_priv_msg(src_pid, src_nick, channel_name, msg))
  end

  defp send_priv_msg(src_pid, src_nick, channel_name, msg) do
    &(GenServer.cast(&1, {:priv_msg, {src_pid, src_nick, channel_name, msg}}))
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

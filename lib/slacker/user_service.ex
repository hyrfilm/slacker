defmodule UserService do
  use GenServer
  require Logger


  # client-side API

  def start do
    GenServer.start_link(__MODULE__, [], name: UserService)
    Logger.info "#{__MODULE__}: started."
  end

  def login(pid, nick) do
    GenServer.call(UserService, {:login, {pid, nick}})
  end

  def logout(pid, nick) do
    GenServer.call(UserService, {:logout, {pid, nick}})
  end

  # Server (callbacks)

  @impl true
  def init(_) do
    state = %{:nicks => %{},:pids => %{}}
    {:ok, state}
  end

  @impl true
  def handle_call({:login, {pid, nick}}, _from, state) do
    cond do
      # error-clause: already logged in
      pid_taken(state, pid) -> error(state, :pid_taken)

      # error-clause: nickname is already taken
      nick_taken(state, nick) -> error(state, :nick_taken)

      # default-clause: update the state with the pid & nick
      true -> update_state(state, pid, nick)
    end
  end

  @impl true
  def handle_call({:logout, {pid, nick}}, _from, state) do
    {_, state} = pop_in(state, [:nicks, pid])
    {_, state} = pop_in(state, [:pids, nick])
    IO.puts ("#{inspect(state)}")
    {:reply, :ok, state}
  end

  defp update_state(state, pid, nick) do
    new_state =
      state |>
      put_in([:nicks, pid], nick) |>
      put_in([:pids, nick], pid)
    IO.puts ("#{inspect(new_state)}")
    {:reply, :ok, new_state}
  end

  defp error(state, error) do
    {:reply, error, state}
  end

  defp nick_taken(state, nick) do
    # a nick is taken if it's already mapped to a pid
    Map.has_key?(state[:pids], nick)
  end

  defp pid_taken(state, pid) do
    # a nick is taken if it's already mapped to a pid
    Map.has_key?(state[:nicks], pid)
  end
end
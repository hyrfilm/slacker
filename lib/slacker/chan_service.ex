defmodule ChanService do
  def start() do
    {:ok, _} = Registry.start_link(keys: :unique, name: ChanService)
  end

  def join(channel) do
    case create_channel(channel) do
      {:ok, pid}
        -> {:ok, pid}

      {:err, pid}
        -> join_channel(pid)

      true
        -> {:err, nil}
    end
  end

  defp create_channel(chan_name) do
    pid_name = {:via, Registry, {ChanService, chan_name}}
    Channel.start(pid_name, chan_name)
  end

  defp join_channel(pid) do
    # what's my name again?
    nick = NickService.find_by_pid(self())
    Channel.join(pid, nick, self())
  end
end
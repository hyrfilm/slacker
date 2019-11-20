defmodule NickService do
  def start() do
    {:ok, _} = Registry.start_link(keys: :duplicate, name: NickService)
  end

  def register(nick) do
    # registering a new nick means that the old nick will not be active
    # however some care must be taken when doing this because unregistering the old nick
    # and then failing to register the new one (because someone took it, for example) would end up with the
    # pid having no nick associated with it. Therefore the new nick is registered first, then
    # the old nick is unregistered. This means that there might be a short moment while the pid
    # is associated with both nicks... but that doesn't seem to be a big deal.

    # first retrieve the already existing keys for this pid
    old_keys = Registry.keys(NickService, self())
    # register the pid under the new name
    Registry.register(NickService, nick, nil)
    # now it should be safe to unregister the old keys
    Enum.each(old_keys, unregister())
    # done
    {:ok, old_keys}
  end

  def lookup(nick) when is_binary(nick) do find_by_nick(nick) end
  def lookup(pid) when is_pid(pid) do find_by_pid(pid) end

  def exists?(nick) when is_binary(nick) do
    find_by_nick(nick) != nil
  end
  def exists?(pid) when is_pid(pid) do
    find_by_pid(pid) != nil
  end

  defp find_by_nick(nick) do
    result = case Registry.lookup(NickService, nick) do
      # nick is registered, return their pid
      [{pid, _} | []] -> pid
      # nick isn't registered
      _ -> nil
    end
    result
  end

  defp find_by_pid(pid) do
    case Registry.keys(NickService, pid) do
    [] -> nil
    [nick] -> nick
    #TODO: shouldn't happend, means a user has many nick names
    _ -> nil
    end
  end

  defp unregister() do
    # protected because nicks are unregistered automatically when a the owning process dies
    &Registry.unregister(NickService, &1)
  end
end

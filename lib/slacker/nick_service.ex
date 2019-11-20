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

  def find_by_nick(nick) do
    [{pid, _} | []] = Registry.lookup(NickService, nick)
    pid
  end

  def find_by_pid(pid) do
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
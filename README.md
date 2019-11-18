Resource
 create(pid, name)
 destroy(pid)
 find_by_pid(pid)
 find_by_name(name)
 get_or_create(name, start_func)

# login
Resource.create(self(), nick)

# quit
Resource.destroy(self())

# join channel
{:ok, pid} = Resource.get_or_create(name, Chan.start)
ChanService.join(pid, self())
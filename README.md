# Slacker
## minimal concurrent IRC server

### run (using Docker)
`docker run hyrfilm/slacker`

This will start will start the server which will accepts connections on port 6667.
you could now connect to it with a irc-client or just with telnet:
```bash
telnet localhost 6667
NICK hyrfilm
JOIN #some-channel
```

### supported clients
Tested with:
- [Irssi](https://irssi.org/)
- [LimeChat](http://limechat.net/)
- [Colloquy](http://colloquy.info/)

### performance
Should be able to handle a fair amount of connections. All users, sockets & channels are handled concurrently.

### supports
Slacker currently only handles a minimal subset of the IRC protocol:
- nicknames
- channels (creating / joining / leaving)
- messaging (in channels & private messages)
- note that all traffic is sent in plain-text
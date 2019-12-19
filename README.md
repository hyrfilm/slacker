# Slacker
## minimal concurrent IRC server

### run (using Docker)
`docker run -p 0.0.0.0:6667:6667 -it --rm hyrfilm/slacker`

This will start the server which accepts connections on port 6667.
you could now connect to it with a irc-client or, hey if you're feeling old fashioned just use telnet:
```bash
telnet localhost 6667
NICK hyrfilm
JOIN #some-channel
PRIVMSG #some-channel :dude!
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

# Slacker
## minimal concurrent IRC server

### run (using Docker)
`docker run hyrfilm/slacker`

you could now connect to it with a irc-client or just with telnet:
```bash
telnet localhost 6667
NICK hyrfilm
JOIN #some-channel
```

This will start will start the server which will accepts connections on port 6667.

### performance
Should be able to handle a fair amount of connections. All users, sockets & channels are handled concurrently.

### supported clients
Tested with:
- Irssi
- LimeChat
- Colloquy


### supports
Slacker currently only handles a minimal subset of the IRC protocol:
- nicknames
- channels (creating / joining / leaving)
- messaging (in channels & private messages)
- note that all traffic is sent in plain-text
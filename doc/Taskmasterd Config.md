##	How can I configure Taskmasterd?
Taskmasterd is configured using a simple `config.json`. Following are the configurable options:
```json
# TCP listening port:
"port" : <port number>

# Enable remote connections:
"remoteConnections" : <true/false>

# Echo commands:
"echoCommands" : <true/false>

# Job config directory:
"configDirectory" : <relative path>

# Log config directory:
"logDirectory" : <relative path>
```

Alternatively, if you simply run the program without configuring it, an interactive setup wizard will automatically run.

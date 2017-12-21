##	How can I configure Taskmasterd?
Taskmasterd is configured using a simple `config.json`. Following are the configurable options:

 - "port"				TCP Listening port
 - "remoteConnections"	Allow remote connections
 - "echoCommands"		Echo all commands received from taskmasterctl.
 - "configDirectory"	Directory containing all the ".tm.json" files.
 - "logDirectory"		Directory to save log files.

Taskmasterd does also have a built in interactive setup wizard that will automatically run if there is no valid "config.json" file.
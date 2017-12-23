##	How can I configure Taskmasterd?
Taskmasterd is configured using a simple `config.json`. Following are the configurable options:

 - "port"				TCP Listening port
 - "remoteConnections"	Allow remote connections
 - "Verbosity"			What type of messaged to print to the console.
 - "configDirectory"	Directory containing all the ".tm.json" files.
 - "logDirectory"		Directory to save log files.

The verbosity levels are as follows:

 - 0:	No output.
 - 1:	Connection alerts.
 - 2:	Connection alerts and errors.
 - 3:	All messages.

Taskmasterd does also have a built in interactive setup wizard that will automatically run if there is no valid "config.json" file.
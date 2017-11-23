#	Taskmasterd
This is the server of the project. It interfaces between the processes themselves and Taskmasterctl(the actual control program).

##	How can I configure it?
Taskmasterd is configured using a simple `config.json`. Following are the configurable options:

	# TCP listening port:
	"tcpListen" : <port number>

	# Enable remote connections:
	"remoteListen" : <true/false>

	# Echo commands:
	"echoCommands" : <true/false>

	# Job config directory:
	"jobsDirectory" : <relative path>
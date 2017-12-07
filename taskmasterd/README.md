#	Taskmasterd
This is the server of the project. It interfaces between the processes themselves and Taskmasterctl(the actual control program).

##	How can I configure it?
Taskmasterd is configured using a simple `config.json`. Following are the configurable options:

	# TCP listening port:
	"tcpListen" : <port number>

	# Enable remote connections:
	"remoteListen" : <1/0>

	# Echo commands:
	"echoCommands" : <1/0>

	# Job config directory:
	"jobsDirectory" : <relative path>

Alternatively, if you simply run the program without configuring it, an interactive setup wizard will automatically run.
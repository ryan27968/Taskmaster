//	Global variables.
struct globalStruct
{
	int		port = -1;
	bool	remoteConnections = false;
	bool	echoCommands = true;
	string	configDirectory;
	string	logDirectory;
}

globalStruct	globals;
globalStruct	defaults = {7777, 0, 1, "./config", "./log"};

//	Constants
const string		configFile = "config.json";
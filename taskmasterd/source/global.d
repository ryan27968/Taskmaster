//	Global variables.
struct globalStruct
{
	int		port = -1;
	byte	remoteConnections = -1;
	byte	echoCommands = -1;
	string	configDirectory;
}

globalStruct	globals;
globalStruct	defaults = {7777, 0, 1, "./config"};

//	Constants
const string		configFile = "config.json";
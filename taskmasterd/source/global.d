//	Global variables.
struct globalStruct
{
	ushort	port = 0;
	bool	remoteConnections = false;
	bool	echoCommands = true;
	string	configDirectory;
	string	logDirectory;
}

globalStruct	globals;
globalStruct	defaults = {7777, 0, 1, "./config", "./log"};

//	Constants
string		configFile = "config.json";
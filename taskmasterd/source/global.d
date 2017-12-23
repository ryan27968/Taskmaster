//	Global variables.
struct globalStruct
{
	ushort	port = 0;
	bool	remoteConnections;
	ushort	verbosity;
	string	configDirectory;
	string	logDirectory;
}

globalStruct	globals;
globalStruct	defaults = {7777, 0, 2, "./config", "./log"};

//	Constants
string		configFile = "config.json";
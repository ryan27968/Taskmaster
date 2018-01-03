//	Global struct.
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

//	Settings
string		configFile = "config.json";

//	Variables
bool		colorTerm = true;
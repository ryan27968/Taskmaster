//	Config variables. The defaults are already entered.
struct globalStruct
{
	int		port = 7777;
	bool	remoteConnections = false;
	bool	echoCommands = true;
	string	configDirectory = "./config";
}

globalStruct globals;

//	Constants
const string	configFile = "config.json";
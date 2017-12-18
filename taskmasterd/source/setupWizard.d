import std.conv;
import std.string;
import std.stdio;
import std.file;
import global;
import config;

//	This function configures all the basic options using a simple command-line wizard.

void	setupWizard()
{
	bool			end = false;
	string			tempStr;
	int				tempInt = 0;
	globalStruct	tempStruct;
	
	//	Port Number
	while(!end)
	{
		std.stdio.write("\nWhich port do you want to listen on?\n[", defaults.port, "] ");
		tempStr = readln().strip;
		if (tempStr.length == 0)
		{
			tempStruct.port = defaults.port;
			end = true;
		}
		else if (isNumeric(tempStr) && (tempInt = to!int(tempStr)) >= 0 && tempInt <= 65535)
		{
			tempStruct.port = tempInt;
			end = true;
		}
		else
			std.stdio.write("\"", tempStr, "\" is not a valid port number. \n",
			"Please enter a number between 0 and 65535.\n");
	}
	end = false;

	//	Remote connections
	while (!end)
	{
		if (defaults.remoteConnections == 1)
			std.stdio.write("\nDo you want to allow remote connections?\n[Yes] ");
		else
			std.stdio.write("\nDo you want to allow remote connections?\n[No] ");
		tempStr = toLower(readln().strip);
		switch (tempStr)
		{
			case "":
				tempStruct.remoteConnections = defaults.remoteConnections;
				end = true;
				break;
			case "t":
			case "true":
			case "y":
			case "yes":
				tempStruct.remoteConnections = 1;
				end = true;
				break;
			case "f":
			case "false":
			case "n":
			case "no":
				tempStruct.remoteConnections = 0;
				end = true;
				break;
			default:
				std.stdio.write("Please enter yes or no.\n");
				break;
		}
	}
	end = false;

	//Echo Commands:
	while (!end)
	{
		if (defaults.echoCommands == 1)
			std.stdio.write("\nDo you want to echo all received commands?\n[Yes] ");
		else
			std.stdio.write("\nDo you want to echo all received commands?\n[No] ");
		tempStr = toLower(readln().strip);
		switch (tempStr)
		{
			case "":
			tempStruct.echoCommands = defaults.echoCommands;
				end = true;
				break;
			case "t":
			case "true":
			case "y":
			case "yes":
				tempStruct.echoCommands = 1;
				end = true;
				break;
			case "f":
			case "false":
			case "n":
			case "no":
				tempStruct.echoCommands = 0;
				end = true;
				break;
			default:
				std.stdio.write("Please enter yes or no.\n");
				break;
		}
	}
	end = false;

	//Config directory
	while(!end)
	{
		std.stdio.write("\nWhere is the directory containing your config files?\n[", defaults.configDirectory, "] ");
		tempStr = readln().strip;
		if (tempStr.length == 0)
			tempStr = defaults.configDirectory;
		if (!tempStr.exists)
			mkdir(tempStr);
		if (tempStr.exists && tempStr.isDir)
		{
			tempStruct.configDirectory = tempStr;
			end = true;
		}
		else
			std.stdio.write("\"", tempStr, "\" is not a directory.\n");
	}
	end = false;

	//Log directory
	while(!end)
	{
		std.stdio.write("\nWhere do you want to store your log files?\n[", defaults.logDirectory, "] ");
		tempStr = readln().strip;
		if (tempStr.length == 0)
			tempStr = defaults.logDirectory;
		if (!tempStr.exists)
			mkdir(tempStr);
		if (tempStr.exists && tempStr.isDir)
		{
			tempStruct.logDirectory = tempStr;
			end = true;
		}
		else
			std.stdio.write("\"", tempStr, "\" is not a directory.\n");
	}
	config.set(tempStruct);
}

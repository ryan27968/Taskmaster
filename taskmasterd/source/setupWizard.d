import std.conv;
import std.string;
import std.stdio;
import std.file;
import global;
import jsonx;

//	This function configures all the basic options using a simple command-line wizard.

void	setupWizard()
{
	bool	end = false;
	string	tempStr;
	int		tempInt = 0;
	
	//	Port Number
	while(!end)
	{
		std.stdio.write("\nWhich port do you want to listen on?\n[", globals.port, "] ");
		tempStr = readln().strip;
		if (tempStr.length == 0)
			end = true;
		else if (isNumeric(tempStr) && (tempInt = to!int(tempStr)) >= 0 && tempInt <= 65535)
		{
			globals.port = tempInt;
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
		std.stdio.write("\nDo you want to allow remote connections?\n[", globals.remoteConnections, "] ");
		tempStr = toLower(readln().strip);
		switch (tempStr)
		{
			case "":
				end = true;
				break;
			case "t":
			case "true":
			case "y":
			case "yes":
				globals.remoteConnections = 1;
				end = true;
				break;
			case "f":
			case "false":
			case "n":
			case "no":
				globals.remoteConnections = 0;
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
		std.stdio.write("\nDo you want to echo all received commands?\n[", globals.echoCommands, "] ");
		tempStr = toLower(readln().strip);
		switch (tempStr)
		{
			case "":
				end = true;
				break;
			case "t":
			case "true":
			case "y":
			case "yes":
				globals.echoCommands = 1;
				end = true;
				break;
			case "f":
			case "false":
			case "n":
			case "no":
				globals.echoCommands = 0;
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
		std.stdio.write("\nWhere is the directory containing your config files?\n[", globals.configDirectory, "] ");
		tempStr = readln().strip;
		if (tempStr.length == 0)
			tempStr = globals.configDirectory;
		if (tempStr.exists && tempStr.isDir)
		{
			globals.configDirectory = tempStr;
			end = true;
		}
		else
			std.stdio.write("\"", tempStr, "\" is not a directory.\n");
	}

	//Convert to json.
	string json = jsonx.jsonEncode(globals);
//	writeln(json);

	//Write to file.
	std.file.write(configFile, json);
}
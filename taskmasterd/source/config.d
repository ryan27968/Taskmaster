import std.file;
import std.stdio;
import std.string;
import global;
import jsonx;
import setupWizard;

void	write()
{
	string	json = jsonEncode(globals);

	try
	{
		std.file.write(configFile, json);
	}
	catch (FileException error)
	{
		std.stdio.writeln("File writing error: ", error);
	}
}

void	set(globalStruct config)
{
	globals = config;
	write();
}

void	readFile()
{
	if (exists(configFile) && isFile(configFile))
	{
		globalStruct fromFile;
		string fileText = readText(configFile);
		try
		{
			fromFile = jsonDecode!globalStruct(fileText);
			if (indexOf(fileText, "\"port\":") != -1
			&&	indexOf(fileText, "\"remoteConnections\":") != -1
			&&	indexOf(fileText, "\"echoCommands\":") != -1
			&&	indexOf(fileText, "\"configDirectory\":") != -1
			&&	indexOf(fileText, "\"logDirectory\":") != -1)
			{
				set(fromFile);
				return ;
			}
		}
		catch (jsonx.JsonException e){}
		writeln("\"", configFile, "\" incomplete/invalid. Running setup wizard.");
	}
	else
		writeln("\"", configFile, "\" does not exist. Running setup wizard.");
	setupWizard.setupWizard();
}

void	setDefaults(globalStruct fromFile)
{
	if (fromFile.port != -1)
		defaults.port = fromFile.port;
	if (fromFile.remoteConnections != -1)
		defaults.remoteConnections = fromFile.remoteConnections;
	if (fromFile.echoCommands != -1)
		defaults.echoCommands = fromFile.echoCommands;
	if (fromFile.configDirectory.length > 0)
		defaults.configDirectory = fromFile.configDirectory;
}
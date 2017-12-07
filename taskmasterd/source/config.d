import std.file;
import std.stdio;
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
		try
			fromFile = jsonDecode!globalStruct(readText(configFile));
		catch (jsonx.JsonException e)
		{}
		if (fromFile.port == -1 || fromFile.remoteConnections == -1 ||
		fromFile.echoCommands == -1 || fromFile.configDirectory.length == 0)
		{
			writeln("\"", configFile, "\" incomplete/invalid. Running setup wizard.");
			setDefaults(fromFile);
		}
		else
			return ;
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
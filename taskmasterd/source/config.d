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
		std.file.write(configFile, json);
	catch (FileException error)
		std.stdio.writeln("File writing error: ", error);
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
		{
			string fileText = readText(configFile).strip();
			fromFile = jsonDecode!globalStruct(fileText);
			if (indexOf(fileText, "\"port\":") != -1
			&&	indexOf(fileText, "\"remoteConnections\":") != -1
			&&	indexOf(fileText, "\"verbosity\":") != -1
			&&	indexOf(fileText, "\"configDirectory\":") != -1
			&&	indexOf(fileText, "\"logDirectory\":") != -1)
			{
				set(fromFile);
				return ;
			}
		}
		catch (Throwable){}
		writeln("\"", configFile, "\" incomplete/invalid. Running setup wizard.");
	}
	else
		writeln("\"", configFile, "\" does not exist. Running setup wizard.");
	setupWizard.setupWizard();
}

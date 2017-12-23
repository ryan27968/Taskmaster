import std.stdio;
import std.string;
import std.file;
import std.datetime;
import std.conv;

import global;

private string	fileTime()
{
	return (Clock.currTime.toISOExtString.split(".")[0].replace("T", "__").replace(":", "."));
}

private string	logTime()
{
	return (Clock.currTime.toISOExtString.split(".")[0].replace("T", " "));
}

class tmdLog
{
	static
	{
		File	log;
		string	logPath;

		void	init()
		{
			logPath = globals.logDirectory ~ "/taskmasterd/";
			mkdirRecurse(logPath);
			log = File(logPath ~ fileTime() ~ ".log", "a");
		}

		void	message(string msg)
		{
			if (globals.verbosity == 3)
				writeln("MSG: ", msg);
			log.writeln("MSG: ", logTime, " -- ", msg);
			log.flush();
		}

		void	error(string msg)
		{
			if (globals.verbosity >= 2)
				writeln("ERR: ", msg);
			log.writeln("ERR: ", logTime, " -- ", msg);
			log.flush();
		}

		void	net(string	msg)
		{
			if (globals.verbosity >= 1)
				writeln("NET: ", msg);
			log.writeln("NET: ", logTime, " -- ", msg);
			log.flush();
		}

		void	print(string msg)
		{
			writeln(msg);
			log.writeln("MSG: ", logTime, " -- ", msg);
			log.flush();
		}
	}
}

class jobLog
{
	File	log;
	string	logPath;
	string	jobName;
	int		procNr;

	this(string name, int nr)
	{
		jobName = name;
		procNr = nr;
		logPath = globals.logDirectory ~ "/jobs/" ~ jobName ~ "/" ~ to!string(procNr) ~ "/";
		mkdirRecurse(logPath);
		log = File(logPath ~ fileTime() ~ ".log", "a");
	}

	void	message(string msg)
	{
		if (globals.verbosity == 3)
			writeln("MSG: ", jobName, ":", procNr, " - ", msg);
		log.writeln("MSG: ", logTime, " -- ", msg);
		log.flush();
	}

	void	error(string msg)
	{
		if (globals.verbosity >= 2)
			writeln("ERR: ", jobName, ":", procNr, " - ", msg);
		log.writeln("ERR: ", logTime, " -- ", msg);
		log.flush();
	}

	void	print(string msg)
	{
		writeln("MSG: ", jobName, ":", procNr, " - ", msg);
		log.writeln("NET: ", logTime, " -- ", msg);
		log.flush();
	}
}

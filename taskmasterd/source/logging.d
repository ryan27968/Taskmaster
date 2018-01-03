import std.stdio;
import std.string;
import std.file;
import std.datetime;
import std.conv;

import global;

private string	fileTime()
{
	try
		return (Clock.currTime.toISOExtString.split(".")[0].replace("T", "__").replace(":", "."));
	catch (Throwable)
		return ("TIME_FETCH_ERR");
}

private string	logTime()
{
	try
		return (Clock.currTime.toISOExtString.split(".")[0].replace("T", " "));
	catch (Throwable)
		return ("TIME_FETCH_ERR");
}

class tmdLog
{
	static
	{
		File	log;
		string	logPath;
		string	msgString;
		string	errString;
		string	netString;

		void	init()
		{
			logPath = globals.logDirectory ~ "/taskmasterd/";
			mkdirRecurse(logPath);
			log = File(logPath ~ fileTime() ~ ".log", "a");
			if (colorTerm)
			{
				msgString = "\033[33mMSG:\033[39m ";
				errString = "\033[31mERR:\033[39m ";
				netString = "\033[32mNET:\033[39m ";
			}
			else
			{
				msgString = "MSG: ";
				errString = "ERR: ";
				netString = "NET: ";
			}
		}

		void	message(string s)
		{
			if (globals.verbosity == 3)
				writeln(msgString, s);
			log.writeln("MSG: ", logTime, " -- ", s);
			log.flush();
		}

		void	error(string s)
		{
			if (globals.verbosity >= 2)
				writeln(errString, s);
			log.writeln("ERR: ", logTime, " -- ", s);
			log.flush();
		}

		void	net(string	s)
		{
			if (globals.verbosity >= 1)
				writeln(netString, s);
			log.writeln("NET: ", logTime, " -- ", s);
			log.flush();
		}

		void	print(string s)
		{
			writeln(s);
			log.writeln("MSG: ", logTime, " -- ", s);
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
	string	msgString;
	string	errString;

	this(string name, int nr)
	{
		jobName = name;
		procNr = nr;
		logPath = globals.logDirectory ~ "/jobs/" ~ jobName ~ "/" ~ to!string(procNr) ~ "/";
		mkdirRecurse(logPath);
		log = File(logPath ~ fileTime() ~ ".log", "a");
		if (colorTerm)
		{
			msgString = "\033[33mMSG:\033[39m ";
			errString = "\033[31mERR:\033[39m ";
		}
		else
		{
			msgString = "MSG: ";
			errString = "ERR: ";
		}
	}

	void	message(string s)
	{
		if (globals.verbosity == 3)
			writeln(msgString, jobName, ":", procNr, " - ", s);
		log.writeln("MSG: ", logTime, " -- ", s);
		log.flush();
	}

	void	error(string s)
	{
		if (globals.verbosity >= 2)
			writeln(errString, jobName, ":", procNr, " - ", s);
		log.writeln("ERR: ", logTime, " -- ", s);
		log.flush();
	}

	void	print(string s)
	{
		writeln(msgString, jobName, ":", procNr, " - ", s);
		log.writeln("MSG: ", logTime, " -- ", s);
		log.flush();
	}
}

import std.file;
import std.stdio;
import std.string;
import std.algorithm.sorting;

import global;
import jsonx;

extern (C) ushort	umask(ushort mask);

struct jobDataStr
{
	string		cmd;
	int			procNr;
	bool		autoStart;
	byte		restart;
	int			startTime;
	byte		normalExitSig;
	int			restartTimes;
	bool		stopSig;
	int			stopTime;
	string		stdout;
	string		stderr;
	string[]	env;
	string		dir;
	ushort		umask;
}

class job
{
	jobDataStr data;
}

job[string] jobs;

void	parseFile(string filename)
{
	string name;
	string fileText = readText(filename);
	jobDataStr tempJob;

	try
	{
		tempJob = jsonDecode!jobDataStr(fileText);
		if (indexOf(fileText, "\"cmd\":") == -1
		||	indexOf(fileText, "\"procNr\":") == -1
		||	indexOf(fileText, "\"autoStart\":") == -1
		||	indexOf(fileText, "\"restart\":") == -1
		||	indexOf(fileText, "\"startTime\":") == -1
		||	indexOf(fileText, "\"normalExitSig\":") == -1
		||	indexOf(fileText, "\"restartTimes\":") == -1
		||	indexOf(fileText, "\"stopSig\":") == -1
		||	indexOf(fileText, "\"stopTime\":") == -1
		||	indexOf(fileText, "\"stdout\":") == -1
		||	indexOf(fileText, "\"stderr\":") == -1
		||	indexOf(fileText, "\"env\":") == -1
		||	indexOf(fileText, "\"dir\":") == -1
		||	indexOf(fileText, "\"umask\":") == -1)
		{
			stderr.writeln("\"", filename, "\" invalid!");
			return ;
		}
	}
	catch (jsonx.JsonException e)
	{
		stderr.writeln("\"", filename, "\" invalid!");
		return ;
	}
	name = chomp(filename, ".tm.json");
	name = chompPrefix(name, globals.configDirectory);
	name = name[1 .. name.length];
	jobs[name] = new job;
	jobs[name].data = tempJob;
}

void	parseDir()
{
	auto entries = dirEntries(globals.configDirectory, "*.tm.json", SpanMode.depth, true);
	foreach (DirEntry entry; entries)
	{
		if (entry.isFile)
			parseFile(entry.name);
	}
}
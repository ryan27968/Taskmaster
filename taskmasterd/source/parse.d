import std.file;
import std.stdio;
import std.string;
import std.utf;

import global;
import jsonx;
import job;
import logging;

void	parseFile(string filename)
{
	string name;
	string fileText;
	jobDataStr tempJob;

	name = chomp(filename, ".tm.json");
	name = chompPrefix(name, globals.configDirectory);
	name = name[1 .. name.length];

	if (!exists(filename) && name in jobs)
	{
		jobs[name].stop();
		while (jobs[name].stoppedCount < jobs[name].data.procNr)
			jobs[name].watchdog();
		jobs.remove(name);
		return ;
	}

	try
		fileText = readText(filename);
	catch (FileException e)
	{
		tmdLog.error("File read error: " ~ e.msg);
		return ;
	}
	catch (UTFException e)
	{
		tmdLog.error("File encoding error: " ~ e.msg);
		return ;
	}

	try
	{
		tempJob = jsonDecode!jobDataStr(fileText);
		if (indexOf(fileText, "\"cmd\":") == -1
		||	indexOf(fileText, "\"procNr\":") == -1
		||	indexOf(fileText, "\"autoStart\":") == -1
		||	indexOf(fileText, "\"restart\":") == -1
		||	indexOf(fileText, "\"startTime\":") == -1
		||	indexOf(fileText, "\"normalExitCode\":") == -1
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
	tempJob.name = name;
	tempJob.filename = filename;
	if (name in jobs && jobs[name].data != tempJob)
	{
		writeln(jobs[name].data);
		writeln(tempJob);
		jobs[name].stop();
		while (jobs[name].stoppedCount < jobs[name].data.procNr)
			jobs[name].watchdog();
		jobs.remove(name);
	}
	if (name !in jobs)
		jobs[name] = new job(tempJob);
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
import std.file;
import std.stdio;
import std.string;
import std.utf;
import std.conv;

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
		jobs[name].logMessage("Job deleted.");
		jobs.remove(name);
		return ;
	}

	try
		fileText = readText(filename).strip();
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
	try
		validateJob(tempJob);
	catch (jobException e)
	{
		tmdLog.print("File \"" ~ filename ~ "\" invalid.");
		return ;
	}
	if (name in jobs && jobs[name].data != tempJob)
	{
		jobs[name].stop();
		while (jobs[name].stoppedCount < jobs[name].data.procNr)
			jobs[name].watchdog();
		jobs[name].logMessage("Reloading job. See new log file.");
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

void	validateJob(jobDataStr job)
{
	if (job.cmd == ""
	||	job.procNr < 1
	||	job.restart < 0
	||	job.restart > 2
	||	job.startTime < 1
	||	job.stopTime < 1
	||	job.stdout == ""
	||	job.stderr == ""
	||	to!ushort(job.umask, 8) > octal!777
	||	to!ushort(job.umask, 8) < octal!0)
		throw new jobException("");
}

class jobException : Exception
{
    this(string msg)
	{
        super(msg);
    }
}
import std.process;
import std.stdio;
import std.conv;

struct envVar
{
	string	name;
	string	value;
}

struct jobDataStr
{
	string			cmd;
	int				procNr;
	bool			autoStart;
	byte			restart;
	int				startTime;
	byte			normalExitSig;
	int				restartTimes;
	byte			stopSig;
	int				stopTime;
	string			stdout;
	string			stderr;
	envVar[]		env;
	string			dir;
	string			umask;
}

class job
{
	class process
	{
		Pid		processid;
		int		procNr;
		File	stdout;
		File	stdin;

		this(int procNrIn)
		{
			procNr = procNrIn;
		}

		void	start()
		{
			stdout = File(data.dir ~ to!string(procNr) ~ "_" ~ data.stdout, "a");
			stderr = File(data.dir ~ to!string(procNr) ~ "_" ~ data.stderr, "a");
			processid = spawnShell(data.cmd, std.stdio.stdin, stdout,
			stderr, envVars, Config.none, data.dir, nativeShell);
		}
	}

	jobDataStr		data;
	process[]		processes;
	string[string]	envVars;

	this(jobDataStr dataIn)
	{
		data = dataIn;
		processes.length = data.procNr;

		foreach (e; data.env)
			envVars[e.name] = e.value;
		for (int i = 0; i < data.procNr; ++i)
			processes[i] = new process(i);
		if (data.autoStart)
			start();
	}

	void	start()
	{
		foreach (process; processes)
			process.start();
	}
}

job[string] jobs;
import std.process;
import std.stdio;
import std.conv;
import std.typecons;
import std.datetime;

extern (C) ushort umask(ushort umask);

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
	byte			normalExitCode;
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
		Pid			processID;
		int			procNr;
		int			restartTimes;
		StopWatch	uptime;
		StopWatch	stopTimer;
		Status		status = Status.stopped;
		File		stdout;
		File		stdin;

		enum	Status
		{
			starting,
			alive,
			stopping,
			stopped,
			unexpectedStop
		}

		this(int procNrIn)
		{
			procNr = procNrIn;
			restartTimes = data.restartTimes;
		}

		void	start(bool restart = false)
		{
			if (!restart)
			{
				restartTimes = data.restartTimes;
				writeln("Starting...");
			}
			else
			{
				--restartTimes;
				writeln("Restarting...");
			}
			status = Status.starting;
			stdout = File(data.dir ~ to!string(procNr) ~ "_" ~ data.stdout, "a");
			stderr = File(data.dir ~ to!string(procNr) ~ "_" ~ data.stderr, "a");
			umask(umaskVal);
			processID = spawnShell("exec " ~ data.cmd, std.stdio.stdin, stdout,
			stderr, envVars, Config.none, data.dir, nativeShell);
			uptime.reset();
			uptime.start();
		}

		void	stop()
		{
			status = Status.stopping;
			writeln("Stopping...");
			std.process.kill(processID, data.stopSig);
			stopTimer.start;
		}

		void	kill()
		{
			status = Status.stopping;
			writeln("Killing...");
			std.process.kill(processID);
		}

		bool	isAlive()
		{
			return (!tryWait(processID).terminated);
		}

		int		exitCode()
		{
			return (tryWait(processID).status);
		}

		void	watchdog()
		{
			if (status == Status.starting && uptime.peek.seconds >= data.startTime)
			{
				if (isAlive)
				{
					writeln("Successfully started");
					status = Status.alive;
				}
				else
				{
					writeln("Failed to start: Exited too soon.");
					status = Status.unexpectedStop;
				}
			}

			else if (status == Status.stopping)
			{
				if (isAlive && stopTimer.peek.seconds >= data.stopTime)
				{
					writeln("Didn't stop in time.");
					stopTimer.stop();
					stopTimer.reset();
					kill();
				}
				else if (!isAlive)
				{
					writeln("Successfully stopped.");
					stopTimer.stop();
					stopTimer.reset();
					status = Status.stopped;
				}
			}

			else if (status == Status.alive && !isAlive)
			{
				uptime.stop();
				if (exitCode == data.normalExitCode)
				{
					writeln("Process stopped...");
					status = Status.stopped;
				}
				else
				{
					writeln("Unexpected stop!");
					status = Status.unexpectedStop;
				}
			}

			else if (status == Status.stopped && data.restart == 2 && restartTimes)
			{
				start(true);
			}

			else if (status == Status.unexpectedStop && data.restart >= 1 && restartTimes)
			{
				start(true);
			}
		}
	}

	jobDataStr		data;
	ushort			umaskVal;
	process[]		processes;
	string[string]	envVars;

	this(jobDataStr dataIn)
	{
		data = dataIn;
		processes.length = data.procNr;
		umaskVal = parse!ushort(data.umask, 8);

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

	void	stop()
	{
		foreach (process; processes)
			process.stop();
	}

	int		aliveCount()
	{
		int count = 0;
		foreach (process; processes)
			count += (process.status == process.Status.alive);
		return (count);
	}

	void	watchdog()
	{
		foreach (process; processes)
			process.watchdog;
	}
}

job[string] jobs;
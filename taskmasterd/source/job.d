import	std.process;
import	std.stdio;
import	std.conv;
import	std.typecons;
import	std.datetime;
import	std.exception;

import	logging;

extern (C) ushort umask(ushort umask);

struct envVar
{
	string	name;
	string	value;
}

struct jobDataStr
{
	string			name;
	string			filename;

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
		jobLog		log;

		enum	Status
		{
			starting,
			alive,
			stopping,
			stopped,
			goodStop,
			badStop
		}

		this(int procNrIn)
		{
			procNr = procNrIn;
			restartTimes = data.restartTimes;
			log = new jobLog(data.name, procNr);
		}

		void	start(bool restart = false)
		{
			if (!restart)
			{
				restartTimes = data.restartTimes;
				log.message("Starting.");
			}
			else
			{
				--restartTimes;
				log.message("Restarting.");
			}
			status = Status.starting;
			try
				stdout = File(data.dir ~ "/" ~ to!string(procNr) ~ "_" ~ data.stdout, "a");
			catch (ErrnoException e)
			{
				log.error("Failed to open stdout file: " ~ e.msg);
				return ;
			}
			try
				stderr = File(data.dir ~ "/" ~ to!string(procNr) ~ "_" ~ data.stderr, "a");
			catch (ErrnoException e)
			{
				log.error("Failed to open stderr file: " ~ e.msg);
				return ;
			}
			umask(umaskVal);
			try
				processID = spawnShell("exec " ~ data.cmd, std.stdio.stdin,
				stdout, stderr, envVars, Config.none, data.dir, nativeShell);
			catch (ProcessException e)
			{
				log.error("Failed to spawn process: " ~ e.msg);
				return ;
			}
			uptime.reset();
			uptime.start();
		}

		void	stop()
		{
			status = Status.stopping;
			log.message("Stopping.");
			try
				std.process.kill(processID, data.stopSig);
			catch (ProcessException e)
			{
				log.error("Failed to stop process: " ~ e.msg);
				log.message("Attempting to kill process: " ~ e.msg);
				kill();
				return ;
			}
			stopTimer.start;
		}

		void	kill()
		{
			status = Status.stopping;
			log.message("Killing.");
			try
				std.process.kill(processID);
			catch (ProcessException e)
				log.error("Failed to kill process: " ~ e.msg);
		}

		bool	isAlive()
		{
			try
				return (!tryWait(processID).terminated);
			catch (ProcessException e)
				log.error("Failed to get process status: " ~ e.msg);
			return (false);
		}

		bool	stopped()
		{
			switch (status)
			{
				case Status.stopped:
				case Status.goodStop:
				case Status.badStop:
					return (true);
					break;
				default:
					return (false);
					break;
			}
		}

		int		exitCode()
		{
			try
				return (tryWait(processID).status);
			catch (ProcessException e)
				log.error("Failed to get process exit code: " ~ e.msg);
			return (-1);
		}

		void	watchdog()
		{
			if (status == Status.starting && uptime.peek.seconds >= data.startTime)
			{
				if (isAlive)
				{
					log.message("Successfully started.");
					status = Status.alive;
				}
				else
				{
					log.error("Failed to start: Exited too soon.");
					status = Status.badStop;
				}
			}

			else if (status == Status.stopping)
			{
				if (isAlive && stopTimer.peek.seconds >= data.stopTime)
				{
					log.error("Failed to stop: Didn't stop in time.");
					stopTimer.stop();
					stopTimer.reset();
					kill();
				}
				else if (!isAlive)
				{
					log.message("Successfully stopped.");
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
					log.message("Process stopped.");
					status = Status.goodStop;
				}
				else
				{
					log.error("Process stopped unexpectedly!");
					status = Status.badStop;
				}
			}

			else if (status == Status.goodStop && data.restart == 2 && restartTimes != 0)
			{
				start(true);
			}

			else if (status == Status.badStop && data.restart >= 1 && restartTimes != 0)
			{
				start(true);
			}
		}
	}

	jobDataStr		data;
	ushort			umaskVal;
	process[]		processes;
	string[string]	envVars;
	bool			running;

	this(jobDataStr dataIn)
	{
		data = dataIn;
		processes.length = data.procNr;
		umaskVal = to!ushort(data.umask, 8);

		foreach (e; data.env)
			envVars[e.name] = e.value;
		for (int i = 0; i < data.procNr; ++i)
			processes[i] = new process(i);
		logMessage("Job loaded.");
		if (data.autoStart)
			start();
	}

	void	start()
	{
		running = true;
		foreach (process; processes)
			if (process.stopped)
				process.start();
	}

	void	stop()
	{
		running = false;
		foreach (process; processes)
			if (!process.stopped)
				process.stop();
	}

	void	kill()
	{
		running = false;
		foreach (process; processes)
			if (!process.stopped)
				process.kill();
	}

	void	repair()
	{
		foreach (process; processes)
			process.restartTimes = data.restartTimes + 1;
	}

	int		aliveCount()
	{
		int count = 0;
		foreach (process; processes)
			count += (process.status == process.Status.alive);
		return (count);
	}

	int		stoppedCount()
	{
		int count = 0;
		foreach (process; processes)
			count += (process.stopped());
		return (count);
	}

	void	watchdog()
	{
		foreach (process; processes)
			process.watchdog;
	}

	void	logMessage(string m)
	{
		foreach (p; processes)
			p.log.message(m);
	}
}

job[string] jobs;
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
import	std.string;
import	core.runtime;
import	std.stdio;

import	config;
import	global;
import	parse;
import	job;
import	logging;
import	tcp;

extern(C) void signal(int sig, void function(int));

extern(C) void handle(int sig)
{
	tmdLog.message("Received SIGHUP. Restarting.");
	parseDir();
}

void main()
{
	if (Runtime.args.length == 2)
		configFile = Runtime.args[1];
	signal(1, &handle);
	config.readFile();
	tmdLog.init();
	tmdLog.print("Taskmasterd started.");
	parseDir();
	tcp.init();
	while (1)
	{
		//	Monitor TCP events.
		tcp.process();
		//	Tend to processes.
		foreach(j; jobs)
			j.watchdog();
	}
}

import	std.string;
import	core.runtime;
import	std.stdio;

import	config;
import	global;
import	parse;
import	job;
import	logging;
import	tcp;

void main()
{
	if (Runtime.args.length == 2)
		configFile = Runtime.args[1];
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

import	std.stdio;
import	std.socket;
import	std.conv;
import	std.string;
import	core.runtime;
import	std.process;

import	config;
import	global;
import	parse;
import	jobs;
import	logging;

void main()
{
//	File	log = File("./log/taskmasterd_2017-12-23_20:13:17.log", "a");
	if (Runtime.args.length == 2)
		configFile = Runtime.args[1];
	if (environment.get("TERM").toLower.indexOf("color") != -1)
		colorTerm = true;
	config.readFile();
	tmdLog.init();
	tmdLog.print("Taskmasterd started.");
	parseDir();
	Socket server = new TcpSocket();
	server.setOption(SocketOptionLevel.SOCKET, SocketOption.REUSEADDR, true);
	if (globals.remoteConnections)
		server.bind(new InternetAddress(globals.port));
	else
		server.bind(new InternetAddress("127.0.0.1", globals.port));
	server.listen(1);
	server.blocking(0);
	Socket client;
	char[1024] buffer;
	while(true)
	{
		if (client is null || !client.isAlive)
			try
			{
				client = server.accept();
				client.blocking(0);
				tmdLog.net("Client \"" ~ client.hostName ~ "\" connected on port " ~ to!string(globals.port) ~ ".");
			}
			catch (SocketAcceptException e){}
		else
		{
			auto received = client.receive(buffer);
			if (received == 0)
			{
				tmdLog.net("Client \"" ~ client.hostName ~ "\" disconnected.");
				client.shutdown(SocketShutdown.BOTH);
				client.close();
			}
			else if (received > 0)
				//Do something with incoming command.
				write(buffer[0.. received]);
		}
		//	Watchdog
		foreach(job; jobs.jobs)
			job.watchdog();
	}
}

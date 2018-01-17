import	std.socket;
import	std.conv;
import	std.string;
import	std.base64;
import	std.stdio;
import	std.file;

import	global;
import	logging;
import	job;
import	jsonx;
import	parse;

Socket		server;

struct	Query
{
	string	cmd;
	string	job;
	string	data;
}

struct	Response
{
	string	response;
	string	error;
	string	data;
}

void init()
{
	server = new TcpSocket();
	server.setOption(SocketOptionLevel.SOCKET, SocketOption.REUSEADDR, true);
	if (globals.remoteConnections)
		server.bind(new InternetAddress(globals.port));
	else
		server.bind(new InternetAddress("127.0.0.1", globals.port));
	server.listen(1);
	server.blocking(0);
}

void	process()
{
	static string		temp;
	static char[1024]	buffer;
	static Socket		client;
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
			temp = "";
			client.shutdown(SocketShutdown.BOTH);
			client.close();
		}
		else if (received > 0)
		{
			temp ~= buffer[0 .. received].replace("\n", "").replace("\r","");
			if (temp.endsWith(";;"))
			{
				string result = parseCommand(temp.chomp(";;")) ~ ";;";
				client.send(result);
				temp = "";
			}
		}
	}
}

private	string	parseCommand(string m)
{
	Response response;

	try
	{
		Query query = jsonDecode!Query(m);
		char[]	job = cast(char[])Base64.decode(query.job);
		char[]	data = cast(char[])Base64.decode(query.data);
		try
		{
			if (job != "" && job !in jobs && query.cmd != "push")
			{
				tmdLog.error("Job \"" ~ to!string(job) ~ "\" does not exist.");
				response.response = "fail";
				response.error = Base64.encode(cast(ubyte[])("Job \"" ~ (job) ~ "\" does not exist."));
			}
			else
				switch (query.cmd)
				{
					case "start":
						tmdLog.net("Received start command for job \"" ~ to!string(job) ~ "\".");
						if (!jobs[job].running)
						{
							jobs[job].start();
							response.response = "success";
						}
						else
						{
							tmdLog.net("\"" ~ to!string(job) ~ "\" already running.");
							response.response = "redundant";
						}
						break;
					case "stop":
						tmdLog.net("Received stop command for job \"" ~ to!string(job) ~ "\".");
						if (jobs[job].running)
						{
							jobs[job].stop();
							response.response = "success";
						}
						else
						{
							tmdLog.net("\"" ~ to!string(job) ~ "\" already stopped.");
							response.response = "redundant";
						}
						break;
					case "kill":
						tmdLog.net("Received kill command for job \"" ~ to!string(job) ~ "\".");
						if (jobs[job].running)
						{
							jobs[job].kill();
							response.response = "success";
						}
						else
						{
							tmdLog.net("\"" ~ to!string(job) ~ "\" already stopped.");
							response.response = "redundant";
						}
						break;
					case "repair":
						tmdLog.net("Received repair command for job \"" ~ to!string(job) ~ "\".");
						if (jobs[job].running)
						{
							jobs[job].repair();
							response.response = "success";
						}
						else
						{
							response.response = "fail";
							response.error = Base64.encode(cast(ubyte[])("\"" ~ to!string(job) ~ "\" not running."));
							tmdLog.net("\"" ~ to!string(job) ~ "\" not running.");
						}
						break;
					case "status":
						tmdLog.net("Received status query for job \"" ~ to!string(job) ~ "\".");
						response.response = "status";
						if (jobs[job].running)
							response.data = Base64.encode(cast(ubyte[])("\"" ~ job ~ "\"" ~ " running. " ~
							to!string(jobs[job].aliveCount) ~ " of " ~ to!string(jobs[job].data.procNr) ~ " processes alive."));
						else
							response.data = Base64.encode(cast(ubyte[])("\"" ~ job ~ "\"" ~ " not running. "));
						break;
					case "pull":
						tmdLog.net("Received pull query for job \"" ~ to!string(job) ~ "\".");
						response.response = "file";
						response.data = Base64.encode(cast(ubyte[])readText(jobs[job].data.filename));
						break;
					case "push":
						tmdLog.net(to!string("Receiving job \"" ~ job ~ ".tm.json\"."));
						response.response = "success";
						File file = File(globals.configDirectory ~ "/" ~ job ~ ".tm.json", "w");
						file.write(data);
						file.flush();
						parseFile(to!string(globals.configDirectory ~ "/" ~ job ~ ".tm.json"));
						break;
					case "delete":
						tmdLog.net("Received delete command for job \"" ~ to!string(job) ~ "\".");
						response.response = "success";
						jobs[job].stop();
						while (jobs[job].stoppedCount < jobs[job].data.procNr)
							jobs[job].watchdog();
						remove(jobs[job].data.filename);
						jobs.remove(to!string(job));
						break;
					case "list":
						string	temp;
						tmdLog.net("Received list query.");
						temp ~= "{\"processes\":[";
						foreach (j; jobs)
							temp ~= ("{\"name\":\"" ~ j.data.name ~ "\"},");
						temp = temp.chop;
						temp ~= "]}";
						response.response = "list";
						response.data = Base64.encode(cast(ubyte[])temp);
						break;
					case "reload":
						tmdLog.net("Received reload command for job \"" ~ to!string(job) ~ "\".");
						parseFile(jobs[job].data.filename);
						response.response = "success";
						break;
					case "restart":
						tmdLog.net("Received restart command.");
						parseDir();
						response.response = "success";
						break;
					default:
						response.response = "invalid";
						tmdLog.net("Invalid query: \"" ~ m ~ "\"");
						break;
				}
		}
		catch (Throwable)
		{
			tmdLog.error("Unknown error. Please restart taskmasterd.");
			response.response = "fail";
			response.error = Base64.encode(cast(ubyte[])"Unknown error. Please restart taskmasterd.");
		}
	}
	catch (Throwable)
	{
		tmdLog.net("Invalid query: \"" ~ m ~ "\"");
		response.response = "invalid";
	}

	return (jsonEncode(response));
}

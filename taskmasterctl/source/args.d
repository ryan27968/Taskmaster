import	std.string;
import	std.conv;
import	std.getopt;
import	std.algorithm.searching;
import	std.algorithm.mutation;
import	std.stdio;

import	global;
import	error;
import	cmd;

string[]	parseArgs(string[] args)
{
	string		connection;
	string[]	temp;
	int			tempPort;

	//	Parse arguments.
	try
		getopt(args,
			std.getopt.config.passThrough,
			std.getopt.config.bundling,
			"c", &connection,
			"s|shell", &global.shellMode);
	catch (Throwable)
		fatalErr("Invalid arguments.");

	//	Remove program name argument.
	remove(args, 0);
	--args.length;

	//	Check if connection specified.
	if (connection != "")
	{
		//	Check if port specified. If not, just use default.
		if (indexOf(connection, ":") == -1)
			server = connection;
		else
		{
			temp = split(connection, ":");
			if (temp.length != 2 || !temp[0].length || !temp[1].length)
				fatalErr("Invalid connection syntax.\nPlease use: \"hostname:port\"" ~
				"if you want to specify the port, otherwise use \"hostname\".");
			server = temp[0];
			try
				tempPort = to!int(temp[1]);
			catch (Throwable)
				fatalErr("Invalid port: \"" ~ temp[1] ~ "\".\nPlease use a valid port number.");
			if (tempPort < 1 || tempPort > 65535)
				fatalErr("Invalid port: \"" ~ temp[1] ~ "\".\nPlease use a valid port number.");
			port = cast(ushort)tempPort;
		}

		//	Verify hostname/IP is valid.
		if (startsWith(server, "-") || endsWith(server, "-"))
			fatalErr("Invalid server: \"" ~ server ~
			"\".\nHostnames/IP Adresses cannot begin or end with hyphens.");
	}
	return (args);
}
import	std.base64;
import	std.algorithm.searching;
import	std.string;
import	std.file;
import	std.stdio;
import	std.utf;

import	error;
import	tcp;
import	jsonx;
import	global;

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

struct	Process
{
	string	name;
}

struct	List
{
	Process[] processes;
}

void	executeCmd(string[] cmd)
{
	Query		query;
	Response	response;
	List		list;

	try
	{
		cmd[0] = cmd[0].toLower;
		switch (cmd[0])
		{
			case "start":
				if (cmd.length != 2)
					err("Invalid command.");
				query.cmd = "start";
				query.job = Base64.encode(cast(ubyte[])cmd[1]);
				break;
			case "stop":
				if (cmd.length != 2)
					err("Invalid command.");
				query.cmd = "stop";
				query.job = Base64.encode(cast(ubyte[])cmd[1]);
				break;
			case "kill":
				if (cmd.length != 2)
					err("Invalid command.");
				query.cmd = "kill";
				query.job = Base64.encode(cast(ubyte[])cmd[1]);
				break;
			case "repair":
				if (cmd.length != 2)
					err("Invalid command.");
				query.cmd = "repair";
				query.job = Base64.encode(cast(ubyte[])cmd[1]);
				break;
			case "status":
				if (cmd.length != 2)
					err("Invalid command.");
				query.cmd = "status";
				query.job = Base64.encode(cast(ubyte[])cmd[1]);
				break;
			case "pull":
				if (cmd.length != 2)
					err("Invalid command.");
				query.cmd = "pull";
				query.job = Base64.encode(cast(ubyte[])cmd[1]);
				break;
			case "push":
				if (cmd.length != 2)
					err("Invalid command.");
				query.cmd = "push";
				if (!cmd[1].endsWith(".tm.json"))
					err("Invalid file.\nTaskmasterd config files must end with \".tm.json\"");
				query.job = Base64.encode(cast(ubyte[])chomp(cmd[1], ".tm.json"));
				query.data = Base64.encode(cast(ubyte[])readText(cmd[1]));
				break;
			case "delete":
				if (cmd.length != 2)
					err("Invalid command.");
				query.cmd = "delete";
				query.job = Base64.encode(cast(ubyte[])cmd[1]);
				break;
			case "list":
				if (cmd.length != 1)
					err("Invalid command.");
				query.cmd = "list";
				break;
			case "reload":
				if (cmd.length != 2)
					err("Invalid command.");
				query.cmd = "reload";
				query.job = Base64.encode(cast(ubyte[])cmd[1]);
				break;
			case "restart":
				if (cmd.length != 1)
					err("Invalid command.");
				query.cmd = "restart";
				break;
			case "exit":
				if (shellMode)
					stop();
				break;
			default:
				err("Invalid command.");
				break;
		}
		response = jsonDecode!Response(tcp.query(jsonEncode(query)));
		switch (response.response)
		{
			case "success":
				writeln("Success!");
				break;
			case "fail":
				err("Error: " ~ cast(string)Base64.decode(response.error));
				break;
			case "invalid":
				err("Invalid command.");
				break;
			case "status":
				writeln(cast(string)Base64.decode(response.data));
				break;
			case "redundant":
				final switch (cmd[0])
				{
					case "start":
						err("Already running.");
						break;
					case "stop":
					case "kill":
						err("Already stopped.");
						break;
				}
				break;
			case "file":
				writeln(cast(string)Base64.decode(response.data));
				break;
			case "list":
				list = jsonDecode!List(cast(string)Base64.decode(response.data));
				foreach(p; list.processes)
					writeln(p.name);
				break;
			default:
				err("Unknown response.");
		}
	}
	catch (Base64Exception)
		writeln("B64 error!");
	catch (FileException)
		writeln("File read error!");
	catch (UTFException)
		writeln("File encoding error!");
	catch (JsonException)
		writeln("Json error!");
	catch (ErrException e)
		writeln(e.msg);
}

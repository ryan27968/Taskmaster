import	std.stdio;

import	args;
import	global;
import	tcp;
import	cmd;
import	error;
import	shell;

void main(string[] args)
{
	//	Parse arguments.
	args = parseArgs(args);

	//	Try to establish connection.
	tcp.init();

	//	If in shell mode, open shell. Otherwise run command.
	if (shellMode)
		shell.shell();
	else if (args.length)
		executeCmd(args);
	else
		fatalErr("No command?!");
}

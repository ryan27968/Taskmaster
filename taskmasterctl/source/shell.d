import	std.stdio;
import	std.string;

import	cmd;
import	global;
import	error;

void	shell()
{
	string	input;

	while (true)
	{
		write(server, " >>> ");
		input = readln().strip();
		if (std.stdio.stdin.eof)
			stop();
		else if (input != "")
			executeCmd(input.split);
	}
}
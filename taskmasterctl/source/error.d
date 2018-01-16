import	core.stdc.stdlib;
import	std.stdio;

import	global;

class ErrException : Exception
{
    this(string msg, string file = __FILE__, size_t line = __LINE__) {
        super(msg, file, line);
    }
}

void		err(string msg)
{
	if (shellMode)
		throw new ErrException(msg);
	else
		fatalErr(msg);
}

void		fatalErr(string msg)
{
	if (msg != "")
		writeln(msg);
	exit(EXIT_FAILURE);
}

void		stop()
{
	exit(EXIT_SUCCESS);
}
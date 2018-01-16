import	std.socket;
import	std.string;

import	global;
import	error;

Socket	connection;
Address[]	addresses;

void	init()
{
	try
		addresses = getAddress(server, port);
	catch (Throwable)
		err("Can't find server:\"" ~ server ~ "\".");
	try
		connection = new TcpSocket(addresses[0]);
	catch (Throwable)
		err("Could not connect to server.\nConnection timed out.");
}

string	query(string query)
{
	string		temp;
	char[1024]	buffer;

	//	Send query
	connection.blocking(1);
	connection.send(query ~ ";;");
	
	//	Receive response
	connection.blocking(0);
	while (1)
	{
		auto received = connection.receive(buffer);
		if (received == 0)
		{
			connection.shutdown(SocketShutdown.BOTH);
			connection.close();
			err("Connection to server lost.");
		}
		else if (received > 0)
		{
			temp ~= buffer[0 .. received].replace("\n", "").replace("\r","");
			if (temp.endsWith(";;"))
				return (temp.chomp(";;"));
		}
	}
}
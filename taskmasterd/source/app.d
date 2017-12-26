import std.stdio;
import std.socket;
import core.runtime;

import config;
import global;
import parse;
import jsonx;

void main()
{
	if (Runtime.args.length == 2)
		configFile = Runtime.args[1];
	readFile();
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
	while(true) {
		if (client is null || !client.isAlive)
			try
				client = server.accept();
			catch (SocketAcceptException e){}
		else
		{
			auto received = client.receive(buffer);
			if (received == 0)
			{
				client.shutdown(SocketShutdown.BOTH);
				client.close();
			}
			else
				//Do something with incoming command.
				write(buffer[0.. received]);
		}
		//Do continuous stuff.
	}
}

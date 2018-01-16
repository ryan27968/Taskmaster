##	How do I use Taskmasterctl?
Taskmasterctl can be used in two modes. It has a single query mode, and a shell mode. The default mode is single query mode. In single query mode, you will give it the query you want to run as arguments. In shell mode, it will give you an interactive shell that will allow you to type queries one after another.

#	What are the command line arguments?
 - `"-c"` to specify server and (optionally) port. Use like so: `"-c hostname:port"` or just `"-c hostname"`.
 - `"-s" or "--shell"` to use shell mode.

#	Where is the list of queries?
The valid queries are all listed in the [TCP communication](../doc/Network.md) readme.

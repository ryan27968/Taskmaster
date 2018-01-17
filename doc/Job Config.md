#	How can I configure a job for Taskmasterd?

Jobs for taskmasterd are configured using a job.tm.json file (where "job" is the name of the job).

Here is an example of a job config file:

```json
{
	"cmd": "printenv",	// The command to run.
	"procNr": 1,		// How many instances of the process to start.
	"autoStart": true,	// Whether to automatically start the process when taskmasterd is started.
	"restart": 1,		// Whether to restart the process always(2), only on unexpected exits(1), or never(0).
	"startTime": 1,		// How long it should take to start the process.
	"normalExitSig": 0,	// Normal exit signal to expect when the process ends.
	"restartTimes": 0,	// How many times to restart the process.
	"stopSig": 15,		// The signal to send to "gracefully" exit the program.
	"stopTime": 1,		// How long to wait for a process to end gracefully before killing it.
	"stdout": "o.txt",	// Which file to redirect stdout from the program to.
	"stderr": "e.txt",	// Which file to redirect stderr from the program to.
	"env":				// List of environment variables to pass to the process.
	[
		{
		"name": "FOO",	// Name of the environment variable you want to set.
		"value": "bar"	// Value to set the environment variable to.
		}
	],
	"dir": "./test/",	// Working directory to run the process within.
	"umask": "0111"		// Umask to set for the process.
}
```
**Note: Although comments are not strictly allowed in json, the jsonx parser I am using(courtesy of Gian Merlino) does accept comments delimited by "//".**

For a preconfigured taskmasterd installation example, check out the examples directory.
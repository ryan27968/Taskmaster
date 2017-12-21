#	How can I configure a job for Taskmasterd?

Jobs for taskmasterd are configured using a job.tm.json file (where "job" is the name of the job).

The applicable json fields are as follows:

 - "cmd" 			# The command used to start the program.
 - "procNr"			# The amount of processes to start/monitor.
 - "autoStart"		# Whether or not to automatically start the job when Taskmasterd is launched.
 - "restart"		# Whether to restart the program always, never, or only on unexpected exits.
 - "normalExitSig"	# The "normal" exit signal to expect from the program.
 - "restartTimes"	# How many times to restart a program before aborting.
 - "stopSig"		# The signal to use to gracefully stop the program.
 - "stopTime"		# The timeout between attempting to stop and killing a program.
 - "stdout"			# The file to redirect stdout to.
 - "stderr"			# The file to redirect stderr to.
 - "env"			# List of environment variables to set before running the program.
 - "dir"			# The working directory to launch the program in.
 - "umask"			# The umask to set for the program.
#	How do the programs communicate?
Taskmasterctl and Taskmasterd communicate over a simple TCP socket.
The communication language is simple json.

##	Commands
The valid commands and their required extra fields are:

 - `"start"`	<`"job"`>			# Start a job.
 - `"stop"`		<`"job"`>			# Stop a job.
 - `"kill"`		<`"job"`>			# Kill a job.
 - `"repair"`	<`"job"`>			# Repair a job (Reset to default state non-destructively).
 - `"status"`	<`"job"`>			# Get status of a job.
 - `"pull"`		<`"job"`>			# Download a job.tm.json file from taskmasterd.
 - `"push"`		<`"job"`, `"data"`>	# Send a job.tm.json file to taskmasterd.
 - `"delete"`	<`"job"`>			# Delete a job.
 - `"list"`							# List all jobs.
 - `"reload"`	<`"job"`>			# Reload a job.
 - `"restart"`						# Reload all jobs

In the case of most commands, they will need one or two extra fields.
For example, when killing a job you will need an extra "job" field in the json query so that taskmasterd knows which job to kill.
When pushing a job, you will need an extra "data" field containing the contents of the file you are pushing.
**Note: The `"job"` and `"data"` fields will always be base64 encoded.**

A query might look something like this:
```json
{
	"command" : "kill",
	"job" : "bmdpbng="
};;
```
Where `"bmdpbng="` is _"nginx"_ in b64.

A push would look something like so:
```json
{
	"command" : "push",
	"job" : "<b64-encoded job name>",
	"data" : "<b64-encoded file>"
};;
```

**Note: Although whitespace is shown in these examples, the actual transmitted data shouldn't have any whitespace.**

##	Responses
The responses will be transmitted in a similar manner. The valid responses and their required extra fields are:
 - `"success"`					# Command successful.
 - `"fail"`			<`"error"`>	# Command failed.
 - `"invalid"`					# Invalid command.
 - `"status"`		<`"data"`>	# Returning the status of a job.
 - `"redundant"`				# Redundant command (eg. attempting to start a job already running).
 - `"file"`			<`"data"`>	# Responding (to a pull query) with a job file.
 - `"list"`			<`"data"`>	# Responding (to a list query) with a json string containing list of job names.

**Note: Just as with commands, the `"error"`, and `"data"` fields will always be base64 encoded.**

A response might look something like this:
```json
{
	"response" : "fail",
	"error" : "SW52YWxpZCBqb2IgbmFtZS4="
};;
```
Where `"SW52YWxpZCBqb2IgbmFtZS4="` means _"Invalid job name."_.

A file would look something like this:
```json
{
	"response" : "file",
	"job" : "<b64-encoded job name>",
	"data" : "<b64-encoded file>"
};;
```

And a list would look like so:
```json
{
	"response" : "list",
	"list" : "<b64-encoded json list>"
};;
```

The json list itself would look something like:
```json
{
	"jobs":
	[
		{"name" : "nginx"},
		{"name" : "apache2"}
	]
};;
```

**Note: Just as with commands, the transmitted data shouldn't have any whitespace.**

##	Connection
The connection by default runs over port `7777` and only accepts connections from `localhost`, although these can both be configured. There is no authentication nor encryption so using this over a network for anything but testing is not recommended. All queries/responses end in ";;" to indicate the end of transmission.

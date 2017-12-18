# How do the programs communicate?
Taskmasterctl and Taskmasterd communicate over a simple TCP socket.
The communication protocol is simple json.

## Commands
The valid commands and their required extra fields are:

 - `"start"`	<`"job"`>			# Start a job 
 - `"kill"`		<`"job"`>			# Kill a job 
 - `"status"`	<`"job"`>			# Get status of a job 
 - `"pull"`		<`"job"`>			# Download a job.json file from taskmasterd. 
 - `"push"`		<`"job"`, `"data"`>	# Send a job.json file to taskmasterd. 
 - `"delete"`	<`"job"`>			# Delete a job 
 - `"list"`							# List all jobs
 - `"reload"`	<`"job"`>			# Reload a job 
 - `"restart"`						# Reload all jobs

In the case of some commands, they will need one or more extra fields.
For example, when killing a job you will need an extra "job" field in the json query so that taskmasterd knows which job to kill.
When pushing a job, you will need an extra "data" field containing the contents of the file you are pushing.
**Note: The `"job"` and `"data"` fields will always be base64 encoded.**

A query might look something like this:
`{
	"command" : "kill",
	"job" : "bmdpbng="
}`
Where `"bmdpbng="` is _"nginx"_ in b64.

A push would look something like so:
`{
	"command" : "push",
	"job" : "<b64-encoded job name>",
	"data" : "<b64-encoded file>"
}`

**Note: Although whitespace is shown in these examples, the actual transmitted data shouldn't have any whitespace.**

## Responses
The responses will be transmitted in a similar manner. The valid responses and their required extra fields are:
 - `"success"`							# Command successful.
 - `"fail"`			<`"error"`>			# Command failed.
 - `"invalid"`							# Invalid command.
 - `"redundant"`						# Redundant command (eg. attempting to start a job already started).
 - `"file"`			<`"job"`, `"data"`>	# Responding (to a pull query) with a job file.
 - `"list"`			<`"list"`>			# Responding (to a list query) with a json string containing list of job names.

**Note: Just as with commands, the `"error"`, `"job"`,  `"data"`, and `"list"` fields will always be base64 encoded.**

A response might look something like this:
`{
	"response" : "fail",
	"error" : "SW52YWxpZCBqb2IgbmFtZS4="
}`
Where `"SW52YWxpZCBqb2IgbmFtZS4="` means _"Invalid job name."_.

A file would look something like this:
`{
	"response" : "file",
	"job" : "<b64-encoded job name>",
	"data" : "<b64-encoded file>"
}`

And a list would look like so:
`{
	"response" : "list",
	"list" : "<b64-encoded json list>"
}`

The json list itself would look something like:
`{
	"jobs":
	[
		{"name" : "nginx"},
		{"name" : "apache2"}
	]
}`

**Note: Just as with commands, the transmitted data shouldn't have any whitespace.**

## Connection
The connection by default runs over port `7777` and only accepts connections from `localhost`, although these can both be configured. There is no authentication nor encryption so using this over a network for anything but testing is not recommended. 

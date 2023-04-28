The CLI Tool will be a single executable binary for a command line interface.
The CLI Tool will be invokable as `cliTool <command> <parameters>`\nThe CLI tool will offer two commands:
	- `create` (`cliTool create <parameters>`)
	- `build` (`cliTool create <parameters>`)

## Commands
### `create` command requirements:

#### Arguments
The  Create command should take two arguments:
	- a relative or absolute path to an output directory (optional, defaults to current directory)
	- The path to a json file following the CREATE json template

#### Interface
The Create command will be invokable as `cliTool create -d <output-directory> -p <path-to-json>`

#### Behaviour
If the output directory or path does not exist, the CLI Tool will create the required directories.
The create command will format the content of the json file into a json following the CREATE OUTPUT json template, mapping the initial json file accordingly.
The create command will then output the content of the newly created json file in a `openai-messages-payload.json` file in the output directory.
Using a POST request, the create command will then send the content content of the `openai-messages-payload.json` file to the `https:\/\/webhook.site\/a9337690-8c51-4051-8fd6-03bd90ba30fc`.

### `build` command requirements:

#### Arguments:
The Build command should take two arguments:
	- a relative or absolute path to an output directory (optional, defaults to current directory)
	- The path to a json file following the BUILD json template.

#### Interface
The Build command will be invokable as `cliTool build -d <output-directory>(optional) -p <path-to-json>`

#### Behaviour
If the output directory or path does not exist, the CLI Tool will create the required directories.
The build command  will create the files listed in the json file, in the designated output directory.
The build commandl will write each file's content in the appropriate file.

The build command will create the directories listed in the json file, in the designated output directory.

After creating all the files and directories, and from the output path, the build command will run the scripts in the order they are listed in the JSON file.

The CLI Tool will catch and log all the errors encountered at runtime, in an `errors.json` file located in the directory the CLI Tool is invoked from (`.\/`)
The CLI Tool will send the encountered errors, as a JSON following the ERROR JSON template, to the backend, via a POST Request to `https:\/\/webhook.site\/a9337690-8c51-4051-8fd6-03bd90ba30fc`.

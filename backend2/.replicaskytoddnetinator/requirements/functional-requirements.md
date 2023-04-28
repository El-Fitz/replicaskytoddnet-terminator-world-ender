# Project Name: QuirkyServerlessCodeGenie
The serverless backend for a software engineer tool. It takes a form describing a project and it's functional and technical requirements (such as the programming language, the technical environment, the architecture and the overall technical stack) as an input, and uses the provided answers to fill in the gaps using the OpenAPI GPT API.

It offers multiple endpoints and is secured using an API key.

## `projects` endpoint
- `POST`: Creates the project on the backend side, generating a unique id (ULID) for the project.It takes an optional json form as a parameter. If the form is provided, It also returns a json form with questions.
- `form` endpoints: For a given project, it returns a form with questions.

### The form:
- key: projectName
  question: "What is your project's name?"
  info: "(e.g. MyProject) Leave empty if you want us to generate one for you"
	required: false
	error: error info (or nil if no error)
- key: functionalDescription
  question: "What is your project's functional description?"
  info: "(e.g. A mobile app that allows users to create and share recipes)"
	required: true
	error: error info (or nil if no error)
- key: environment
  question: "What will be your project's technical environment?"
  info: "(e.g. iOS, macOS, tvOS, watchOS, web app, serverless backend, etc.)"
  required: false
  error: error info (or nil if no error)
- key: programmingLanguagequestion: "What programming language do you want to use?"
  info: "(e.g. Swift, Objective-C, JavaScript, TypeScript, Python, Ruby, etc.)"
  required: false
  error: error info (or nil if no error)
- key: architecture
  question: "What architecture and architectural patterns do you want to use?"
  info: "(e.g. MVC, MVVM, VIPER, Clean, Hexagonal, Atomic Design components, etc.)"
  required: false
  error: error info (or nil if no error)

If the filled form is invalid, the endpoint will return an HTTP error.
If the filled form contains an invalid answer or is missing a required field, the endpoint will return the form, with the error field filled out.
If the filled form is missing an optional field, the backend will generate appropriate values for this field using the OpenAI GPT API and the provided answers as context.
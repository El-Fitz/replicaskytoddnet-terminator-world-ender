# QuirkyServerlessCodeGenie Specifications

## Introduction

These specifications are for a serverless backend for a software engineer tool called QuirkyServerlessCodeGenie. The backend will take a form describing a project and its functional and technical requirements as input and use the OpenAPI GPT API to fill in any gaps. The backend provides multiple endpoints secured with an API key.

### Technical Environment

- Serverless backend on AWS
- AWS CDK (Cloud Development Kit)
- AWS Lambda
- DynamoDB
- AWS API Gateway
- TypeScript
- Clean Architecture, Repositories pattern

## Project Functionality

### `projects` Endpoint:

- `POST`: Creates the project on the backend side, generating a unique id (ULID) for the project. It takes an optional JSON form as a parameter. If the form is provided, it also returns a JSON form with questions.

### `form` Endpoints:

- For a given project, it returns a form with questions.

#### The Form:

1. key: projectName
   - question: "What is your project's name?"
   - info: "(e.g. MyProject) Leave empty if you want us to generate one for you"
   - required: false
   - error: error info (or nil if no error)
2. key: functionalDescription
   - question: "What is your project's functional description?"
   - info: "(e.g. A mobile app that allows users to create and share recipes)"
   - required: true
   - error: error info (or nil if no error)
3. key: environment
   - question: "What will be your project's technical environment?"
   - info: "(e.g. iOS, macOS, tvOS, watchOS, web app, serverless backend, etc.)"
   - required: false
   - error: error info (or nil if no error)
4. key: programmingLanguage
   - question: "What programming language do you want to use?"
   - info: "(e.g. Swift, Objective-C, JavaScript, TypeScript, Python, Ruby, etc.)"
   - required: false
   - error: error info (or nil if no error)
5. key: architecture
   - question: "What architecture and architectural patterns do you want to use?"
   - info: "(e.g. MVC, MVVM, VIPER, Clean, Hexagonal, Atomic Design components, etc.)"
   - required: false
   - error: error info (or nil if no error)

If the filled form is invalid, the endpoint will return an HTTP error. If the filled form contains an invalid answer or is missing a required field, the endpoint will return the form, with the error field filled out. If the filled form is missing an optional field, the backend will generate appropriate values for this field using the OpenAI GPT API and the provided answers as context.

## Accessibility

The backend must ensure that the forms and endpoints are accessible to users with disabilities. This includes, but is not limited to:

- Ensuring that the questions and information provided in the forms are in clear, concise language that can be easily understood by users.
- Ensuring that error messages are descriptive and provide guidance on how to correct the issue.
- Ensuring compatibility with screen readers and other assistive technologies.

## Localization

The backend must support localization to ensure a consistent user experience across different languages and regions. This includes, but is not limited to:

- Providing translations for all form questions, information, and error messages.
- Supporting regional-specific formatting for dates, times, and other data.
- Ensuring that the backend can handle input and output in various character sets and languages.

### Technical Requirements Summary

- Develop a serverless backend on AWS with AWS CDK, AWS Lambda, DynamoDB, and AWS API Gateway.
- Implement the backend using TypeScript and Clean Architecture with the Repositories pattern.
- Provide multiple endpoints secured with an API key.
- Offer a `projects` endpoint with a `POST` method for creating a project and generating a ULID.
- Provide a `form` endpoint that returns a form with questions for a given project.
- Ensure that the backend adheres to accessibility best practices.
- Support localization for form questions, info, and error messages
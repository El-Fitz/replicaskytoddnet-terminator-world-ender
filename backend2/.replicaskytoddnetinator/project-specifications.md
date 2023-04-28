# QuirkyServerlessCodeGenie

**Project Name**: QuirkyServerlessCodeGenie

**Project Description**: The serverless backend for a software engineer tool. It takes a form describing a project and its functional and technical requirements (such as the programming language, the technical environment, the architecture, and the overall technical stack) as input, and uses the provided answers to fill in the gaps using the OpenAPI GPT API. It offers multiple endpoints and is secured using an API key.

## Technical Requirements

- Language: TypeScript
- Environment: Serverless backend on AWS, AWS CDK, AWS Lambda, DynamoDB, AWS API Gateway
- Architecture: Clean Architecture, Repositories pattern
- Frameworks and Tooling: AWS CDK, AWS Lambda, DynamoDB, AWS API Gateway

## Accessibility Requirements

- Ensure that error messages are clear, concise, and informative.
- Provide helpful descriptions and hints for each form field to guide users in filling out the form.
- Use appropriate form elements such as labels and placeholders for better accessibility.

## Localization Requirements

- Ensure that the form supports multiple languages for both input and display.
- Use a localization library or service to manage translations for form fields, error messages, and other user-facing text.

## Endpoints

### `projects` endpoint

- `POST`: Creates the project on the backend side, generating a unique id (ULID) for the project. It takes an optional JSON form as a parameter. If the form is provided, it also returns a JSON form with questions.

### `form` endpoints

- For a given project, it returns a form with questions.

#### The Form

The form should include the following fields:

- Key: projectName
  - Question: "What is your project's name?"
  - Info: "(e.g., MyProject) Leave empty if you want us to generate one for you"
  - Required: false
  - Error: error info (or nil if no error)

- Key: functionalDescription
  - Question: "What is your project's functional description?"
  - Info: "(e.g., A mobile app that allows users to create and share recipes)"
  - Required: true
  - Error: error info (or nil if no error)

- Key: environment
  - Question: "What will be your project's technical environment?"
  - Info: "(e.g., iOS, macOS, tvOS, watchOS, web app, serverless backend, etc.)"
  - Required: false
  - Error: error info (or nil if no error)

- Key: programmingLanguage
  - Question: "What programming language do you want to use?"
  - Info: "(e.g., Swift, Objective-C, JavaScript, TypeScript, Python, Ruby, etc.)"
  - Required: false
  - Error: error info (or nil if no error)

- Key: architecture
  - Question: "What architecture and architectural patterns do you want to use?"
  - Info: "(e.g., MVC, MVVM, VIPER, Clean, Hexagonal, Atomic Design components, etc.)"
  - Required: false
  - Error: error info (or nil if no error)

If the filled form is invalid, the endpoint will return an HTTP error. If the filled form contains an invalid answer or is missing a required field, the endpoint will return the form, with the error field filled out. If the filled form is missing an optional field, the backend will generate appropriate values for this field using the OpenAI GPT API and the provided answers as context.

## Technical Requirements (Reiterated)

- Implement the project using TypeScript.
- Deploy the serverless backend on AWS, utilizing AWS CDK, AWS Lambda, DynamoDB, and AWS API Gateway.
- Follow Clean Architecture and Repositories pattern for the system design.
- Utilize AWS CDK, AWS Lambda, DynamoDB, and AWS API Gateway for frameworks and tooling.

## Accessibility Best Practices

- Ensure that all form elements have proper labels and use ARIA attributes when necessary to improve accessibility.
- Test the form with screen readers and other assistive technologies to ensure compatibility.
- Offer clear and concise error messages to help users understand any issues with their input.

## Localization Best Practices

- Use a standardized method for handling translations, such as a localization library or service.
- Ensure all user-facing text, including form fields, error messages, and hints, are available in multiple languages.
- Test the form with input in different languages to ensure compatibility with various character sets and encodings.
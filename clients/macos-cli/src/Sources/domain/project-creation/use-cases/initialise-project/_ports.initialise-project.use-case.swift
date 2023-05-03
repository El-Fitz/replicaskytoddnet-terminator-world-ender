protocol _InitProjectUseCaseRequestProjectNamePort {
	func execute() async -> String?
}

protocol _InitProjectUseCaseInferProjectNamePort {
	func execute(request: UseCases.InitProject.Models.Request.InferProjectName) async throws -> String
}

protocol _InitProjectUseCaseRequestFunctionalDescriptionPort {
	func execute() async -> String
}

protocol _InitProjectUseCaseRequestTechnicalEnvironmentPort {
	func execute() async -> String?
}

protocol _InitProjectUseCaseInferTechnicalEnvironmentPort {
	func execute(request: UseCases.InitProject.Models.Request.InferTechnicalEnvironment) async throws -> String
}

protocol _InitProjectUseCaseRequestProgrammingLanguagePort {
	func execute() async -> String?
}

protocol _InitProjectUseCaseInferProgrammingLanguagePort {
	func execute(request: UseCases.InitProject.Models.Request.InferProgrammingLanguage) async throws -> String
}

protocol _InitProjectUseCaseRequestTechnicalArchitecturePort {
	func execute() async -> String?
}

protocol _InitProjectUseCaseInferTechnicalArchitecturePort {
	func execute(request: UseCases.InitProject.Models.Request.InferTechnicalArchitecture) async throws -> String
}

protocol _InitProjectUseCaseRequestTechnicalFrameworksPort {
	func execute() async -> String?
}

protocol _InitProjectUseCaseInferTechnicalFrameworksPort {
	func execute(request: UseCases.InitProject.Models.Request.InferTechnicalFrameworks) async throws -> String?
}

protocol _InitProjectUseCaseRequestToolsPort {
	func execute() async -> String?
}

protocol _InitProjectUseCaseInferToolsPort {
	func execute(request: UseCases.InitProject.Models.Request.InferTools) async throws -> String?
}

protocol _InitProjectUseCaseRequestLibrariesPort {
	func execute() async -> String?
}

protocol _InitProjectUseCaseInferLibrariesPort {
	func execute(request: UseCases.InitProject.Models.Request.InferLibraries) async throws -> String?
}

protocol _InitProjectUseCaseSaveRequirementsPort {
	func execute(requirements: ProjectRequirementsDefinition) async throws
}

protocol _InitProjectUseCaseDeleteRequirementsPort {
	func execute() async throws
}

protocol _InitProjectUseCaseRequestUserApprovalPort {
	func execute(requirements: ProjectRequirementsDefinition) async throws -> Bool
}
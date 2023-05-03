struct UseCases {

}

extension UseCases {
	class InitProject {
		struct Ports {
			typealias RequestProjectName = _InitProjectUseCaseRequestProjectNamePort
			typealias RequestFunctionalDescription = _InitProjectUseCaseRequestFunctionalDescriptionPort
			typealias RequestTechnicalEnvironment = _InitProjectUseCaseRequestTechnicalEnvironmentPort
			typealias RequestProgrammingLanguage = _InitProjectUseCaseRequestProgrammingLanguagePort
			typealias RequestTechnicalArchitecture = _InitProjectUseCaseRequestTechnicalArchitecturePort
			typealias RequestTechnicalFrameworks = _InitProjectUseCaseRequestTechnicalFrameworksPort
			typealias RequestTools = _InitProjectUseCaseRequestToolsPort
			typealias RequestLibraries = _InitProjectUseCaseRequestLibrariesPort

			typealias InferProjectName = _InitProjectUseCaseInferProjectNamePort
			typealias InferTechnicalEnvironment = _InitProjectUseCaseInferTechnicalEnvironmentPort
			typealias InferProgrammingLanguage = _InitProjectUseCaseInferProgrammingLanguagePort
			typealias InferTechnicalArchitecture = _InitProjectUseCaseInferTechnicalArchitecturePort
			typealias InferTechnicalFrameworks = _InitProjectUseCaseInferTechnicalFrameworksPort
			typealias InferTools = _InitProjectUseCaseInferToolsPort
			typealias InferLibraries = _InitProjectUseCaseInferLibrariesPort

			typealias SaveRequirements = _InitProjectUseCaseSaveRequirementsPort
			typealias DeleteRequirements = _InitProjectUseCaseDeleteRequirementsPort

			typealias RequestUserApproval = _InitProjectUseCaseRequestUserApprovalPort
		}

		struct Dependencies {
			let RequestProjectName: Ports.RequestProjectName
			let RequestFunctionalDescription: Ports.RequestFunctionalDescription
			let RequestTechnicalEnvironment: Ports.RequestTechnicalEnvironment
			let RequestProgrammingLanguage: Ports.RequestProgrammingLanguage
			let RequestTechnicalArchitecture: Ports.RequestTechnicalArchitecture
			let RequestTechnicalFrameworks: Ports.RequestTechnicalFrameworks
			let RequestTools: Ports.RequestTools
			let RequestLibraries: Ports.RequestLibraries

			let InferProjectName: Ports.InferProjectName
			let InferTechnicalEnvironment: Ports.InferTechnicalEnvironment
			let InferProgrammingLanguage: Ports.InferProgrammingLanguage
			let InferTechnicalArchitecture: Ports.InferTechnicalArchitecture
			let InferTechnicalFrameworks: Ports.InferTechnicalFrameworks
			let InferTools: Ports.InferTools
			let InferLibraries: Ports.InferLibraries

			let SaveRequirements: Ports.SaveRequirements
			let DeleteRequirements: Ports.DeleteRequirements

			let RequestUserApproval: Ports.RequestUserApproval
		}

		let dependencies: Dependencies

		public init(dependencies: Dependencies) {
			self.dependencies = dependencies
		}

		func execute() async throws -> ProjectRequirementsDefinition {
			let providedProjectName = await dependencies.RequestProjectName.execute()
			let providedFunctionalDescription = await dependencies.RequestFunctionalDescription.execute()
			let providedTechnicalEnvironment = await dependencies.RequestTechnicalEnvironment.execute()
			let providedProgrammingLanguage = await dependencies.RequestProgrammingLanguage.execute()
			let providedTechnicalArchitecture = await dependencies.RequestTechnicalArchitecture.execute()
			let providedTechnicalFrameworks = await dependencies.RequestTechnicalFrameworks.execute()
			let providedTools = await dependencies.RequestTools.execute()
			let providedLibraries = await dependencies.RequestLibraries.execute()

			let projectName: String = try await {
				if let providedProjectName = providedProjectName {
					return providedProjectName
				} else {
					return try await self.dependencies.InferProjectName.execute(request: .init(functionalDescription: providedFunctionalDescription)) 
				}
			}()
			let technicalEnvironment: String = try await {
				if let providedTechnicalEnvironment = providedTechnicalEnvironment {
					return providedTechnicalEnvironment
				} else {
					return try await self.dependencies.InferTechnicalEnvironment.execute(request: .init(functionalDescription: providedFunctionalDescription))
				}
			}()
			let programmingLanguage: String = try await {
				if let providedProgrammingLanguage = providedProgrammingLanguage {
					return providedProgrammingLanguage
				} else {
					return try await self.dependencies.InferProgrammingLanguage.execute(request: .init(functionalDescription: providedFunctionalDescription, technicalEnvironment: technicalEnvironment))
				}
			}()
			let technicalArchitecture: String = try await {
				if let providedTechnicalArchitecture = providedTechnicalArchitecture {
					return providedTechnicalArchitecture
				} else {
					return try await self.dependencies.InferTechnicalArchitecture.execute(request: .init(functionalDescription: providedFunctionalDescription, technicalEnvironment: technicalEnvironment))
				}
			}()
			async let technicalFrameworks: String? = {
				if let providedTechnicalFrameworks = providedTechnicalFrameworks {
					return providedTechnicalFrameworks
				} else {
					return try await self.dependencies.InferTechnicalFrameworks.execute(request: .init(functionalDescription: providedFunctionalDescription, technicalEnvironment: technicalEnvironment, programmingLanguage: programmingLanguage, technicalArchitecture: technicalArchitecture))
				}
			}()
			async let tools: String? = {
				if let providedTools = providedTools {
					return providedTools
				} else {
					return try await self.dependencies.InferTools.execute(request: .init(functionalDescription: providedFunctionalDescription, technicalEnvironment: technicalEnvironment, programmingLanguage: programmingLanguage, technicalArchitecture: technicalArchitecture))
				}
			}()
			async let libraries: String? = {
				if let providedLibraries = providedLibraries {
					return providedLibraries
				} else {
					return try await self.dependencies.InferLibraries.execute(request: .init(functionalDescription: providedFunctionalDescription, technicalEnvironment: technicalEnvironment, programmingLanguage: programmingLanguage, technicalArchitecture: technicalArchitecture))
				}
			}()

			let functionalRequirements = """
			# Project Name: \(projectName)
			\(providedFunctionalDescription)
			"""
	
			let requirements = try await ProjectRequirementsDefinition(
				functional: functionalRequirements,
				technical: [
					"environment": technicalEnvironment,
					"architecture": technicalArchitecture,
					"language": programmingLanguage,
					"frameworks": technicalFrameworks ?? "",
					"tools": tools ?? "",
					"libraries": libraries ?? ""
				]
			)

			try await dependencies.SaveRequirements.execute(requirements: requirements)

			guard try await dependencies.RequestUserApproval.execute(requirements: requirements) else {
				try await dependencies.DeleteRequirements.execute()
				throw UseCases.InitProject.Models.Error.userDidNotApproveRequirements
			}

			return requirements
		}
	}
}


extension UseCases {
	class SetUpProject {
		struct Ports {
			typealias RunScripts = _SetUpProjectUseCaseRunScriptsPort
			typealias CreateFiles = _SetUpProjectUseCaseCreateFilesPort
		}

		struct Dependencies {
			let RunScripts = Ports.RunScripts
			let CreateFiles = Ports.CreateFiles
		}

		struct Params {
			let projectDefinition: ProjectDefinition
		}

		let dependencies: Dependencies

		public init(dependencies: Dependencies) {
			self.dependencies = dependencies
		}

		func execute(params: Params) async throws {
			// 1. Run Genesis scripts
			// TODO: Run Genesis scripts
			// 2. Create files
			// TODO: Create files
			// 3. Run Finalisation scripts
			// TODO: Run Finalisation scripts
		}
	}
}


extension UseCases.InitProject {
	struct Models {
		enum Error: Swift.Error {
			case userDidNotApproveRequirements
		}

		struct Request {
			struct InferProjectName {
				let functionalDescription: String
			}

			struct InferTechnicalEnvironment {
				let functionalDescription: String
			}

			struct InferProgrammingLanguage {
				let functionalDescription: String
				let technicalEnvironment: String
			}

			struct InferTechnicalArchitecture {
				let functionalDescription: String
				let technicalEnvironment: String
			}

			struct InferTechnicalFrameworks {
				let functionalDescription: String
				let technicalEnvironment: String
				let programmingLanguage: String
				let technicalArchitecture: String
			}

			struct InferTools {
				let functionalDescription: String
				let technicalEnvironment: String
				let programmingLanguage: String
				let technicalArchitecture: String
			}

			struct InferLibraries {
				let functionalDescription: String
				let technicalEnvironment: String
				let programmingLanguage: String
				let technicalArchitecture: String
			}
		}
	}
}
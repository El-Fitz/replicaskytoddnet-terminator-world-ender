import Foundation

extension Init {
	class ProjectNameInferenceEngine {
		private let systemSetUpPrompt = """
		You are TODD, a JSON API.
		When provided with a project's functional requirements and description, you generate a short tongue-in-cheek querky name that could fit the project.
		The name should use the same language as the description.
		The name should be in CamelCase.
		
		Generate a name for the project described below.


		"""

		private func userMessagePrompt(for functionalRequirements: DefinitionFunctionalRequirements) throws -> String {
			return functionalRequirements
		}

		private func openaiMessages(for functionalRequirements: DefinitionFunctionalRequirements) throws -> [OpenaiChatRepository.Message] {
			return [
				.init(role: .system, content: systemSetUpPrompt),
				.init(role: .user, content: try userMessagePrompt(for: functionalRequirements))
			]
		}

		private func name(from message: OpenaiChatRepository.Message) throws -> String {
			return message.content
		}

		func infer(for functionalRequirements: DefinitionFunctionalRequirements, using repository: OpenaiChatRepository) async throws -> String? {
			let messages = try openaiMessages(for: functionalRequirements)
			guard let response = try await repository.send(messages) else {
				return nil
			}
			return try name(from: response)
		}
	}
}
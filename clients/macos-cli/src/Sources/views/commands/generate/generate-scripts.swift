import Foundation

extension Generate {
	struct ScriptsDefinitionsGenerator {

		fileprivate struct PromptContext: Codable {
			let requirements: ProjectRequirements
			let fileTree: FileTree
		}

		private let systemPrompt = """
		You are TODD, a JSON API.
		You assist developpers by providing setup, build & run scripts for their projects.
		When provided with a project's requirements, the project's file tree and an outline of the project's files, you return the scripts required to init & set up the project, and it's dependencies.
		You also return the scripts required to build & run said project.

		You output your scripts using the following JSON template.

		No prose.

		==========

		TEMPLATE:
		{ "beforeFilesCreation": [{"name": "script name", "script": "the bash script to execute" }], "afterFilesCreation": [{"name": "script name", "script": "the bash script to execute" }] }
		"""
		
		private func contextPrompt(for fileTree: FileTree, and requirements: ProjectRequirements) throws -> String {
			let context = PromptContext(requirements: requirements, fileTree: fileTree)
			let contextJsonData = try JSONEncoder().encode(context)
			guard let contextJsonString = String(data: contextJsonData, encoding: .utf8) else {
				throw GenerateError.failedEncodingRequirements
			}
			return """
			==============
			CONTEXT:
			\(contextJsonString)
			"""
		}

		private func scriptRequestPrompt() -> String {
			return """
			================
			INSTRUCTION
			Generate the required setup scripts for the described project
			"""
		}

		private func openaiMessages(considering requirements: ProjectRequirements, and fileTree: FileTree) throws -> [OpenaiChatRepository.Message] {
			return [
				.init(role: .system, content: systemPrompt),
				.init(role: .user, content: try contextPrompt(for: fileTree, and: requirements)),
				.init(role: .user, content: scriptRequestPrompt())
			]
		}

		private func scriptsDefinitions(from message: OpenaiChatRepository.Message) throws -> ScriptsDefinitions? {
			guard let data = message.content.data(using: .utf8) else {
				return nil
			}
			return try JSONDecoder().decode(ScriptsDefinitions.self, from: data)
		}

		func generateScriptsDefinitions(considering requirements: ProjectRequirements, and fileTree: FileTree, using repository: OpenaiChatRepository) async throws -> ScriptsDefinitions? {
			let messages = try openaiMessages(considering: requirements, and: fileTree)
			guard let response = try await repository.send(messages) else {
				return nil
			}
			return try scriptsDefinitions(from: response)
		}
	}
}
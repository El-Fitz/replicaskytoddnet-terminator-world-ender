import Foundation
import AsyncAlgorithms

extension Generate {
	struct FilesDefinitionsGenerator {

		fileprivate struct PromptContext: Codable {
			let requirements: ProjectRequirements
			let fileTree: FileTree
		}

		private let systemSetUpPrompt = """
		You are TODD, a Software Engineer's best friend.
		When provided with a project's requirements, it's file tree, and a specific file's outline, you return the requested file full and raw content.
		The returned raw file contents contains a detailed implementation of the requested file's outlined classes, functions, structures and methods.
		The provided implementation is extensive and complete, and it's content strictly follows the project's requirements.

		No prose. No markdown codeblock.
		
		"""

		private let systemClosingPrompt = """
		Based on the previous description, return the requested file's full raw content, including an extensive & detailed complete implementation of the requested file's outlined classes, functions, structures and methods.
		
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

		private func fileContentRequestPrompt(for requestedFileOutline: FileOutline) -> String {
			return """
			================
			OUTPUT
			//\(requestedFileOutline.filepath)

			"""
		}

		private func openaiMessages(for requestedFileOutline: FileOutline, considering requirements: ProjectRequirements, and fileTree: FileTree) throws -> [OpenaiChatRepository.Message] {
			return [
				.init(role: .system, content: systemSetUpPrompt),
				.init(role: .user, content: try contextPrompt(for: fileTree, and: requirements)),
				.init(role: .user, content: fileContentRequestPrompt(for: requestedFileOutline))
				// .init(role: .system, content: systemClosingPrompt),
			]
		}

		private func fileDefinition(for filepath: String, from message: OpenaiChatRepository.Message) throws -> FileDefinition {
			let content = message.content
			return FileDefinition(filepath: filepath, content: content)
		}

		fileprivate func generateFileDefinition(for requestedFileOutline: FileOutline, considering requirements: ProjectRequirements, and fileTree: FileTree, using repository: OpenaiChatRepository) async -> Result<FileDefinition, Error> {
			do {
				let messages = try openaiMessages(for: requestedFileOutline, considering: requirements, and: fileTree)
				guard let response = try await repository.send(messages) else {
					return .failure(GenerateError.failedGeneratingFileDefinition(filepath: requestedFileOutline.filepath))
				}
				let fileDefinition = try fileDefinition(for: requestedFileOutline.filepath, from: response)	
				return .success(fileDefinition)
			} catch {
				return .failure(error)
			}
			
		}

		func generateFilesDefinitions(for requirements: ProjectRequirements, and fileTree: FileTree, using repository: OpenaiChatRepository) async throws -> [Result<FileDefinition, Error>] {
			let definitions = try await fileTree.outlines.async.compactMap({ (fileOutline) async throws -> Result<FileDefinition, Error> in
				return await generateFileDefinition(for: fileOutline, considering: requirements, and: fileTree, using: repository)
			}).collect()
			if definitions.count != fileTree.outlines.count {
				print("Failed to generate all files definitions")
			}
			return definitions
		}
	}
}
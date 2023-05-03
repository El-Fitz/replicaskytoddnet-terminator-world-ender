import Foundation

extension Generate {
	struct FilesStore {
		private func createProjectDescriptionFile(from projectDefinition: ProjectDefinition) throws -> String {
			let data = try JSONEncoder().encode(projectDefinition)
			guard let content = String(data: data, encoding: .utf8) else {
				throw GenerateError.failedEncodingProjectDefinition
			}
			return content
		}
		
		// func createProjectDescriptionFile(in directoryPath: String, from projectDefinition: ProjectDefinition) throws {
		// 	let content = try createProjectDescriptionFile(from: projectDefinition)
		// 	try FilesRepository.write(content, to: "./.replicaskytoddnetinator/.tmp/artifacts/roject.json", at: .custom() directoryPath)
		// }
	}
}
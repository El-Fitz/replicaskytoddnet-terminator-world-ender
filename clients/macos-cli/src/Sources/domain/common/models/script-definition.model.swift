struct ScriptsDefinitions: Codable {
	let beforeFilesCreation: [ScriptDefinition]
	let afterFilesCreation: [ScriptDefinition]
}
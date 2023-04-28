struct ProjectDefinition: Codable {
	let requirements: ProjectRequirements
	let fileTree: FileTree
	let files: [FileDefinition]
	let scripts: ScriptsDefinitions
}
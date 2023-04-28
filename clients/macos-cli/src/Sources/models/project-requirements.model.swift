struct ProjectRequirements: Codable, Hashable {
	let requirements: DefinitionRequirements
	let templates: [RequirementsTemplate]
}
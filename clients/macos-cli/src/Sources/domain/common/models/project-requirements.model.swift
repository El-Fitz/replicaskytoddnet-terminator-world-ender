struct ProjectRequirements: Codable, Hashable {
	let requirements: ProjectRequirementsDefinition
	let templates: [RequirementsTemplate]
}
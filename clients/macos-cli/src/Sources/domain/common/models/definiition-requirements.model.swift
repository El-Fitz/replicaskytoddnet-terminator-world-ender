struct ProjectRequirementsDefinition: Codable, Hashable {
	let functional: DefinitionFunctionalRequirements
	let technical: DefinitionTechnicalRequirements
}
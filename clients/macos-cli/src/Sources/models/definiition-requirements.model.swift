struct DefinitionRequirements: Codable, Hashable {
	let functional: DefinitionFunctionalRequirements
	let technical: DefinitionTechnicalRequirements
}
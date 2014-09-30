public enum FeatureParserNodeType {
	NAME("name"), SUB_START("("), SUB_END(")"), RELATIONSHIP("relationship");
	
	private String value;
	FeatureParserNodeType(String value) {
		this.value = value;
	}
	
	public String toString() {
		return value;
	}
}

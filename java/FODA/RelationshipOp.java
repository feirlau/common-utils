// 该集合中特征模型和子节点之间的关系，强制、可选、或者、选择，对应的操作为MA、OP、OR、XOR
public enum RelationshipOp {
	MA("MA"), OP("OP"), OR("OR"), XOR("XOR");
	
	private final String name;
	RelationshipOp(String name) {
		this.name = name;
	}
	public String toString() {
		return name;
	}
}

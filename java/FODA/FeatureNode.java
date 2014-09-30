import java.util.ArrayList;

// 特征模型节点
public class FeatureNode {
	// 节点名字
	public String name;
	// 节点所能组合的产品数
	public long count = 1;
	// 父节点
	public FeatureNode parent;
	// 该特征模型和父节点之间的关系，强制、可选、或者、选择，对应的操作为MA、OP、OR、XOR
	public RelationshipOp relationship;
    // 该节点对应的特征模型的子节点集合
    public ArrayList<FeatureNode> children = new ArrayList<FeatureNode>();
    
    public FeatureNode clone() {
    	FeatureNode node = new FeatureNode();
    	node.name = name;
    	node.count = count;
    	node.relationship = relationship;
    	return node;
    }
}

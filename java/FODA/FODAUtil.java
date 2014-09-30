import java.util.ArrayList;

public class FODAUtil {
	// 解析特征模型的数学序列（如B1MAB2MA(C1XORC2XORB3)MAB4OPA），生成一棵树，节点为FeatureNode
	public static FeatureNode generateFeatureNode(String featureStr) {
		FeatureNode rootNode = new FeatureNode();
		rootNode.name = "ROOT";
		int index = 0;
		FeatureNode parentNode = rootNode;
		FeatureNode currentNode = null;
		while(null != featureStr && featureStr.length()>0) {
			FeatureParserNode parserNode = FeatureParser.getFeatureParserNode(featureStr);
			parserNode.index = index;
			index += parserNode.value.length();
			featureStr = featureStr.substring(index);
			FeatureNode featureNode = null;
			if(parserNode.type == FeatureParserNodeType.NAME) {
				// 创建节点，如B1
				featureNode = new FeatureNode();
				featureNode.name = parserNode.value;
				currentNode = featureNode;
			} else if(parserNode.type == FeatureParserNodeType.RELATIONSHIP) {
				// 设置节点之间的关系，如MA
				currentNode.relationship = getRelationshipOp(parserNode.value);
				currentNode.parent = parentNode;
				parentNode.children.add(currentNode);
				currentNode = null;
			} else if(parserNode.type == FeatureParserNodeType.SUB_START) {
				// 创建子节点，如(C1XORC2XORB3)
				featureNode = new FeatureNode();
				featureNode.parent = parentNode;
				parentNode.children.add(featureNode);
				parentNode = currentNode = featureNode;
			}  else if(parserNode.type == FeatureParserNodeType.SUB_END) {
				// 子节点结束，如)
				if(currentNode != null) {
					// 只有一个节点，如(B1)
					parentNode.name = currentNode.name;
				}
				currentNode = parentNode;
				parentNode = parentNode.parent;
			}
		}
		// 设置跟节点的名字，如A
		if(currentNode != null) {
			parentNode.name = currentNode.name;
		}
		return rootNode;
	}
	
	// 将生成的特征模型树规范化为一个二叉树
	public static FeatureNode normalizeFeatureNode(FeatureNode parent, FeatureNode featureNode) {
		FeatureNode rootNode = featureNode.clone();
		rootNode.parent = parent;
		if(parent != null) {
			parent.children.add(rootNode);
		}
		ArrayList<FeatureNode> featureNodes = featureNode.children;
		int length = featureNodes.size();
		if(length < 3) {
			// 少于3个节点，已经是二叉树结构，直接将节点添加上去
			for(FeatureNode currentNode : featureNodes) {
				normalizeFeatureNode(rootNode,currentNode);
			}
		} else {
			int index = 0;
			FeatureNode parentNode = null;
			FeatureNode preNode = null;
			// 遍历所有子节点，优化该子节点
			while(index < length) {
				FeatureNode node1 = featureNodes.get(index);
				if(preNode !=null && preNode.relationship == node1.relationship && (node1.relationship == RelationshipOp.OR || node1.relationship == RelationshipOp.XOR)) {
					// 对于多于两个的OR和XOR关系的一组子节点，将它们优化为二叉树结构
					FeatureNode parentNode1 = node1.clone();
					parentNode1.relationship = RelationshipOp.MA;
					// 将父节点类型修改为当前类型，同时将父节点与当前节点组合，添加另一个父节点
					parentNode.relationship = preNode.relationship;
					FeatureNode preParent = parentNode.parent;
					preParent.children.remove(parentNode);
					parentNode.parent = parentNode1;
					parentNode1.parent = preParent;
					parentNode1.children.add(parentNode);
					preParent.children.add(parentNode1);
					normalizeFeatureNode(parentNode1, node1);
					preNode = node1;
					index += 1;
				} else if(index + 1 == length) {
					// 剩下最后一个节点时，直接将它加上去
					normalizeFeatureNode(rootNode, node1);
					preNode = node1;
					index += 1;
				} else {
					// 对不同类型的节点分组优化，添加父节点，(MA, MA), (OP, OP), (MA,OP), (XOR, XOR), (OR, OR)
					FeatureNode node2 = featureNodes.get(index+1);
					if((node1.relationship != node2.relationship) && (node2.relationship == RelationshipOp.OR || node2.relationship == RelationshipOp.XOR)) {
						// 对不同类型的节点分组，如果两个节点类型不可组合，将它们以单个节点形式添加
						normalizeFeatureNode(rootNode, node1);
						preNode = node1;
						index += 1;
					} else {
						parentNode = node2.clone();
						if(node1.relationship != node2.relationship || node1.relationship != RelationshipOp.OP) {
							// 只有当为(OP, OP)时父节点类型为RelationshipOp.OP，其他为RelationshipOp.MA
							parentNode.relationship = RelationshipOp.MA;
						}
						parentNode.parent = rootNode;
						rootNode.children.add(parentNode);
						normalizeFeatureNode(parentNode, node1);
						normalizeFeatureNode(parentNode, node2);
						preNode = node2;
						index += 2;
					}
				}
			}
			rootNode = normalizeFeatureNode(null, rootNode);
		}
		return rootNode;
	}
	
	// 计算该特征模型对应的产品数
	public static long getFeatureCount(FeatureNode featureNode) {
		ArrayList<FeatureNode> children = featureNode.children;
		if(children.size() == 1) {
			FeatureNode node1 = children.get(0);
			if(node1.relationship == RelationshipOp.MA) {
				featureNode.count = getFeatureCount(node1);
			} else if(node1.relationship == RelationshipOp.OP) {
				featureNode.count = getFeatureCount(node1) + 1;
			}
		} else if(children.size() == 2) {
			FeatureNode node1 = children.get(0);
			FeatureNode node2 = children.get(1);
			long count1 = getFeatureCount(node1);
			long count2 = getFeatureCount(node2);
			if(node1.relationship == RelationshipOp.OR) {
				featureNode.count = (count1+1)*(count2+1)-1;
			} else if(node1.relationship == RelationshipOp.XOR) {
				featureNode.count = count1 + count2;
			} else {
				if(node1.relationship == RelationshipOp.OP) {
					count1 += 1;
				}
				if(node2.relationship == RelationshipOp.OP) {
					count2 += 1;
				}
				featureNode.count = count1 * count2;
			}
			
		}
		return featureNode.count;
	}
	
	// 通过操作数对应的字符串得到相应的操作对象
	public static RelationshipOp getRelationshipOp(String relationship) {
		RelationshipOp op = RelationshipOp.MA;
		if(RelationshipOp.MA.equals(relationship)) {
			op = RelationshipOp.MA;
		} else if(RelationshipOp.OP.equals(relationship)) {
			op = RelationshipOp.OP;
		} else if(RelationshipOp.OR.equals(relationship)) {
			op = RelationshipOp.OR;
		} else if(RelationshipOp.XOR.equals(relationship)) {
			op = RelationshipOp.XOR;
		}
		return op;
	}
}

public class FeatureParser {
	public static FeatureParserNode getFeatureParserNode(String featureStr) {
		FeatureParserNode parserNode = null;
		if(featureStr != null) {
			FeatureParserNodeType type = FeatureParserNodeType.NAME;
			String value = featureStr;
			int index1 = featureStr.indexOf(FeatureParserNodeType.SUB_START.toString());
			if(index1 >= 0) {
				type = FeatureParserNodeType.SUB_START;
				value = type.toString();
			}
			int index2 = featureStr.indexOf(FeatureParserNodeType.SUB_END.toString());
			if(index2 >= 0 && index2 < index1) {
				index1 = index2;
				type = FeatureParserNodeType.SUB_END;
				value = type.toString();
			}
			index2 = featureStr.indexOf(RelationshipOp.MA.toString());
			if(index2 >= 0 && index2 < index1) {
				index1 = index2;
				type = FeatureParserNodeType.RELATIONSHIP;
				value = RelationshipOp.MA.toString();
			}
			index2 = featureStr.indexOf(RelationshipOp.OP.toString());
			if(index2 >= 0 && index2 < index1) {
				index1 = index2;
				type = FeatureParserNodeType.RELATIONSHIP;
				value = RelationshipOp.OP.toString();
			}
			index2 = featureStr.indexOf(RelationshipOp.OR.toString());
			if(index2 >= 0 && index2 < index1) {
				index1 = index2;
				type = FeatureParserNodeType.RELATIONSHIP;
				value = RelationshipOp.OR.toString();
			}
			index2 = featureStr.indexOf(RelationshipOp.XOR.toString());
			if(index2 >= 0 && index2 < index1) {
				index1 = index2;
				type = FeatureParserNodeType.RELATIONSHIP;
				value = RelationshipOp.XOR.toString();
			}
			if(index1 != 0) {
				type = FeatureParserNodeType.NAME;
				if(index1 > 0) {
					value = featureStr.substring(0, index1);
				}
			}
			parserNode = new FeatureParserNode();
			parserNode.type = type;
			parserNode.value = value;
		}
		return parserNode;
	}
}

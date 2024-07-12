package main.java.KGIRA.entity;

public class KnowledgeGranularity {
	private IntArrayKey attributes;   //B
	private int DecisionValue=-1;        //是否包含D待定  不包含为-1
	private float NotDValue;   //不包含D的GKu
	private float DValue;  //包含D的GKu
	
	public IntArrayKey getAttributes() {
		return attributes;
	}
	public void setAttributes(IntArrayKey attributes) {
		this.attributes = attributes;
	}
	public int getDecisionValue() {
		return DecisionValue;
	}
	public void setDecisionValue(int decisionValue) {
		DecisionValue = decisionValue;
	}
	public float getNotDValue() {
		return NotDValue;
	}
	public void setNotDValue(float notDValue) {
		NotDValue = notDValue;
	}
	public float getDValue() {
		return DValue;
	}
	public void setDValue(float dValue) {
		DValue = dValue;
	}
	//	public KnowledgeGranularity() {
//		
//	}
	public KnowledgeGranularity(IntArrayKey attributes,int decisionValue) {
		this.attributes=attributes;
		this.DecisionValue=decisionValue;
	}
	//计算
//	public calculateGK() {
//		
//	}
}

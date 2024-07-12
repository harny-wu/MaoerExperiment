package main.basic.model;

import java.util.Arrays;

public class Sample {
	protected int name;
	protected int[] attributeValues;  
	public static int DECISION_ATTRIBUTE_INDEX=0;  //决策属性下标为0
	protected boolean is_Incomplete=false;
	
	public Sample() {
		
	}
	public Sample(int name,int[] attributeValues) {
		this.name=name;
		this.attributeValues=attributeValues;
	}
	public Sample(int name,int[] attributeValues,boolean is_Incomplete) {
		this.name=name;
		this.attributeValues=attributeValues;
		this.is_Incomplete=is_Incomplete;
	}
	public int getName() {
		return name;
	}
	public void setName(int name) {
		this.name = name;
	}
	public int[] getAttributeValues() {
		return attributeValues;
	}
	public void setAttributeValues(int[] attributeValues) {
		this.attributeValues = attributeValues;
	}
	public int getValueLength() {
		return attributeValues.length;
	}
	public void setAttributeValue(int...value) {
		attributeValues=value;
	}
	public void setAttributeValueOf(int index,int value) {
		attributeValues[index]=value;
	}
	public int getAttributeValueByIndex(int index) {
		try {
			return attributeValues[index];
		}catch(IndexOutOfBoundsException e){
			return -1;
		}
	}
	public boolean isIs_Incomplete() {
		return is_Incomplete;
	}
	public void setIs_Incomplete(boolean is_Incomplete) {
		this.is_Incomplete = is_Incomplete;
	}
	public int[] getConditionValues() {
		return Arrays.copyOfRange(attributeValues, 1, attributeValues.length);
	}
	public int getDecisionValues() {
		return attributeValues[DECISION_ATTRIBUTE_INDEX];
	}
	public String toString() {
		if(attributeValues==null)	return "Instance #"+name;

        StringBuilder builder = new StringBuilder();
        builder.append("Instance-"+name+"	");
        for (int i=1; i<attributeValues.length; i++) {
            builder.append(attributeValues[i]);
            if (i!=attributeValues.length-1)	builder.append(", ");
        }
        builder.append("	"+"d = "+attributeValues[0]);
        return builder.toString();
	}
	public Sample clone() {
		Sample x=new Sample(this.name,this.attributeValues.clone(),this.is_Incomplete);
		return x;
	}
}

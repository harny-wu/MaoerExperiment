package main.java.FSSNC.entity;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Set;


//Ux
public class Sample{
	protected int name;  //xIndex
	protected float[] attributeValues;  
	public static int DECISION_ATTRIBUTE_INDEX=0;  //决策属性下标为0
	protected boolean is_Incomplete=false;
	
	public Sample() {}
	public Sample(int name,float[] attributeValues) {
		this.name=name;
		this.attributeValues=attributeValues;
	}
	public Sample(int name,float[] attributeValues,boolean is_Incomplete) {
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
	public float[] getAttributeValues() {
		return this.attributeValues;
	}
	public void setAttributeValues(float[] attributeValues) {
		this.attributeValues = attributeValues;
	}
	public int getValueLength() {
		return attributeValues.length;
	}
	public void setAttributeValue(float...value) {
		attributeValues=value;
	}
	public void setAttributeValueOf(int index,float value) {
		attributeValues[index]=value;
	}
	public float getAttributeValueByIndex(int index) {
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
	public float[] getConditionValues() {
		return Arrays.copyOfRange(attributeValues, 1, attributeValues.length);
	}
	public float getDecisionValues() {
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
}

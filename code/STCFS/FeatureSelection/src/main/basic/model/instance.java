package main.basic.model;

import java.util.Arrays;

/**
 * @author 凌Y
 *
 */
public class instance {
	public static int DECISION_ATTRIBUTE_INDEX=0;  //决策属性下标为0
	protected int[] attributeValues;
	private static int numCounter=1;  //ID
	protected int num=0;
	
	public static int getDECISION_ATTRIBUTE_INDEX() {
		return DECISION_ATTRIBUTE_INDEX;
	}
	public static void setDECISION_ATTRIBUTE_INDEX(int dECISION_ATTRIBUTE_INDEX) {
		DECISION_ATTRIBUTE_INDEX = dECISION_ATTRIBUTE_INDEX;
	}
	public int[] getAttributeValues() {
		return attributeValues;
	}
	public void setAttributeValues(int[] attributeValues) {
		this.attributeValues = attributeValues;
	}
	public static int getNumCounter() {
		return numCounter;
	}
	public static void setNumCounter(int numCounter) {
		instance.numCounter = numCounter;
	}
	public int getNum() {
		return num;
	}
	
	public instance(int[] value) {
		this(value,numCounter++);
	}
	public instance(int[] value,int num) {
		if(value!=null)
			setAttributeValue(value);
		this.num=num;
	}
	public static void resetID() {
		numCounter=1;
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
	public int getAttributeValue(int index) {
		try {
			return attributeValues[index];
		}catch(IndexOutOfBoundsException e){
			return -1;
		}
	}
	public int[] getConditionAttributeValues() {     //条件属性从下标1开始，下标0为决策属性
		return Arrays.copyOfRange(attributeValues, 1, attributeValues.length);
	}
	
	public String toString() {
		if(attributeValues==null)	return "Instance #"+num;

        StringBuilder builder = new StringBuilder();
        builder.append("Instance-"+num+"	");
        for (int i=1; i<attributeValues.length; i++) {
            builder.append(attributeValues[i]);
            if (i!=attributeValues.length-1)	builder.append(", ");
        }
        builder.append("	"+"d = "+attributeValues[0]);
        return builder.toString();
	}
	
}

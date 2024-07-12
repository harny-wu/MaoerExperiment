package main.basic.model;

import java.util.Arrays;

/**
 * @author 凌Y
 *
 */
public class IncompleteInstance extends instance{
	public final static int MISSING_VALUE=-1;
	
	public IncompleteInstance(int[] value) {
		super(value);
		// TODO Auto-generated constructor stub
	}
	public IncompleteInstance(int[] value,int num) {
		super(value,num);
		// TODO Auto-generated constructor stub
	}
	public void setValueMissing(int attribute) {
		getAttributeValues()[attribute-1]=MISSING_VALUE;
	}
	public boolean isValueMissing(int attribute) {
		return getAttributeValue(attribute)==MISSING_VALUE;
	}
	public boolean containsMissingValue() {
		return Arrays.stream(this.attributeValues).anyMatch(v ->v==MISSING_VALUE);
	}
	
	public String toString() {
		return "*"+super.toString() +" (missing value)";
	}
}

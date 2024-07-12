package main.java.KGIRA.entity;

import java.util.Collection;
import java.util.HashSet;
import java.util.LinkedList;
import main.basic.model.Sample;

//import main.java.KGIRA.entity.IncompleteInstance;


public class ToleranceEquivalenceClass {
	//public final static int MISSING_VALUE = IncompleteInstance.MISSING_VALUE;
	private int xIndex;  //x下标
	//private Sample x;
	//private int decisionValue=-1;
	private HashSet<Sample> items;
	
//	public int getAttributeValue() {
//		return attributeValue;
//	}
//	public void setAttributeValue(int attributeValue) {
//		this.attributeValue = attributeValue;
//	}
//	public int getDecisionValue() {
//		return decisionValue;
//	}
//	public void setDecisionValue(int decisionValue) {
//		this.decisionValue = decisionValue;
//	}
	public HashSet<Sample> getItems() {
		return items;
	}
	public int getXIndex() {
		return xIndex;
	}
	public void setXIndex(int xIndex) {
		this.xIndex = xIndex;
	}
	public void setItems(HashSet<Sample> items) {
		this.items = items;
	}
	/**
	 * Constructor for {@link EquivalenceClass}.
	 * 
	 * @see #attributeValue
	 * 
	 * @param attributeValue
	 * 		The attribute value that {@link Instance}s in this equivalent class share.
	 */
//	public ToleranceEquivalenceClass(int attributeValue,int decisionValue) {
//		items = new LinkedList<>();
//		this.attributeValue = attributeValue;
//		this.decisionValue=decisionValue;
//	}
//	public ToleranceEquivalenceClass(int attributeValue) {
//		items = new HashSet<Sample>();
//		this.attributeValue = attributeValue;
//	}
//	public ToleranceEquivalenceClass() {
//		items = new HashSet<Sample>();
//		this.attributeValue = -1;
//	}
	public ToleranceEquivalenceClass(int xIndex,int USize) {
		items = new HashSet<Sample>();
		this.xIndex = xIndex;
	}
	public ToleranceEquivalenceClass() {
		items = new HashSet<Sample>();   //*****************可修改 是否在输入参数中添加int USize
		//this.xIndex = new Sample();
		}
	/**
	 * Add an {@link Instance} into current equivalent class.
	 * 
	 * @param ins
	 * 		An {@link Instance} to be added.
	 */
	public void add(Sample ins) {
		items.add(ins);
	}
	
	public String toString() {
		StringBuilder builder = new StringBuilder();
		builder.append("EquivalenceClass[");
		builder.append("xIndex="+xIndex);
		builder.append(", |items|="+items.size());
		builder.append("]");
		
		return builder.toString();
	}
}

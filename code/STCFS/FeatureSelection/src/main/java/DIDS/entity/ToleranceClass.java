package main.java.DIDS.entity;

import java.util.ArrayList;
import java.util.Collection;
import java.util.LinkedList;
import main.basic.model.Sample;

public class ToleranceClass {
	private int attributeValue;  //属性值
	private Collection<Sample> items;  
	
	public ToleranceClass(int attributeValue) {
		this.attributeValue=attributeValue;
		this.items=new LinkedList<Sample>();
	}
	public ToleranceClass(int attributeValue,Collection<Sample> items) {
		this.attributeValue=attributeValue;
		this.items=items;
	}
	
	public int getAttributeVlaue() {
		return attributeValue;
	}
	public void setAttributeVlaue(int attributeVlaue) {
		this.attributeValue = attributeVlaue;
	}
	public Collection<Sample> getItems() {
		return items;
	}
	public void setItems(ArrayList<Sample> items) {
		this.items = items;
	}
	public void add(Sample ins) {
		items.add(ins);
	}
	public String toString() {
		StringBuilder builder = new StringBuilder();
		//builder.append("ToleranceClass[");
		builder.append("attributeValue="+attributeValue);
		builder.append(", |items|="+items.size()+" ");
		builder.append("]");
		
		return builder.toString();
	}
	
}

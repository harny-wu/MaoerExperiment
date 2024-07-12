package main.java.IFSICE.entity;

import java.util.ArrayList;
import main.basic.model.Sample;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map.Entry;
import java.util.Set;

public class ToleranceCollection {
	private IntArrayKey attribute;
	private HashMap<Integer,ArrayList<Sample>> items;
	//private int totalDNumber=0;
	
	public ToleranceCollection() {}
	public ToleranceCollection(IntArrayKey attribute,int itemsSize) {
		this.attribute=attribute;
		items=new HashMap<Integer,ArrayList<Sample>>(itemsSize);
	}
	
	public ToleranceCollection(IntArrayKey attribute,HashMap<Integer,ArrayList<Sample>> items) {
		this.attribute=attribute;
		this.items=items;
	}
	public IntArrayKey getAttribute() {
		return attribute;
	}
	public void setAttribute(IntArrayKey attribute) {
		this.attribute = attribute;
	}	
	public HashMap<Integer, ArrayList<Sample>> getItems() {
		return items;
	}
	public void setItems(HashMap<Integer, ArrayList<Sample>> items) {
		this.items = items;
	}
	public void outPut() {
		System.out.print("Attribute-"+this.attribute);
		Set<Entry<Integer,ArrayList<Sample>>> entryset=this.items.entrySet();
		for(Entry<Integer,ArrayList<Sample>> entrykey:entryset) {
			System.out.print("T("+entrykey.getKey()+")={");
			for(Sample x:entrykey.getValue()) 
				System.out.print(x.getName()+",");
			System.out.println("}");
		}
	}
	
}

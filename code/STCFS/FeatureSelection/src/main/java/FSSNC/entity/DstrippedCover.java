package main.java.FSSNC.entity;

import java.util.Arrays;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.Map.Entry;
//剥离D的邻域覆盖集合
public class DstrippedCover {
	private IntArrayKey attributes;
	private HashMap<Integer,LinkedList<Integer>> NotDTolerance;
	private HashMap<Integer,LinkedList<Integer>> DTolerance;
	private int[] totalNotDNumber;
	private int[] totalDNumber;
	private float eBvalue;
	
	public DstrippedCover() {}
	public DstrippedCover(int size) {
		//LinkedList<ToleranceEquivalenceClass> dtec=new LinkedList<ToleranceEquivalenceClass>();
		//LinkedList<ToleranceEquivalenceClass> notdtec=new LinkedList<ToleranceEquivalenceClass>();
		NotDTolerance=new HashMap<Integer,LinkedList<Integer>>(size);
		DTolerance=new HashMap<Integer,LinkedList<Integer>>(size);
		totalNotDNumber=new int[size];
		totalDNumber=new int[size];
	}
	public DstrippedCover(IntArrayKey attributes,int size) {
		this.attributes=attributes;
		NotDTolerance=new HashMap<Integer,LinkedList<Integer>>(size);
		DTolerance=new HashMap<Integer,LinkedList<Integer>>(size);
		totalNotDNumber=new int[size];
		totalDNumber=new int[size];
	}
	//Clone
	public DstrippedCover clone(DstrippedCover DstrippedCover) {
		this.attributes=new IntArrayKey(DstrippedCover.getAttributes().key().clone());
		this.NotDTolerance=new HashMap<>(DstrippedCover.getNotDTolerance());
		this.DTolerance=new HashMap<>(DstrippedCover.getDTolerance());
		this.totalNotDNumber=new int[DstrippedCover.getTotalNotDNumber().length];
		this.totalDNumber=new int[DstrippedCover.getTotalDNumber().length];
		for(int i=0;i<DstrippedCover.getTotalNotDNumber().length;i++) {
			this.totalNotDNumber[i]=DstrippedCover.getTotalNotDNumber()[i];
			this.totalDNumber[i]=DstrippedCover.getTotalDNumber()[i];
		}
		this.eBvalue=DstrippedCover.geteBvalue();
		return this;
	}
	public IntArrayKey getAttributes() {
		return attributes;
	}
	public void setAttributes(IntArrayKey attributes) {
		this.attributes = attributes;
	}
	public HashMap<Integer, LinkedList<Integer>> getNotDTolerance() {
		return NotDTolerance;
	}
	public void setNotDTolerance(HashMap<Integer, LinkedList<Integer>> notDTolerance) {
		NotDTolerance = notDTolerance;
	}
	public HashMap<Integer, LinkedList<Integer>> getDTolerance() {
		return DTolerance;
	}
	public void setDTolerance(HashMap<Integer, LinkedList<Integer>> dTolerance) {
		DTolerance = dTolerance;
	}
	public int[] getTotalNotDNumber() {
		return totalNotDNumber;
	}
	public void setTotalNotDNumber(int[] totalNotDNumber) {
		this.totalNotDNumber = totalNotDNumber;
	}
	public int[] getTotalDNumber() {
		return totalDNumber;
	}
	public void setTotalDNumber(int[] totalDNumber) {
		this.totalDNumber = totalDNumber;
	}
	public float geteBvalue() {
		return eBvalue;
	}
	public void seteBvalue(float eBvalue) {
		this.eBvalue = eBvalue;
	}
	//计算eBValue
	public float calculateeBValue(int USize) {
		float eBvalue=0;
		for(Integer k:this.NotDTolerance.keySet()) {
			//if(this.getTotalNotDNumber()[k]!=0)
				//eBvalue+=(float)((float)(this.getTotalNotDNumber()[k]-this.getTotalDNumber()[k])/this.getTotalNotDNumber()[k]);
			eBvalue+=(float)((float)(this.getTotalNotDNumber()[k]-this.getTotalDNumber()[k])/(float)this.getTotalNotDNumber()[k]);
		}
		eBvalue=(1/(float)USize)*(float)eBvalue;
		this.eBvalue=eBvalue;
		return eBvalue;
	}
	
	public void outPut() {
		System.out.println("Attribute:"+attributes.toString());
		//System.out.println("totalNotDNumber:"+totalNotDNumber+",totalDNumber:"+totalDNumber);
		System.out.println("NotDTolerance:");
		for(Entry<Integer,LinkedList<Integer>> key:NotDTolerance.entrySet())
			System.out.println("T("+key.getKey()+")="+key.getValue().toString());
		System.out.println("DTolerance:");
		for(Entry<Integer,LinkedList<Integer>> key:DTolerance.entrySet())
			System.out.println("T("+key.getKey()+")="+key.getValue().toString());
		
	}
}

package main.java.KGIRA.entity;

import java.util.LinkedList;
import java.util.List;
import main.basic.model.Sample;

public class ToleranceCollection {
	private IntArrayKey attribute;
	private LinkedList<ToleranceEquivalenceClass> NotDTolerance;
	private LinkedList<ToleranceEquivalenceClass> DTolerance;
	private int totalNotDNumber=0;
	private int totalDNumber=0;
	
	public ToleranceCollection() {}
	public ToleranceCollection(IntArrayKey attribute) {
		this.attribute=attribute;
		NotDTolerance=new LinkedList<ToleranceEquivalenceClass>();
		DTolerance=new LinkedList<ToleranceEquivalenceClass>();
	}
	
	public ToleranceCollection(IntArrayKey attribute,LinkedList<ToleranceEquivalenceClass> NotDTolerance,LinkedList<ToleranceEquivalenceClass> DTolerance,int totalNotDNumber,int totalDNumber) {
		this.attribute=attribute;
		this.NotDTolerance=NotDTolerance;
		this.DTolerance=DTolerance;
		this.setTotalNotDNumber(totalNotDNumber);
		this.setTotalDNumber(totalDNumber);
	}
	//初始化
	public void initialize(List<Sample> U) {
		for(int i=0;i<U.size();i++) {
			this.NotDTolerance.add(new ToleranceEquivalenceClass(i,U.size()));
			this.DTolerance.add(new ToleranceEquivalenceClass(i,U.size()));
		}
	}
	public IntArrayKey getAttribute() {
		return attribute;
	}
	public void setAttribute(IntArrayKey attribute) {
		this.attribute = attribute;
	}
	public LinkedList<ToleranceEquivalenceClass> getNotDTolerance() {
		return NotDTolerance;
	}
	public void setNotDTolerance(LinkedList<ToleranceEquivalenceClass> notDTolerance) {
		NotDTolerance = notDTolerance;
	}
	public LinkedList<ToleranceEquivalenceClass> getDTolerance() {
		return DTolerance;
	}
	public void setDTolerance(LinkedList<ToleranceEquivalenceClass> dTolerance) {
		DTolerance = dTolerance;
	}

	public int getTotalNotDNumber() {
		return totalNotDNumber;
	}

	public void setTotalNotDNumber(int totalNotDNumber) {
		this.totalNotDNumber = totalNotDNumber;
	}

	public int getTotalDNumber() {
		return totalDNumber;
	}

	public void setTotalDNumber(int totalDNumber) {
		this.totalDNumber = totalDNumber;
	}
	public void resetNumber() {
		this.totalDNumber=0;
		this.totalNotDNumber=0;
	}
	
}

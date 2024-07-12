package main.java.DIDS.entity;

import java.util.Collection;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.Map.Entry;

import main.basic.model.Sample;

public class PositiveRegion {
	private IntArrayKey attributes;
	private Collection<Sample> POSSamples;
	private int size=0;
	
	public PositiveRegion() {}
	public PositiveRegion(IntArrayKey attributes) {
		this.attributes=attributes;
		POSSamples=new LinkedList<Sample>();
	}
	
	public IntArrayKey getAttributes() {
		return attributes;
	}
	public void setAttributes(IntArrayKey attributes) {
		this.attributes = attributes;
	}
	public Collection<Sample> getPOSSamples() {
		return POSSamples;
	}
	public void setPOSSamples(Collection<Sample> pOSSamples) {
		POSSamples = pOSSamples;
	}
	public int getSize() {
		return size;
	}
	public void setSize(int size) {
		this.size = size;
	}
	//计算正域
	public void calculate(Collection<Entry<Sample, Collection<Sample>>> toleranceClasses) {
		Collection<Sample> pos=new LinkedList<Sample>();
		ToleranceClassLoop:
			for (Entry<Sample, Collection<Sample>> toleranceClass: toleranceClasses) {
				Iterator<Sample> insIterator = toleranceClass.getValue().iterator();
				int dec =toleranceClass.getKey().getDecisionValues();
				while (insIterator.hasNext()) {
					//  in-consistent
					if (insIterator.next().getDecisionValues()!=dec) {
						continue ToleranceClassLoop;
					}
				}
				// all consistent
				pos.add(toleranceClass.getKey());
			}
		POSSamples=pos;
		size=pos.size();
	}
	//output
	public void outPut() {
		System.out.print("Atributes-"+attributes.toString()+" ");
		System.out.println("POSsize:"+size+" ");
		//System.out.println("POS={"+POSSamples.toString()+"}");
	}
}

package main.java.DIDS.entity;

import java.lang.reflect.InvocationTargetException;
import java.util.Collection;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.Map;
import java.util.Set;
import java.util.Map.Entry;

import main.basic.model.Sample;
import main.java.FSMV.entity.ToleranceClassandPOSResult;

public class ToleranceClassandIDegreeResult {
	//private IntArrayKey attributes;
	private Map<Sample,Collection<Sample>> toleranceClassesOfCondAttrs;
	private Map<Sample,Collection<Sample>> toleranceClassesOfCondAttrsWithDecAttr;
	private float iDegree=0;
	
	public ToleranceClassandIDegreeResult(Map<Sample,Collection<Sample>> toleranceClassesOfCondAttrs,Map<Sample,Collection<Sample>> toleranceClassesOfCondAttrsWithDecAttr,float iDegree) {
		//this.attributes=attributes;
		this.toleranceClassesOfCondAttrs=toleranceClassesOfCondAttrs;
		this.toleranceClassesOfCondAttrsWithDecAttr=toleranceClassesOfCondAttrsWithDecAttr;
		this.iDegree=iDegree;
	}
//	public IntArrayKey getAttributes() {
//		return attributes;
//	}
//	public void setAttributes(IntArrayKey attributes) {
//		this.attributes = attributes;
//	}
	public Map<Sample, Collection<Sample>> getToleranceClassesOfCondAttrs() {
		return toleranceClassesOfCondAttrs;
	}
	public void setToleranceClassesOfCondAttrs(Map<Sample, Collection<Sample>> toleranceClassesOfCondAttrs) {
		this.toleranceClassesOfCondAttrs = toleranceClassesOfCondAttrs;
	}
	public Map<Sample, Collection<Sample>> getToleranceClassesOfCondAttrsWithDecAttr() {
		return toleranceClassesOfCondAttrsWithDecAttr;
	}
	public void setToleranceClassesOfCondAttrsWithDecAttr(
			Map<Sample, Collection<Sample>> toleranceClassesOfCondAttrsWithDecAttr) {
		this.toleranceClassesOfCondAttrsWithDecAttr = toleranceClassesOfCondAttrsWithDecAttr;
	}
	public float getiDegree() {
		return iDegree;
	}
	public void setiDegree(float iDegree) {
		this.iDegree = iDegree;
	}
	public void tolerancesOutPut2() {
		Set<Entry<Sample,Collection<Sample>>> entryset1=toleranceClassesOfCondAttrs.entrySet();
		for(Entry<Sample,Collection<Sample>> entry:entryset1) {
			System.out.print("T("+entry.getKey().getName()+")={");
			for(Sample x:entry.getValue())
				System.out.print(x.getName()+",");
			System.out.println("}");
		}
		System.out.println("size="+toleranceClassesOfCondAttrs.size());
		Set<Entry<Sample,Collection<Sample>>> entryset=toleranceClassesOfCondAttrsWithDecAttr.entrySet();
		for(Entry<Sample,Collection<Sample>> entry:entryset) {
			System.out.print("T("+entry.getKey().getName()+")={");
			for(Sample x:entry.getValue())
				System.out.print(x.getName()+",");
			System.out.println("}");
		}
		System.out.println("iDegree="+iDegree+", size="+toleranceClassesOfCondAttrsWithDecAttr.size());
	}
	public void iDegreeOutPut() {
		System.out.println("iDegree="+iDegree+", NdecSize="+toleranceClassesOfCondAttrs.size()+", decSize="+toleranceClassesOfCondAttrsWithDecAttr.size());
	}
//	public static <ToleranceCollection extends Collection<Sample>> Map<Sample, Collection<Sample>>
//	copyToleranceClass(
//		Map<Sample, Collection<Sample>> tolerances,
//		Class<ToleranceCollection> tolerancesClass
//) throws InstantiationException, IllegalAccessException, IllegalArgumentException, 
//		InvocationTargetException, NoSuchMethodException, SecurityException
//{
//	Map<Sample, Collection<Sample>> copy = new HashMap<>(tolerances.size());
//	for (Entry<Sample, Collection<Sample>> entry: tolerances.entrySet()) {
//		copy.put(entry.getKey(), copyToleranceClass(entry.getValue(), tolerancesClass));
//	}
//	return copy;
//}
//	public static <Tolerance extends Collection<Sample>> Tolerance copyToleranceClass(
//			Collection<Sample> tolerance, Class<Tolerance> tolerancesClass
//	) throws InstantiationException, IllegalAccessException, IllegalArgumentException,
//			InvocationTargetException, NoSuchMethodException, SecurityException 
//	{
//		Tolerance tolerancesOfIns = tolerancesClass.getConstructor(Collection.class).newInstance(tolerance);
//		return tolerancesOfIns;
//	}
	public ToleranceClassandIDegreeResult clone() {
		Map<Sample,Collection<Sample>> newtoleranceClassesOfCondAttrs=new HashMap<>(this.toleranceClassesOfCondAttrs.size());
		for(Entry<Sample,Collection<Sample>> entry:toleranceClassesOfCondAttrs.entrySet()) {
			Collection<Sample> newtol=new LinkedList<>();
			for(Sample x:entry.getValue())
				newtol.add(x);
			newtoleranceClassesOfCondAttrs.put(entry.getKey(), newtol);
		}
		Map<Sample,Collection<Sample>> newtoleranceClassesOfCondAttrsWithDecAttr=new HashMap<>(this.toleranceClassesOfCondAttrsWithDecAttr.size());
		for(Entry<Sample,Collection<Sample>> entry:toleranceClassesOfCondAttrsWithDecAttr.entrySet()) {
			Collection<Sample> newtol=new LinkedList<>();
			for(Sample x:entry.getValue())
				newtol.add(x);
			newtoleranceClassesOfCondAttrsWithDecAttr.put(entry.getKey(), newtol);
		}
		float idegree=iDegree;
		return new ToleranceClassandIDegreeResult(newtoleranceClassesOfCondAttrs,newtoleranceClassesOfCondAttrsWithDecAttr,idegree);
	}
	public Map<Sample,Collection<Sample>> cloneToleranceofCondAttrs() {
		Map<Sample,Collection<Sample>> newtoleranceClassesOfCondAttrs=new HashMap<>(this.toleranceClassesOfCondAttrs.size());
		for(Entry<Sample,Collection<Sample>> entry:toleranceClassesOfCondAttrs.entrySet()) {
			Collection<Sample> newtol=new LinkedList<>();
			for(Sample x:entry.getValue())
				newtol.add(x);
			newtoleranceClassesOfCondAttrs.put(entry.getKey(), newtol);
		}
		
		return newtoleranceClassesOfCondAttrs;
	}
}

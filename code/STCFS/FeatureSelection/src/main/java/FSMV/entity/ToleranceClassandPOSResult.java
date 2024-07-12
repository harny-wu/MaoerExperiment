package main.java.FSMV.entity;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;
import main.basic.model.Sample;

public class ToleranceClassandPOSResult {
	private Map<Sample,Collection<Sample>> tolerances;
	private PositiveRegion pos;
	
	public ToleranceClassandPOSResult() {}
	public ToleranceClassandPOSResult(Map<Sample,Collection<Sample>> tolerances,PositiveRegion pos) {
		this.tolerances=tolerances;
		this.pos=pos;
	}
	public Map<Sample, Collection<Sample>> getTolerances() {
		return tolerances;
	}
	public void setTolerances(Map<Sample, Collection<Sample>> tolerances) {
		this.tolerances = tolerances;
	}
	public PositiveRegion getPos() {
		return pos;
	}
	public void setPos(PositiveRegion pos) {
		this.pos = pos;
	}	
	public void tolerancesOutPut() {
		System.out.print(tolerances.toString());
	}
	public void posOutPut() {
		pos.outPut();
	}
	public void tolerancesOutPut2() {
		Set<Entry<Sample,Collection<Sample>>> entryset=tolerances.entrySet();
		for(Entry<Sample,Collection<Sample>> entry:entryset) {
			System.out.print("T("+entry.getKey().getName()+")={");
			for(Sample x:entry.getValue())
				System.out.print(x.getName()+",");
			System.out.println("}");
		}
		System.out.println(", size="+tolerances.size());
	}
	public ToleranceClassandPOSResult clone() {
		Map<Sample,Collection<Sample>> newtolerances=new HashMap<>(this.tolerances.size());
		for(Entry<Sample,Collection<Sample>> entry:tolerances.entrySet()) {
			Collection<Sample> newtol=new LinkedList<>();
			for(Sample x:entry.getValue())
				newtol.add(x);
			newtolerances.put(entry.getKey(), newtol);
		}
		return new ToleranceClassandPOSResult(newtolerances,pos.clone());
	}
}

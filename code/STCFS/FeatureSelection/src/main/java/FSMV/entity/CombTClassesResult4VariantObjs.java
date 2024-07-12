package main.java.FSMV.entity;

import java.util.Collection;
import java.util.Map;
import java.util.Set;
import java.util.Map.Entry;
import main.basic.model.Sample;

/**
 * Full name: CombinedToleranceClassesResult4VariantObjects (Combined Tolerance Classes Result 4 Variant 
 * Objects)
 * <p>
 * An entity for the result of combined tolerance classes in variant objects process.
 * 
 * @author Benjamin_L
 */
public class CombTClassesResult4VariantObjs {
	private Collection<Sample> invariancesUpdated;
	private Collection<Sample> variancesUpdated;
	private Map<Sample, Collection<Sample>> tolerancesOfInvariances;
	private Map<Sample, Collection<Sample>> tolerancesOfVariances;
	private Map<Sample, Collection<Sample>> tolerancesOfCombined;
	
	public CombTClassesResult4VariantObjs(Collection<Sample> invariancesUpdated,Collection<Sample> variancesUpdated,Map<Sample, Collection<Sample>> tolerancesOfInvariances,Map<Sample, Collection<Sample>> tolerancesOfVariances,Map<Sample, Collection<Sample>> tolerancesOfCombined) {
		this.invariancesUpdated=invariancesUpdated;
		this.variancesUpdated=variancesUpdated;
		this.tolerancesOfInvariances=tolerancesOfInvariances;
		this.tolerancesOfVariances=tolerancesOfVariances;
		this.tolerancesOfCombined=tolerancesOfCombined;
	}

	public Collection<Sample> getInvariancesUpdated() {
		return invariancesUpdated;
	}
	public void setInvariancesUpdated(Collection<Sample> invariancesUpdated) {
		this.invariancesUpdated = invariancesUpdated;
	}
	public Collection<Sample> getVariancesUpdated() {
		return variancesUpdated;
	}
	public void setVariancesUpdated(Collection<Sample> variancesUpdated) {
		this.variancesUpdated = variancesUpdated;
	}
	public Map<Sample, Collection<Sample>> getTolerancesOfInvariances() {
		return tolerancesOfInvariances;
	}
	public void setTolerancesOfInvariances(Map<Sample, Collection<Sample>> tolerancesOfInvariances) {
		this.tolerancesOfInvariances = tolerancesOfInvariances;
	}
	public Map<Sample, Collection<Sample>> getTolerancesOfVariances() {
		return tolerancesOfVariances;
	}
	public void setTolerancesOfVariances(Map<Sample, Collection<Sample>> tolerancesOfVariances) {
		this.tolerancesOfVariances = tolerancesOfVariances;
	}
	public Map<Sample, Collection<Sample>> getTolerancesOfCombined() {
		return tolerancesOfCombined;
	}
	public void setTolerancesOfCombined(Map<Sample, Collection<Sample>> tolerancesOfCombined) {
		this.tolerancesOfCombined = tolerancesOfCombined;
	}
	
	public boolean anyUpdate() {
		return invariancesUpdated!=null && variancesUpdated!=null &&
				(!invariancesUpdated.isEmpty() || !variancesUpdated.isEmpty());
	}
	public void TolerancesOfCombinedOutPut() {
		Set<Entry<Sample,Collection<Sample>>> entryset=tolerancesOfCombined.entrySet();
		for(Entry<Sample,Collection<Sample>> entry:entryset) {
			System.out.print("T("+entry.getKey().getName()+")={");
			for(Sample x:entry.getValue())
				System.out.print(x.getName()+",");
			System.out.println("}");
		}
		System.out.println(", size="+tolerancesOfCombined.size());
	}
}

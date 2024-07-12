package main.java.FSMV.entity;

import java.util.Collection;
import java.util.List;

public class ReductCandidateResult4VariantObjects {
	private Collection<Integer> previousReductHash;
	private List<Integer> reductCandidate;
	
	public ReductCandidateResult4VariantObjects() {}
	public ReductCandidateResult4VariantObjects(Collection<Integer> previousReductHash,List<Integer> reductCandidate) {
		this.previousReductHash=previousReductHash;
		this.reductCandidate=reductCandidate;
	}
	public Collection<Integer> getPreviousReductHash() {
		return previousReductHash;
	}
	public void setPreviousReductHash(Collection<Integer> previousReductHash) {
		this.previousReductHash = previousReductHash;
	}
	public List<Integer> getReductCandidate() {
		return reductCandidate;
	}
	public void setReductCandidate(List<Integer> reductCandidate) {
		this.reductCandidate = reductCandidate;
	}
//	public ToleranceClassandPOSResult getNewMaxTCResult() {
//		return newMaxTCResult;
//	}
//	public void setNewMaxTCResult(ToleranceClassandPOSResult newMaxTCResult) {
//		this.newMaxTCResult = newMaxTCResult;
//	}
	
}

package main.java.FSMV.entity;

public class MostSignificantAttributeResult {
	private int attribute;
	private ToleranceClassandPOSResult TCResult;
	
	public MostSignificantAttributeResult(int attribute,ToleranceClassandPOSResult TCResult) {
		this.attribute=attribute;
		this.TCResult=TCResult;
	}
	public int getAttribute() {
		return attribute;
	}
	public void setAttribute(int attribute) {
		this.attribute = attribute;
	}
	public ToleranceClassandPOSResult getTCResult() {
		return TCResult;
	}
	public void setTCResult(ToleranceClassandPOSResult tCResult) {
		TCResult = tCResult;
	}
	
}

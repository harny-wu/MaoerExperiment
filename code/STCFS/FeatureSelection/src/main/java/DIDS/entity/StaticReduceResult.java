package main.java.DIDS.entity;

import java.util.LinkedHashMap;
import java.util.LinkedList;
import java.util.List;

public class StaticReduceResult {
	private ToleranceClassandIDegreeResult CTCResult;
	private ToleranceClassandIDegreeResult BTCResult;
	private List<Integer> Reduce;
	public LinkedHashMap<String,Long> times;  //分段时间
	public LinkedHashMap<Integer,Integer> posattr;
	
	public StaticReduceResult(ToleranceClassandIDegreeResult CTCResult,ToleranceClassandIDegreeResult BTCResult,List<Integer> Reduce) {
		this.CTCResult=CTCResult;
		this.BTCResult=BTCResult;
		this.Reduce=Reduce;
	}
	public StaticReduceResult(ToleranceClassandIDegreeResult CTCResult,ToleranceClassandIDegreeResult BTCResult,List<Integer> Reduce,LinkedHashMap<String,Long> times) {
		this.CTCResult=CTCResult;
		this.BTCResult=BTCResult;
		this.Reduce=Reduce;
		this.times=times;
	}
	public ToleranceClassandIDegreeResult getCTCResult() {
		return CTCResult;
	}
	public void setCTCResult(ToleranceClassandIDegreeResult cTCResult) {
		CTCResult = cTCResult;
	}
	public ToleranceClassandIDegreeResult getBTCResult() {
		return BTCResult;
	}
	public void setBTCResult(ToleranceClassandIDegreeResult bTCResult) {
		BTCResult = bTCResult;
	}
	public List<Integer> getReduce() {
		return Reduce;
	}
	public void setReduce(List<Integer> reduce) {
		Reduce = reduce;
	}
	
	public LinkedHashMap<String, Long> getTimes() {
		return times;
	}
	public void setTimes(LinkedHashMap<String, Long> times) {
		this.times = times;
	}
	public LinkedHashMap<Integer, Integer> getPosattr() {
		return posattr;
	}
	public void setPosattr(LinkedHashMap<Integer, Integer> posattr) {
		this.posattr = posattr;
	}
	//Reduce克隆
	public List<Integer> reduceClone() {
		List<Integer> newreduce=new LinkedList<Integer>();
		for(int x:this.Reduce) {
			newreduce.add(x);
		}
		return newreduce;
	}
}

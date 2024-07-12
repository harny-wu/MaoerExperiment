package main.java.FSMV.entity;

import java.util.LinkedHashMap;
import java.util.LinkedList;
import java.util.List;

public class StaticReduceResult {
	private ToleranceClassandPOSResult CPos;
	private ToleranceClassandPOSResult BPos;
	private List<Integer> Reduce;
	public LinkedHashMap<String,Long> times; //分段时间
	
	public StaticReduceResult(ToleranceClassandPOSResult CPos,ToleranceClassandPOSResult BPos,List<Integer> Reduce) {
		this.CPos=CPos;
		this.BPos=BPos;
		this.Reduce=Reduce;
	}
	public StaticReduceResult(ToleranceClassandPOSResult CPos,ToleranceClassandPOSResult BPos,List<Integer> Reduce,LinkedHashMap<String,Long> times) {
		this.CPos=CPos;
		this.BPos=BPos;
		this.Reduce=Reduce;
		this.times=times;
	}
	public ToleranceClassandPOSResult getCPos() {
		return CPos;
	}
	public void setCPos(ToleranceClassandPOSResult cPos) {
		CPos = cPos;
	}
	public ToleranceClassandPOSResult getBPos() {
		return BPos;
	}
	public void setBPos(ToleranceClassandPOSResult bPos) {
		BPos = bPos;
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
	//Reduce克隆
	public List<Integer> reduceClone() {
		List<Integer> newreduce=new LinkedList<Integer>();
		for(int x:this.Reduce) {
			newreduce.add(x);
		}
		return newreduce;
	}
}

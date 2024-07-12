package main.java.FSSNC.entity;

import java.util.LinkedHashMap;
import java.util.LinkedList;
import java.util.List;

public class StaticReduceResult {
	private List<Integer> Reduce;
	public LinkedHashMap<String,Long> times; //分段时间
	
	public StaticReduceResult(List<Integer> Reduce,LinkedHashMap<String,Long> times) {
		this.Reduce=Reduce;
		this.times=times;
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

package main.java.INEC.entity.equivalenceClass;

import java.util.LinkedHashMap;
import java.util.LinkedList;
import java.util.List;

public class StaticReduceResult {
	private teCollection Initial_te;
	private tEListCollection tEList;
	private List<Integer> Reduce;
	public LinkedHashMap<String, Long> splitTimes;
	public LinkedHashMap<Integer, Integer> posattr;
	public LinkedList<TNECSizeCount> TNECSize;

	public StaticReduceResult(teCollection Initial_te, tEListCollection tEList, List<Integer> Reduce) {
		this.Initial_te = Initial_te;
		this.tEList = tEList;
		this.Reduce = Reduce;
	}

	public StaticReduceResult(teCollection Initial_te, tEListCollection tEList, List<Integer> Reduce,
			LinkedHashMap<String, Long> splitTimes, LinkedHashMap<Integer, Integer> posattr,
			LinkedList<TNECSizeCount> TNECSize) {
		this.Initial_te = Initial_te;
		this.tEList = tEList;
		this.Reduce = Reduce;
		this.splitTimes = splitTimes;
		this.posattr = posattr;
		this.TNECSize = TNECSize;
	}

	public teCollection getInitial_te() {
		return Initial_te;
	}

	public void setInitial_te(teCollection initial_te) {
		Initial_te = initial_te;
	}

	public tEListCollection gettEList() {
		return tEList;
	}

	public void settEList(tEListCollection tEList) {
		this.tEList = tEList;
	}

	public List<Integer> getReduce() {
		return Reduce;
	}

	public void setReduce(List<Integer> reduce) {
		Reduce = reduce;
	}

	public LinkedHashMap<String, Long> getSplitTimes() {
		return splitTimes;
	}

	public void setSplitTimes(LinkedHashMap<String, Long> splitTimes) {
		this.splitTimes = splitTimes;
	}

	public LinkedHashMap<Integer, Integer> getPosattr() {
		return posattr;
	}

	public void setPosattr(LinkedHashMap<Integer, Integer> posattr) {
		this.posattr = posattr;
	}

	public List<Integer> reduceClone() {
		List<Integer> newreduce = new LinkedList<Integer>();
		for (int x : this.Reduce) {
			newreduce.add(x);
		}
		return newreduce;
	}
}

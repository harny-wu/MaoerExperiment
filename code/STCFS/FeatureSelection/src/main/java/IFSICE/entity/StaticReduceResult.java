package main.java.IFSICE.entity;

import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.LinkedList;
import java.util.List;

public class StaticReduceResult {
	private List<Integer> oldReduce;
	private List<Integer> remainC;
	private ToleranceCollection oldCTColl;
	private ToleranceCollection oldBTColl;
	private DupdateCollection oldDCategoryHash;
	private float THDP_C;
	private float THDP_B;
	public LinkedHashMap<String,Long> times;
	public int haveException=0; //0代表正常；1表示得到结果后中断；2表示没得到结果就中断
	
	public StaticReduceResult() {this.haveException=2;} //
	public StaticReduceResult(List<Integer> oldReduce,LinkedHashMap<String,Long> times) {
		this.oldReduce=oldReduce;
		this.times=times;
		this.haveException=1;
	}
	
	public StaticReduceResult(List<Integer> oldReduce,List<Integer> remainC,ToleranceCollection oldCTColl,ToleranceCollection oldBTColl,DupdateCollection oldDCategoryHash,float THDP_C,float THDP_B) {
		this.oldReduce=oldReduce;
		this.remainC=remainC;
		this.oldCTColl=oldCTColl;
		this.oldBTColl=oldBTColl;
		this.oldDCategoryHash=oldDCategoryHash;
		this.THDP_C=THDP_C;
		this.THDP_B=THDP_B; 
		this.haveException=0;
	}
	public StaticReduceResult(List<Integer> oldReduce,List<Integer> remainC,ToleranceCollection oldCTColl,ToleranceCollection oldBTColl,DupdateCollection oldDCategoryHash,float THDP_C,float THDP_B,LinkedHashMap<String,Long> times) {
		this.oldReduce=oldReduce;
		this.remainC=remainC;
		this.oldCTColl=oldCTColl;
		this.oldBTColl=oldBTColl;
		this.oldDCategoryHash=oldDCategoryHash;
		this.THDP_C=THDP_C;
		this.THDP_B=THDP_B; 
		this.times=times;
		this.haveException=0;
	}
	public List<Integer> getOldReduce() {
		return oldReduce;
	}
	public void setOldReduce(List<Integer> oldReduce) {
		this.oldReduce = oldReduce;
	}
	public List<Integer> getRemainC() {
		return remainC;
	}
	public void setRemainC(List<Integer> remainC) {
		this.remainC = remainC;
	}
	public ToleranceCollection getOldCTColl() {
		return oldCTColl;
	}
	public void setOldCTColl(ToleranceCollection oldCTColl) {
		this.oldCTColl = oldCTColl;
	}
	public ToleranceCollection getOldBTColl() {
		return oldBTColl;
	}
	public void setOldBTColl(ToleranceCollection oldBTColl) {
		this.oldBTColl = oldBTColl;
	}
	public DupdateCollection getOldDCategoryHash() {
		return oldDCategoryHash;
	}
	public void setOldDCategoryHash(DupdateCollection oldDCategoryHash) {
		this.oldDCategoryHash = oldDCategoryHash;
	}
	public float getTHDP_C() {
		return THDP_C;
	}
	public void setTHDP_C(float tHDP_C) {
		THDP_C = tHDP_C;
	}
	public float getTHDP_B() {
		return THDP_B;
	}
	public void setTHDP_B(float tHDP_B) {
		THDP_B = tHDP_B;
	}
	public LinkedHashMap<String, Long> getTimes() {
		return times;
	}
	public void setTimes(LinkedHashMap<String, Long> times) {
		this.times = times;
	}
	public List<Integer> reduceClone() {
		List<Integer> newreduce=new LinkedList<Integer>();
		for(int x:this.oldReduce) {
			newreduce.add(x);
		}
		return newreduce;
	}
}

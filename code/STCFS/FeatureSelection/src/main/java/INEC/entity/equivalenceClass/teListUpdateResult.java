package main.java.INEC.entity.equivalenceClass;

import java.util.HashMap;

public class teListUpdateResult {
	private HashMap<IntArrayKey,toleranceClass> add_te;//or delete_te  增加的te
	private teCollection update_te; //由Initial_te更新得到的te表
	
	public teListUpdateResult(HashMap<IntArrayKey,toleranceClass> add_te,teCollection update_te) {
		this.add_te=add_te;
		this.update_te=update_te;
	}
	public HashMap<IntArrayKey, toleranceClass> getAdd_te() {
		return add_te;
	}
	public void setAdd_te(HashMap<IntArrayKey, toleranceClass> add_te) {
		this.add_te = add_te;
	}
	public teCollection getUpdate_te() {
		return update_te;
	}
	public void setUpdate_te(teCollection update_te) {
		this.update_te = update_te;
	}
	public int size() {
		return this.add_te.size()+this.update_te.size();
	}
}

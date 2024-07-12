package main.java.INEC.entity.equivalenceClass;

import java.util.HashMap;
import java.util.Map.Entry;
import java.util.Set;

public class teCollection {
	// 初始te表结构 Initial_te/update_te
	private HashMap<IntArrayKey, toleranceClass> Complete;
	private HashMap<IntArrayKey, toleranceClass> Incomplete;

	public teCollection() {
	}

	public teCollection(int Size) {
		Complete = new HashMap<>(Size);
		Incomplete = new HashMap<>(Size);
	}

	public teCollection(HashMap<IntArrayKey, toleranceClass> Complete,
			HashMap<IntArrayKey, toleranceClass> Incomplete) {
		this.Complete = Complete;
		this.Incomplete = Incomplete;
	}

	public HashMap<IntArrayKey, toleranceClass> getIncomplete() {
		return Incomplete;
	}

	public void setIncomplete(HashMap<IntArrayKey, toleranceClass> incomplete) {
		Incomplete = incomplete;
	}

	public HashMap<IntArrayKey, toleranceClass> getComplete() {
		return Complete;
	}

	public void setComplete(HashMap<IntArrayKey, toleranceClass> complete) {
		Complete = complete;
	}

	public void addnewAll(teCollection teList) {
		this.Complete.putAll(teList.getComplete());
		this.Incomplete.putAll(teList.getIncomplete());
	}

	// 当add_te时判断将新te添加到表内TE
	public boolean addnewFriend(toleranceClass te, boolean is_Incomplete) {
		Set<Entry<IntArrayKey, toleranceClass>> Set;
		if (is_Incomplete)
			Set = this.getIncomplete().entrySet();
		else
			Set = this.getComplete().entrySet();
		for (Entry<IntArrayKey, toleranceClass> entry : Set) {
			toleranceClass te2 = entry.getValue();
			if (te.tolerateEqual(te2.getValue())) {
				if (!te.getTE().contains(te2) && !te.equals(te2))
					te.getTE().add(te2);
				if (!te2.getTE().contains(te) && !te.equals(te2))
					te2.getTE().add(te);
				if (te2.gettDec() != te.gettDec()) {
					te.settDec(-1);
					te.settCnst(-1);
					te2.settDec(-1);
					te2.settCnst(-1);
				}
			}
		}
		return true;
	}

	public int size() {
		return this.Complete.size() + this.Incomplete.size();
	}
}

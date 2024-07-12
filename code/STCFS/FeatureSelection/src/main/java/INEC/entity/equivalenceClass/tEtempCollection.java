package main.java.INEC.entity.equivalenceClass;

import java.util.HashMap;

public class tEtempCollection {
	private HashMap<IntArrayKey,tE> Complete;
	private HashMap<IntArrayKey,tE> Incomplete;
	
	public tEtempCollection() {}
	public tEtempCollection(int Size) {
		Complete=new HashMap<>(Size);
		Incomplete=new HashMap<>(Size);
	}
	public tEtempCollection(HashMap<IntArrayKey,tE> Complete,HashMap<IntArrayKey,tE> Incomplete) {
		this.Complete=Complete;
		this.Incomplete=Incomplete;
	}
	
	public HashMap<IntArrayKey, tE> getComplete() {
		return Complete;
	}
	public void setComplete(HashMap<IntArrayKey, tE> complete) {
		Complete = complete;
	}
	public HashMap<IntArrayKey, tE> getIncomplete() {
		return Incomplete;
	}
	public void setIncomplete(HashMap<IntArrayKey, tE> incomplete) {
		Incomplete = incomplete;
	}
	
	
}

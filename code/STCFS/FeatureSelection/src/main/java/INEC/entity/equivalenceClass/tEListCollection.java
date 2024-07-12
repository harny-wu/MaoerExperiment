package main.java.INEC.entity.equivalenceClass;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;

public class tEListCollection {
	private LinkedHashMap<IntArrayKey,ArrayList<tE>> Effective;
	private LinkedHashMap<IntArrayKey,ArrayList<tE>> Ineffective;
	public tEListCollection() {
		Effective=new LinkedHashMap<IntArrayKey,ArrayList<tE>>();
		Ineffective=new LinkedHashMap<IntArrayKey,ArrayList<tE>>();
	}
	public tEListCollection(LinkedHashMap<IntArrayKey,ArrayList<tE>> Effective,LinkedHashMap<IntArrayKey,ArrayList<tE>> Ineffective) {
		this.Effective=Effective;
		this.Ineffective=Ineffective;
	}
	public LinkedHashMap<IntArrayKey, ArrayList<tE>> getEffective() {
		return Effective;
	}
	public void setEffective(LinkedHashMap<IntArrayKey, ArrayList<tE>> effective) {
		Effective = effective;
	}
	public LinkedHashMap<IntArrayKey, ArrayList<tE>> getIneffective() {
		return Ineffective;
	}
	public void setIneffective(LinkedHashMap<IntArrayKey, ArrayList<tE>> ineffective) {
		Ineffective = ineffective;
	}
	public int size() {
		return this.Effective.size()+this.Ineffective.size();
	}
}

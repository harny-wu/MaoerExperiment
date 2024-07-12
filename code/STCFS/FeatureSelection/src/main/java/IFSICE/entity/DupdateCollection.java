package main.java.IFSICE.entity;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Set;

import main.basic.model.Sample;

import java.util.Map.Entry;

//更新后的U`/D集合
public class DupdateCollection {
	private HashMap<Integer,DupdateClass> Dupdate;//Integer为DValue
	
	public DupdateCollection(int size) {
		this.Dupdate=new HashMap<Integer,DupdateClass>(size);
	}
	public DupdateCollection(HashMap<Integer,DupdateClass> Dupdate) {
		this.Dupdate=Dupdate;
	}

	public HashMap<Integer, DupdateClass> getDupdate() {
		return Dupdate;
	}

	public void setDupdate(HashMap<Integer, DupdateClass> dupdate) {
		Dupdate = dupdate;
	}
	//添加Dvalue集合
	public void putDvalue(int Dvalue,DupdateClass dclass) {
		this.Dupdate.put(Dvalue, dclass);
	}
	public DupdateCollection clone() {
		HashMap<Integer,DupdateClass> newDupdateHash=(HashMap<Integer,DupdateClass>)this.Dupdate.clone();
		DupdateCollection newdupdate=new DupdateCollection(newDupdateHash);
		return newdupdate;
	}
	
	public void output() {
		Set<Entry<Integer,DupdateClass>> entryset=this.Dupdate.entrySet();
		for(Entry<Integer,DupdateClass> entrykey:entryset) {
			System.out.print("DValue-"+entrykey.getKey());
			System.out.print("DCategory="+entrykey.getValue().getCategory()+",U/Dj={");
			for(Sample x:entrykey.getValue().getList()) 
				System.out.print(x.getName()+",");
			System.out.println("}");
		}
	}
}

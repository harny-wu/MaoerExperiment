package main.java.DIDS.entity;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

public class ToleranceCollection {
	private Map<Integer, Collection<ToleranceClass>> TColl;  //Integer为属性，Collection为在属性attr下所有属性值包含的x
	
	public ToleranceCollection(int size) {
		this.TColl=new HashMap<Integer, Collection<ToleranceClass>>(size);
	}
	public void set(int attribute, Collection<ToleranceClass> tolerance) {
		TColl.put(attribute, tolerance);
	}
	public Collection<ToleranceClass> getTCbyattriubte(int attribute){
		return this.TColl.get(attribute);
	}
	public boolean containsAttribute(int attribute) {
		return TColl.containsKey(attribute);
	}
	public Map<Integer, Collection<ToleranceClass>> getTColl() {
		return TColl;
	}
	public void setTColl(Map<Integer, Collection<ToleranceClass>> tColl) {
		TColl = tColl;
	}
	public void outPut() {		
		Set<Entry<Integer,Collection<ToleranceClass>>> entryset=this.TColl.entrySet();		
		for(Entry<Integer,Collection<ToleranceClass>> entrykey:entryset) {
			System.out.print("T("+entrykey.getKey().toString()+")={");
			for(ToleranceClass tc:entrykey.getValue()) 
				System.out.print(tc.toString());
			System.out.println("}");
		}
	}
	
}

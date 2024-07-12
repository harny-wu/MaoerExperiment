package main.java.IFSICE.entity;

import java.util.ArrayList;
import main.basic.model.Sample;

//更新后的U`/D中的Dj
public class DupdateClass {
	private int category;  //1为Ej∪Fj;  2为Ej;  3为F j-d+r
	private ArrayList<Sample> list;  
	
	public DupdateClass(int category,int listSize) {
		this.category=category;
		this.list=new ArrayList<Sample>(listSize);
	}
	public DupdateClass(int category,ArrayList<Sample> list) {
		this.category=category;
		this.list=list;
	}
	public int getCategory() {
		return category;
	}
	public void setCategory(int category) {
		this.category = category;
	}
	public ArrayList<Sample> getList() {
		return list;
	}
	public void setList(ArrayList<Sample> list) {
		this.list = list;
	}
	public DupdateClass clone() {
		DupdateClass newduc=new DupdateClass(this.category,(ArrayList<Sample>)this.list.clone());
		return newduc;
	}
}

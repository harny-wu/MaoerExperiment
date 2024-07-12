package main.java.INEC.entity.equivalenceClass;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;
import main.basic.model.Sample;

//等价类te定义
public class toleranceClass {
//	private String name;
	//private HashMap<Integer,Integer> value; //te.value <属性名，属性值>
	private int[] value;
	private LinkedList<Sample> member;    
	private int count;                    //包含对象的个数
	private int cnst=1;                   //添加进的x.DValue与te.dec不相同为-1，默认为1
	private int dec;                   //相同的DValue，不同为“/”
	private LinkedList<toleranceClass> TE;        //te的容差类，除*外与te.value的值完全相同
	private int tDec;                  //包括等价类和TE在内的所有等价类的dec
	private int tCnst;                    //包括等价类和TE在内所有等价类的一致性
	
	public toleranceClass() {
		
	}	
    public toleranceClass(int[] value,Sample onemember,int count,int cnst,int dec,LinkedList<toleranceClass> TE,int tDec,int tCnst) {
		this.value=value;
		this.member=new LinkedList<Sample>();
		this.member.add(onemember);
		//this.member=member;
		this.count=count;
		this.cnst=cnst;
		this.dec=dec;
		this.TE=TE;
		this.tDec=tDec;
		this.tCnst=tCnst;
	}	

	public int[] getValue() {
		return value;
	}
	public void setValue(int[] value) {
		this.value = value;
	}
	public LinkedList<Sample> getMember() {
		return member;
	}
	public void setMember(LinkedList<Sample> member) {
		this.member = member;
	}
	public int getCount() {
		return count;
	}
	public void setCount(int count) {
		this.count = count;
	}
	public int getCnst() {
		return cnst;
	}
	public void setCnst(int cnst) {
		this.cnst = cnst;
	}
	public int getDec() {
		return dec;
	}
	public void setDec(int dec) {
		this.dec = dec;
	}
	public LinkedList<toleranceClass> getTE() {
		return TE;
	}
	public void setTE(LinkedList<toleranceClass> tE) {
		TE = tE;
	}
	public int gettDec() {
		return tDec;
	}
	public void settDec(int tDec) {
		this.tDec = tDec;
	}
	public int gettCnst() {
		return tCnst;
	}
	public void settCnst(int tCnst) {
		this.tCnst = tCnst;
	}
	public boolean istetCnst() {
		return this.tCnst==1;
	}
	
	public IntArrayKey getteValue() {
		return new IntArrayKey(this.value);
	}
	//根据给出的属性名称得到属性值
	public int getAttributeValue(int attributeNameList) {
		return this.getValue()[attributeNameList];
	}
	//根据给出的属性名称列表得到属性值
	public int[] getBValue(int[] attributeNameList) {
		if (attributeNameList.length==0)
			return new int[0];
		int[] AttrValue=new int[attributeNameList.length];
		for(int i=0;i<attributeNameList.length;i++) 
			AttrValue[i]=this.value[attributeNameList[i]];		
		return AttrValue;
	}
	public List<Integer> getBValuetoList(int[] attributeNameList) {
		List<Integer> AttrValue=new ArrayList<Integer>(attributeNameList.length);
		for(int i=0;i<attributeNameList.length;i++) {
			int attrName=attributeNameList[i];
			AttrValue.add(this.value[attrName]);
		}
		return AttrValue;
	}
	//判断给出的属性名称列表对应的te.value是否有Incomplete
	public boolean is_BValueIncomplete(int[] attributeNameList) {
		if (attributeNameList.length==0)
			return false;		
		for(int i=0;i<attributeNameList.length;i++) 
			if(this.value[attributeNameList[i]]==-1)
				return true;
		
		return false;
	}
	//判断te值与tE值是否相同
	public boolean is_teValueEuqaltEValue(tE tE,int[] attributeNameList) {
		for(int i=0;i<attributeNameList.length;i++) {
			if(tE.getValue().get(attributeNameList[i])!=this.value[attributeNameList[i]])
				return false;
		}
		return true;
//		Set<Entry<Integer,Integer>> tEValues=tE.getValue().entrySet();
//		for(Entry<Integer,Integer> entry:tEValues) {
//			if(entry.getValue()!=this.value[entry.getKey()])
//				return false;
//		}
//		return true;
	}
	
	//将te2.TE表中不存在的te增加到本te.tE
	public void addNotContaintE(LinkedList<toleranceClass> TE) {
		for(toleranceClass te:TE) {
			if(!this.getTE().contains(te)&&!this.getteValue().equals(te.getteValue()))
				this.getTE().add(te);
		}
		
	}
	//判断除*之外其他值都相同
	public boolean tolerateEqual(int[] te2_value) {
		for(int i=0;i<this.value.length;i++) 		
			if (value[i]!=-1&&te2_value[i]!=-1)
				if (value[i]!=te2_value[i]) 
					return false;
		return true;
	}
	
	public boolean is_Incomplete() {
		for(int a:this.value)
			if(a==-1)
				return true;
		return false;
	}
	
	public String toString() {
		StringBuilder str=new StringBuilder();
		str.append(this.getteValue()+"  ");
		//str.append(this.getMember().size());
		for(Sample a:this.getMember()) 
			str.append(a.getName()+" ");
		str.append("  "+this.getCount());
		str.append("  "+this.getCnst());
		str.append("  "+this.getDec());
		str.append("  TE:"+this.getTE().size());
		str.append("  TE:");			
		for(toleranceClass a:this.getTE()) 
			str.append(a.getteValue());
		str.append("  "+this.gettDec());
		str.append("  "+this.gettCnst());
		return str.toString();
	}
}

package main.java.INEC.entity.equivalenceClass;

import java.util.ArrayList;
import java.util.LinkedList;

//等价类表，包含te
public class tE {
	private ArrayList<Integer> value; // <属性名下标，属性值> 从HashMap<Integer,Integer>转为LinkedList<Integer>
	private LinkedList<toleranceClass> member;
	// private LinkedList<Integer> member;
	private int count; // member中te.count相加,用于计算正域POS
	private int cnst; // 当member.cnst都为1且dec相等时=1；当member.cnst都为-1时= -1；其余情况为0
	private int dec; // 相同的member.DValue，不同为“/”
	private boolean m_tCnst; // 存在tE.member.tCnst==1
	private LinkedList<toleranceClass> TE; // te的tolerate类，除*外与te.value的值完全相同
	// private LinkedList<Integer> TE;
	private int tCount;
	private int tDec; // 包括等价类和TE在内的所有等价类的dec
	private int tCnst; // 包括等价类和TE在内所有等价类的一致性
	private boolean isEmpty = true;

	public tE() {
		this.member = new LinkedList<toleranceClass>();
		this.isEmpty = true;
	}

	public tE(ArrayList<Integer> value, toleranceClass onemember, int count, int cnst, int dec, boolean m_tCnst,
			LinkedList<toleranceClass> TE, int tCount, int tDec, int tCnst) {
		this.value = value;
		this.member = new LinkedList<toleranceClass>();
		this.member.add(onemember);
		// this.member=member;
		this.count = count;
		this.cnst = cnst;
		this.dec = dec;
		this.m_tCnst = m_tCnst;
		this.TE = TE;
		this.tCount = tCount;
		this.tDec = tDec;
		this.tCnst = tCnst;
		this.isEmpty = false;
	}
//	public tE(HashMap<Integer,Integer> value,LinkedList<Integer> member,int count,int cnst,int dec,boolean m_tCnst,LinkedList<Integer> TE,int tCount,int tDec,int tCnst) {
//		this.value=value;
//		this.member=member;
//		this.count=count;
//		this.cnst=cnst;
//		this.dec=dec;
//		this.m_tCnst=m_tCnst;
//		this.TE=TE;
//		this.tCount=tCount;
//		this.tDec=tDec;
//		this.tCnst=tCnst;
//	}

	public ArrayList<Integer> getValue() {
		return value;
	}

	public void setValue(ArrayList<Integer> value) {
		this.value = value;
	}

	public LinkedList<toleranceClass> getMember() {
		return member;
	}

	public void setMember(LinkedList<toleranceClass> member) {
		this.member = member;
	}

	public void addMember(LinkedList<toleranceClass> member) {
		this.member.addAll(member);
	}

//	public LinkedList<Integer> getMember() {
//		return member;
//	}
//	public void setMember(LinkedList<Integer> member) {
//		this.member = member;
//		}
//	public void addMember(LinkedList<Integer> member) {
//		this.member.addAll(member);
//		}
	public int getCount() {
		return count;
	}

	public void setCount(int count) {
		this.count = count;
	}

	public int addCount(int count1) {
		this.count += count1;
		return count;
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

	public boolean isM_tCnst() {
		return m_tCnst;
	}

	public void setM_tCnst(boolean m_tCnst) {
		this.m_tCnst = m_tCnst;
	}

	public LinkedList<toleranceClass> getTE() {
		return TE;
	}

	public void setTE(LinkedList<toleranceClass> tE) {
		TE = tE;
	}

//	public LinkedList<Integer> getTE() {
//		return TE;
//	}
//	public void setTE(LinkedList<Integer> tE) {
//		TE = tE;
//	}
//	public LinkedList<Integer> addTE(LinkedList<Integer> tE1) {
//		if(tE1!=null)
//			TE.addAll(tE1);
//		return TE;
//	}
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

	public int gettCount() {
		return tCount;
	}

	public void settCount(int tCount) {
		this.tCount = tCount;
	}

	public int addtCount(int count1) {
		this.tCount += count1;
		return tCount;
	}

	public IntArrayKey gettEValue() {
		// int[] tEvalue=new int[value.size()];
//		Set<Entry<Integer,Integer>> keySet=this.getValue().entrySet();
//		int i=0;
//		for(Entry<Integer,Integer> entry:keySet) {
//			//if(!entry.getKey().equals(0)) {
//				tEvalue[i]=entry.getValue();
//				i++;
//			//}
//		}
		int[] tEvalue = this.value.stream().mapToInt(Integer::valueOf).toArray();
		return new IntArrayKey(tEvalue);
	}

	// 获取tE中所有x的个数
	public int countAllSample() {
		int size = 0;
		for (toleranceClass te : this.getMember()) {
			size += te.getMember().size();
		}
		return size;
	}

	// 将tE2.TE表中不存在的te增加到本tE.tE
	public void addNotContaintE(LinkedList<toleranceClass> TE) {
		for (toleranceClass te : TE) {
			if (!this.getTE().contains(te))
				this.getTE().add(te);
		}
	}

	// 判断除*之外其他值都相同
//	public boolean tolerateEqual(HashMap<Integer,Integer> te2_value) {
//		boolean flag=true;
//		Set<Entry<Integer,Integer>> KeySet=this.value.entrySet();
//		for(Entry<Integer,Integer> entry: KeySet) {
//			int value1=Integer.valueOf(entry.getValue());
//			int value2=Integer.valueOf(te2_value.get(entry.getKey()));
//			if (value1!=-1&&value2!=-1){
//				if (value1!=value2) {
//					flag=false;
//					return flag;
//				}
//			}
//		}
//		return flag;
//	}
	public boolean tolerateEqual(ArrayList<Integer> te2_value) {
		for (int i = 0; i < this.value.size(); i++) {
			int value1 = this.value.get(i);
			int value2 = te2_value.get(i);
			if (value1 != -1 && value2 != -1) {
				if (value1 != value2) {
					return false;
				}
			}
		}
		return true;
	}

	public String toString() {
		StringBuilder str = new StringBuilder();
		str.append(this.gettEValue() + "  ");
		str.append(this.getMember().size());
//		for(sample a:tE.getMember()) 
//			str.append(a.getName());
		// str.append(" "+this.gettEValue());
		str.append("  " + this.getCount());
		str.append("  " + this.getCnst());
		str.append("  " + this.getDec());
		str.append("  " + this.isM_tCnst());
		str.append("  " + this.gettCount());
		// str.append(" "+this.gettEValue());
		// str.append(" "+this.gettEValue());
		str.append("  TE:" + this.getTE().size());
		str.append("  TE:");
//		for(toleranceClass a:this.getTE()) 
//			str.append(a.getteValue());
		str.append("  " + this.gettDec());
		str.append("  " + this.gettCnst());
		return str.toString();
	}

	public boolean isEmpty() {
		return this.isEmpty;
	}

}

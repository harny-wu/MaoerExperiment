package main.java.KGIRA.entity;

public class Significance {
	private int attribute;   //单个属性
	private int[] B;
	private float Sig=Integer.MIN_VALUE;
	private boolean is_inner;   //if false则outer
	
	public Significance() {}
	public Significance(int attribute,int[] B) {
		this.attribute=attribute;
		this.B=B;
	}
	
	public int getAttribute() {
		return attribute;
	}
	public void setAttribute(int attribute) {
		this.attribute = attribute;
	}
	public int[] getB() {
		return B;
	}
	public void setB(int[] b) {
		B = b;
	}
	public float getSig() {
		return Sig;
	}
	public void setSig(float sig) {
		Sig = sig;
	}
	public boolean isIs_inner() {
		return is_inner;
	}
	public void setIs_inner(boolean is_inner) {
		this.is_inner = is_inner;
	}
	//重要度计算
	public float calculateSig_common(boolean is_inner,int USize,ToleranceCollection initialTColl,ToleranceCollection newTColl) {
		this.is_inner=is_inner;
		float sig;
		if(is_inner)   //true则inner  求B-{a}
			sig=((float)1/(USize*USize))*Math.abs((Math.abs(newTColl.getTotalNotDNumber())-Math.abs(newTColl.getTotalDNumber()))-(Math.abs(initialTColl.getTotalNotDNumber())-Math.abs(initialTColl.getTotalDNumber())));
		else 
			sig=((float)1/(USize*USize))*Math.abs((Math.abs(initialTColl.getTotalNotDNumber())-Math.abs(initialTColl.getTotalDNumber()))-(Math.abs(newTColl.getTotalNotDNumber())-Math.abs(newTColl.getTotalDNumber())));
		this.Sig=sig;		
		return this.Sig;
	}
	public float calculateSig_update(boolean is_inner,int USize,int newUSize,float initial_GP_B,float new_GP_B) {
		this.is_inner=is_inner;
		float sig;
		if(is_inner)   //true则inner  求B-{a}
			sig=new_GP_B-initial_GP_B;
		else 
			sig=initial_GP_B-new_GP_B;
		this.Sig=sig;		
		return this.Sig;
	}
}

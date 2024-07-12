package main.java.FSSNC.entity;

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
//	public float calculateSig_common(boolean is_inner,int USize,DstrippedCover initialCover,DstrippedCover newCover) {
//		this.is_inner=is_inner;
//		float sig;
//		float eB=0,eBremoveA=0;
//		if(is_inner)   //true则inner  求B-{a}
//			sig=0;
//		else {			
//			for(int i=0;i<initialCover.getTotalNotDNumber().length;i++) {
//				if(initialCover.getTotalNotDNumber()[i]!=0)
//				eB+=((initialCover.getTotalNotDNumber()[i]-initialCover.getTotalDNumber()[i])/(float)initialCover.getTotalNotDNumber()[i]);
//			}
//			eB=(1/(float)USize)*eB;
//			for(int i=0;i<newCover.getTotalNotDNumber().length;i++) {
//				if(newCover.getTotalNotDNumber()[i]!=0)
//					eBremoveA+=((newCover.getTotalNotDNumber()[i]-newCover.getTotalDNumber()[i])/(float)newCover.getTotalNotDNumber()[i]);
//			}
//			eBremoveA=(1/(float)USize)*eBremoveA;
//		}
//		this.Sig=eB-eBremoveA;		
//		return this.Sig;
//	}
	public float calculateSig_common(boolean is_inner,int USize,DstrippedCover initialCover,DstrippedCover newCover) {
		this.is_inner=is_inner;
		float sig;
		if(is_inner)   //true则inner  求B-{a}
			sig=newCover.geteBvalue()-initialCover.geteBvalue();
		else {			
			sig=initialCover.geteBvalue()-newCover.geteBvalue();
		}
		this.Sig=sig;		
		return this.Sig;
	}
}

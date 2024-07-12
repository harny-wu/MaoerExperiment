package main.java.INEC.entity.equivalenceClass;

import java.util.ArrayList;
import java.util.Map.Entry;
import java.util.Set;

//属性重要度
public class Significance {
	private int attribute; // 单个属性
	private int[] B = new int[1];
	private float certainlyValue = Integer.MIN_VALUE;
	private float uncertainlyValue = Integer.MAX_VALUE;
	private int POS = -1;
	// private float DSameProportion=0;
	// //计算在增加属性attribute后ineffective中“所有朋友的D和tcnst=1的te的D相同”的比例
	private int one = -1;
	private int minusone = -1;
	private float zero = -1;
	private float sigcriterion = 0;
	// private float fronttCount=0;

	public Significance() {
	}

	public Significance(int attribute, int[] B) {
		this.attribute = attribute;
		this.B = B;
	}

	public Significance(Significance sig) { // clone
		this.attribute = sig.getAttribute();
		this.B = sig.getB();
		this.POS = sig.getPOS();
		this.one = sig.getOne();
		this.minusone = sig.getMinusone();
		this.zero = sig.getZero();
		this.sigcriterion = sig.getSigcriterion();
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

	public int getPOS() {
		return POS;
	}

	public void setPOS(int pOS) {
		POS = pOS;
	}

	public float getCertainlyValue() {
		return certainlyValue;
	}

	public void setCertainlyValue(float certainlyValue) {
		this.certainlyValue = certainlyValue;
	}

	public float getUncertainlyValue() {
		return uncertainlyValue;
	}

	public void setUncertainlyValue(float uncertainlyValue) {
		this.uncertainlyValue = uncertainlyValue;
	}
//	public float getDSameProportion() {
//		return DSameProportion;
//	}
//	public void setDSameProportion(float DSameProportion) {
//		this.DSameProportion = DSameProportion;
//	}

	public float getSigcriterion() {
		return sigcriterion;
	}

	public void setSigcriterion(float sigcriterion) {
		this.sigcriterion = sigcriterion;
	}

	public int getOne() {
		return one;
	}

	public void setOne(int one) {
		this.one = one;
	}

	public int getMinusone() {
		return minusone;
	}

	public void setMinusone(int minusone) {
		this.minusone = minusone;
	}

	public float getZero() {
		return zero;
	}

	public void setZero(float zero) {
		this.zero = zero;
	}

	// 正域计算
	public int POS(tEtempCollection tE_temp, int frontpos) {
		int pos = frontpos;
		Set<Entry<IntArrayKey, tE>> IncompleteSet = tE_temp.getIncomplete().entrySet();
		Set<Entry<IntArrayKey, tE>> CompleteSet = tE_temp.getComplete().entrySet();
		for (Entry<IntArrayKey, tE> entry1 : IncompleteSet) { // Incomplete
			tE tE = entry1.getValue();
			if (tE.gettCnst() == 1)
				pos += tE.getCount();
		}
		for (Entry<IntArrayKey, tE> entry1 : CompleteSet) { // Complete
			tE tE = entry1.getValue();
			if (tE.gettCnst() == 1)
				pos += tE.getCount();
		}
		this.POS = pos;
		return pos;
	}

	public int POS(ArrayList<tE> tE_temp, int frontpos) {
		int pos = frontpos;
		for (tE tE : tE_temp) {
			if (tE.gettCnst() == 1)
				pos += tE.getCount();
		}
		this.POS = pos;
		return pos;
	}

	// 计算1和-1作为sig
	public float Sig_threepart(tEtempCollection tE_temp, Significance frontsig) {
		float zero = frontsig.getZero();
		int one = frontsig.getOne();
		int minusone = frontsig.getMinusone();
		if (frontsig.getOne() == -1 && frontsig.getMinusone() == -1 && frontsig.getZero() == -1) {
			zero = 0;
			one = 0;
			minusone = 0;
		} else {
			zero = 0;
			one = frontsig.getOne();
			minusone = frontsig.getMinusone();
		}
		Set<Entry<IntArrayKey, tE>> IncompleteSet = tE_temp.getIncomplete().entrySet();
		Set<Entry<IntArrayKey, tE>> CompleteSet = tE_temp.getComplete().entrySet();
		for (Entry<IntArrayKey, tE> entry1 : IncompleteSet) { // Incomplete
			tE tE = entry1.getValue();
			if (tE.gettCnst() == 1)
				one += tE.getCount();
			else if (tE.gettCnst() == -1)
				minusone += tE.getCount();
			else if (tE.gettCnst() == 0)
				zero += (tE.gettCount()) * (tE.gettCount());
		}
		for (Entry<IntArrayKey, tE> entry1 : CompleteSet) { // Complete
			tE tE = entry1.getValue();
			if (tE.gettCnst() == 1)
				one += tE.getCount();
			else if (tE.gettCnst() == -1)
				minusone += tE.getCount();
			else if (tE.gettCnst() == 0)
				zero += (tE.gettCount()) * (tE.gettCount());
		}
		zero = (float) Math.sqrt(zero);
		this.zero = zero;
		this.one = one;
		this.minusone = minusone;
		this.sigcriterion = zero + one + minusone;
		this.POS = one;
		return sigcriterion;
	}

	public float Sig_threepart(ArrayList<tE> tE_temp, Significance frontsig) {
		float zero = frontsig.getZero();
		int one = frontsig.getOne();
		int minusone = frontsig.getMinusone();
		if (frontsig.getOne() == -1 && frontsig.getMinusone() == -1 && frontsig.getZero() == -1) {
			zero = 0;
			one = 0;
			minusone = 0;
		} else {
			zero = 0;
			one = frontsig.getOne();
			minusone = frontsig.getMinusone();
		}
		for (tE tE : tE_temp) {
			if (tE.gettCnst() == 1)
				one += tE.getCount();
			else if (tE.gettCnst() == -1)
				minusone += tE.getCount();
			else if (tE.gettCnst() == 0)
				zero += (tE.gettCount()) * (tE.gettCount());
		}
		zero = (float) Math.sqrt(zero);
		this.zero = zero;
		this.one = one;
		this.minusone = minusone;
		this.sigcriterion = zero + one + minusone;
		this.POS = one;
		return sigcriterion;
	}

	// 属性重要度计算（确定性与不确定性计算）
	public void significance(tEtempCollection tE_temp, float fronttCount) {
		Set<Entry<IntArrayKey, tE>> IncompleteSet = tE_temp.getIncomplete().entrySet();
		Set<Entry<IntArrayKey, tE>> CompleteSet = tE_temp.getComplete().entrySet();
		float HC = 0, HU = 0;
		for (Entry<IntArrayKey, tE> entry1 : CompleteSet) { // Complete
			tE tE = entry1.getValue();
			if (tE.gettCnst() == 1 || tE.gettCnst() == -1)
				// HC+=(tE.gettCount()/fronttCount)*Math.log(tE.gettCount()/fronttCount);
				HC += (tE.gettCount() / fronttCount);
			else // tE.tCnst==0
					// HU+=(tE.gettCount()/fronttCount)*Math.log(tE.gettCount()/fronttCount);
				HU += (tE.gettCount() / fronttCount);
		}
		for (Entry<IntArrayKey, tE> entry2 : IncompleteSet) { // Incomplete
			tE tE = entry2.getValue();
			if (tE.gettCnst() == 1 || tE.gettCnst() == -1)
				// HC+=(tE.gettCount()/fronttCount)*Math.log(tE.gettCount()/fronttCount);
				HC += (tE.gettCount() / fronttCount);
			else // tE.tCnst==0
					// HU+=(tE.gettCount()/fronttCount)*Math.log(tE.gettCount()/fronttCount);
				HU += (tE.gettCount() / fronttCount);
		}
		// HC=HC*(-1);HU=HU*(-1);
		this.setCertainlyValue(HC);
		this.setUncertainlyValue(HU);
	}

}

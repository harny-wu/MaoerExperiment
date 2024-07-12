package main.java.DIDS.algorithm;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.stream.Collectors;

import main.Log4jPrintStream;
import main.basic.model.Sample;
import main.java.DIDS.entity.IntArrayKey;
import main.java.DIDS.entity.Significance;
import main.java.DIDS.entity.StaticReduceResult;
import main.java.DIDS.entity.ToleranceClass;
import main.java.DIDS.entity.ToleranceClassandIDegreeResult;
import main.java.DIDS.entity.ToleranceCollection;

public class DIDS {
	static {
		Log4jPrintStream.redirectSystemOut();
	}

	// 找到一个属性attribute下的所有非*的属性值对应的x集合
	public List<Sample> findNotMissingValueCollofAttribute(Collection<Sample> U, int attributeindex) {
		List<Sample> list = new ArrayList<Sample>();
		for (Sample x : U)
			if (x.getAttributeValueByIndex(attributeindex + 1) != -1)
				list.add(x);
		return list;
	}

	// 找到在U中一个属性attribute下所有属性值划分的x的集合
	public Collection<ToleranceClass> equivalenceClass(List<Sample> U, int attribute) {
		Collections.sort(U,
				(x1, x2) -> (x1.getAttributeValueByIndex(attribute + 1) - x2.getAttributeValueByIndex(attribute + 1)));
		Sample x;
		int attributeValue;
		ToleranceClass tolclass;
		Collection<ToleranceClass> tolclasses = new LinkedList<>();
		Iterator<Sample> insIterator = U.iterator();
		x = insIterator.next();
		attributeValue = x.getAttributeValueByIndex(attribute + 1);
		tolclasses.add(tolclass = new ToleranceClass(attributeValue));
		tolclass.add(x);
		while (insIterator.hasNext()) {
			x = insIterator.next();
			if (attributeValue != x.getAttributeValueByIndex(attribute + 1)) {
				attributeValue = x.getAttributeValueByIndex(attribute + 1);
				tolclasses.add(tolclass = new ToleranceClass(attributeValue));
			}
			tolclass.add(x);
		}
		return tolclasses;
	}

	// 找到U在B下所有属性的ToleranceClass集合 Uij
	public ToleranceCollection findNotMissing(Collection<Sample> U, IntArrayKey attributes) {
		ToleranceCollection notmissingSample = new ToleranceCollection(attributes.size());
		// attributes
		for (int attr : attributes.key()) {
			List<Sample> notmissinglist = findNotMissingValueCollofAttribute(U, attr);
			if (!notmissinglist.isEmpty())
				notmissingSample.set(attr, equivalenceClass(notmissinglist, attr));
		}
		return notmissingSample;
	}

	// 计算ToleranceClass TB(x)
	public Map<Sample, Collection<Sample>> obtainSampleToleranceClass(Collection<Sample> samples,
			Collection<Sample> candidates, IntArrayKey attributes, ToleranceCollection completeColl) {
//		if(attributes.size()==0)
//		return samples.stream().collect(Collectors.toMap(Function.identity(), x->new HashSet<>(candidates)));
		Map<Sample, Collection<Sample>> tolerances = new HashMap<Sample, Collection<Sample>>(samples.size());
		if (attributes.size() == 0) {
			for (Sample x : samples)
				tolerances.put(x, new HashSet<>(candidates));
			return tolerances;
		}
		Collection<Sample> tolerance;
		for (Sample x : samples) {
			tolerance = new LinkedList<>();
			Collection<Sample> toBRemoved = new HashSet<>(candidates.size());
			for (Sample candidate : candidates) {
				for (int i = 0; i < attributes.size(); i++) {
					int attr = attributes.key()[i] + 1;
					if (x.getAttributeValueByIndex(attr) == -1)
						continue;
					if (candidate.getAttributeValueByIndex(attr) == -1)
						continue;
					if (!completeColl.containsAttribute(attr - 1))
						continue;
					for (ToleranceClass tolClass : completeColl.getTColl().get(attr - 1)) {
						if (tolClass.getAttributeVlaue() != x.getAttributeValueByIndex(attr)) {
							toBRemoved.addAll(tolClass.getItems());
						}
					}
				}
			}
			if (toBRemoved.isEmpty()) {
				tolerances.put(x, new HashSet<>(candidates));
			} else if (toBRemoved.size() != candidates.size()) {
				tolerance = candidates.stream().filter(can -> !toBRemoved.contains(can)).collect(Collectors.toList());
				tolerances.put(x, tolerance);
			} else {
				// "ins" has no tolerance class.
			}
		}
		return tolerances;
	}

	// 增加一个属性下等价类更新 只更新了无D的等价类
	public Map<Sample, Collection<Sample>> ToleranceClassUpdatebyAdding1attr(
			Map<Sample, Collection<Sample>> previousTolerances, IntArrayKey attributes) { // B+{a}
		Map<Sample, Collection<Sample>> newconAttr = this.cloneMapTolerances(previousTolerances);
		int attr = attributes.key()[attributes.key().length - 1];
		for (Entry<Sample, Collection<Sample>> tolerances : newconAttr.entrySet()) {
			Sample x1 = tolerances.getKey();
			Collection<Sample> remove = new LinkedList<>();
			for (Sample x2 : tolerances.getValue())
				if (x1.getName() != x2.getName())
					if (x1.getAttributeValueByIndex(attr + 1) != -1 && x2.getAttributeValueByIndex(attr + 1) != -1
							&& x1.getAttributeValueByIndex(attr + 1) != x2.getAttributeValueByIndex(attr + 1)) {
						remove.add(x2);
						if (newconAttr.containsKey(x2))
							newconAttr.get(x2).remove(x1);
					}
			tolerances.getValue().removeAll(remove);
		}
		// ToleranceClassandIDegreeResult
		// TCResult=toleranceClassConsideringDecisionValueWithIDegree(newTCResult.getToleranceClassesOfCondAttrs());
		return newconAttr;
	}

	// 同时计算iDegree
	public ToleranceClassandIDegreeResult toleranceClassConsideringDecisionValueWithIDegree(
			Map<Sample, Collection<Sample>> toleranceClasses) {
		float iDegree = 0;
		final Map<Sample, Collection<Sample>> result = new HashMap<>(toleranceClasses.size());
		for (Entry<Sample, Collection<Sample>> entry : toleranceClasses.entrySet()) {
			int decisionValue = entry.getKey().getDecisionValues();
			Collection<Sample> tolerance = entry.getValue().stream()
					.filter(ins -> ins.getDecisionValues() == decisionValue).collect(Collectors.toList());
			result.put(entry.getKey(), tolerance);
			iDegree += (float) Math.abs((entry.getValue().size() - tolerance.size())) / 2;
		}
		return new ToleranceClassandIDegreeResult(toleranceClasses, result, iDegree);
	}

	// 总流程——计算ToleranceClass TB(x) and TB∪D(X) for all x∈U and iDegree
	public ToleranceClassandIDegreeResult calculateTolerances(Collection<Sample> samples, Collection<Sample> candidates,
			IntArrayKey attributes,ToleranceCollection TColl) {
		//ToleranceCollection TColl = findNotMissing(samples, attributes);
		Map<Sample, Collection<Sample>> tolerances = obtainSampleToleranceClass(samples, candidates, attributes, TColl);
		ToleranceClassandIDegreeResult TCResult = toleranceClassConsideringDecisionValueWithIDegree(tolerances);
		return TCResult;
	}

	// 使tolerances中sample1和sample2的等价类添加一致
	public void maintainSymmetricTolerance(Map<Sample, Collection<Sample>> tolerances, Sample ins1, Sample ins2) {
		Collection<Sample> toleranceOfIns1 = tolerances.get(ins1);
		if (toleranceOfIns1 == null) {
			tolerances.put(ins1, toleranceOfIns1 = new HashSet<>());
			toleranceOfIns1.add(ins1);
		}
		toleranceOfIns1.add(ins2);
		Collection<Sample> toleranceOfIns2 = tolerances.get(ins2);
		if (toleranceOfIns2 == null) {
			tolerances.put(ins2, toleranceOfIns2 = new HashSet<>());
			toleranceOfIns2.add(ins2);
		}
		toleranceOfIns2.add(ins1);
	}

	// 判断两个属性在B上是否容差
	public boolean tolerant(Sample x1, Sample x2, IntArrayKey attributes) {
		// ---------------------------------------------------------------
		// | T(B)={(x,y)∈U×U|∀b∈B,f(x,b)=f(y,b)∨f(x,b)=∗∨f(y,b)=∗} |
		// ---------------------------------------------------------------
		for (int i = 0; i < attributes.size(); i++) {
			int attr = attributes.key()[i] + 1;
			int attrV1 = x1.getAttributeValueByIndex(attr), attrV2 = x2.getAttributeValueByIndex(attr);
			if (attrV1 == attrV2) {
				continue;
			} else if (attrV1 == -1) {
				continue;
			} else if (attrV2 == -1) {
				continue;
			} else {
				return false;
			}
		}
		return true;
	}

	// 计算属性重要度
	// 原文中重要度计算利用inconsistency degree计算sig 0<sig<1
	public Significance calculateSignificance(int attribute, IntArrayKey B, boolean is_inner, float initialiDegree,
			float newiDegree) {
		Significance sig = new Significance(attribute, B.key());
		if (!is_inner)
			sig.setSig(initialiDegree - newiDegree);
		else
			sig.setSig(newiDegree - initialiDegree);
		return sig;
	}

	// 冗余检验
	public boolean redundancy(int attribute, IntArrayKey Reduce, Collection<Sample> U,
			ToleranceClassandIDegreeResult BTCResult,ToleranceCollection TColl) {
		IntArrayKey newAttr = new IntArrayKey(Reduce.key().clone());
		newAttr.deleteKey(attribute);
		ToleranceClassandIDegreeResult tempTCResult = calculateTolerances(U, U, newAttr,TColl);
		Significance sig = calculateSignificance(attribute, newAttr, true, BTCResult.getiDegree(),
				tempTCResult.getiDegree());
		if (sig.getSig() == 0) {
			BTCResult = tempTCResult;
			return true;
		}
		return false;
	}

	// 静态约简
	public StaticReduceResult staticReduce_DIDS(Collection<Sample> U, int CSize) {
		System.out.println("||静态约简开始");
		List<Integer> Reduce = new LinkedList<>();
		IntArrayKey C = new IntArrayKey(CSize);
		LinkedHashMap<String, Long> times = new LinkedHashMap<>(10);

		long start = System.currentTimeMillis();
		ToleranceCollection TColl = findNotMissing(U, C);
		ToleranceClassandIDegreeResult CTCResult = calculateTolerances(U, U, C,TColl);
		long end = System.currentTimeMillis();
		System.out.println("||全C下的等价类计算&iDegree(C)=" + CTCResult.getiDegree() + ",时间:" + (end - start) + "ms,"
				+ (double) (end - start) / 1000 + "s");
		times.put("computeEquivalenceClassofC", end - start);
		// CTCResult.iDegreeOutPut();

		ToleranceClassandIDegreeResult tempTCResult;
		List<Integer> remainC = Arrays.stream(C.key()).boxed().collect(Collectors.toList());
		List<Integer> delete = new ArrayList<Integer>(C.key().length);

		start = System.currentTimeMillis();
		for (int i = 0; i < CSize; i++) {
			int attr = C.key()[i];
			IntArrayKey temp = new IntArrayKey(C.key().clone());
			temp.deleteKey(attr);
			tempTCResult = calculateTolerances(U, U, temp,TColl);
			// tempPos.posOutPut();
			Significance a_sig = calculateSignificance(attr, C, true, CTCResult.getiDegree(),
					tempTCResult.getiDegree());
			// System.out.print("sig="+a_sig.getSig()+" ");
			if (a_sig.getSig() > 0) {
				Reduce.add(attr);
				delete.add(i);
			}
		}
		end = System.currentTimeMillis();
		System.out.println(
				"||求核计算&初始Reduce={" + Reduce + "},时间：" + (end - start) + "ms," + (double) (end - start) / 1000 + "s");
		times.put("computeCore", end - start);

		// System.out.println("初始Reduce="+Reduce.toString());
		IntArrayKey ReduceKey = new IntArrayKey(Reduce.stream().mapToInt(Integer::valueOf).toArray());
		remainC.removeAll(delete);
		// System.out.println("remainC="+remainC.toString());

		start = System.currentTimeMillis();
		ToleranceClassandIDegreeResult ReduceTCResult = calculateTolerances(U, U, ReduceKey,TColl);
		end = System.currentTimeMillis();
		System.out.println("||B下的等价类计算&iDegree(B)=" + ReduceTCResult.getiDegree() + ",时间:" + (end - start) + "ms,"
				+ (double) (end - start) / 1000 + "s");
		times.put("computeEquivalenceClassofB", end - start);
		// ReduceTCResult.iDegreeOutPut();

		ToleranceClassandIDegreeResult maxTCResult = ReduceTCResult;
		Significance max_sig = new Significance();
		int max_a = -1;
		int j = -1;

		start = System.currentTimeMillis();
		while (CTCResult.getiDegree() != ReduceTCResult.getiDegree()) {
			max_sig = new Significance();
			for (int i = 0; i < remainC.size(); i++) {
				int attr = remainC.get(i);
				IntArrayKey temp = new IntArrayKey(ReduceKey.key().clone());
				temp.addKey(attr);
				tempTCResult = calculateTolerances(U, U, temp,TColl);
				// tempTCResult.iDegreeOutPut();
				Significance a_sig = calculateSignificance(attr, ReduceKey, false, ReduceTCResult.getiDegree(),
						tempTCResult.getiDegree());
				// System.out.println("属性"+i+"的sig="+a_sig.getSig()+" ");
				if (a_sig.getSig() > max_sig.getSig()) {
					max_a = attr;
					maxTCResult = tempTCResult;
					max_sig = a_sig;
					j = i;
				}
			}
			Reduce.add(max_a);
			ReduceKey.addKey(max_a);
			ReduceTCResult = maxTCResult;
			remainC.remove(j);
			// System.out.print("最优属性："+max_a+"iDegree:"+ReduceTCResult.getiDegree()+"
			// 约简："+Reduce.toString()+" ");
			// System.out.println("remainC="+remainC.toString());
			System.out.println("||最优特征{" + max_a + "}&iDegree(B+{" + max_a + "})=" + ReduceTCResult.getiDegree());
		}
		end = System.currentTimeMillis();
		System.out.println("||迭代时间：" + (end - start) + "ms," + (double) (end - start) / 1000 + "s");
		times.put("iteration", end - start);
		// 冗余检验 无
//		for(int i=0;i<Reduce.size();i++) {  //删除冗余属性
//			int a=Reduce.get(i);
//			boolean redundancy=redundancy(a, ReduceKey,U,ReduceTCResult);
//			if(redundancy) {
//				Reduce.remove(i);
//				ReduceKey.deleteKey(a);
//				i--;
//				remainC.add(a);
//				System.out.print("删除属性："+a+" ");
//			}				
//		}
		long alltime = 0;
		for (long i : times.values())
			alltime += i;
		System.out.println("||最终约简Reduce={" + Reduce + "},约简数量=" + Reduce.size());
		System.out.println("||总时间：" + alltime + "ms," + (double) (alltime) / 1000 + "s");

		StaticReduceResult result = new StaticReduceResult(CTCResult, ReduceTCResult, Reduce, times);
		return result;
	}

	// object update
	public Map<Sample, Collection<Sample>> toleranceClassUpdatebyObject(Collection<Sample> U, Collection<Sample> newU,
			IntArrayKey attributes, Map<Sample, Collection<Sample>> tolerancesOfInvariances,ToleranceCollection variancesTColl ) {
		Map<Sample, Collection<Sample>> tolerancesOfCombined = new HashMap<>(U.size() + newU.size());
		//ToleranceCollection variancesTColl = findNotMissing(newU, attributes);
		Map<Sample, Collection<Sample>> tolerancesOfVariances = obtainSampleToleranceClass(newU, newU, attributes,
				variancesTColl);
		tolerancesOfCombined.putAll(tolerancesOfInvariances);
		tolerancesOfCombined.putAll(tolerancesOfVariances);
		Map<Sample, Collection<Sample>> additionalTolerances = obtainSampleToleranceClass(U, newU, attributes,
				variancesTColl);
		// Collection<Sample> invariancesUpdated = additionalTolerances.keySet();
		// Collection<Sample> variancesUpdated = new HashSet<>(newU.size());
		for (Entry<Sample, Collection<Sample>> extraInvariancesEntry : additionalTolerances.entrySet()) {
			// Maintain U'/TR(B): Additional ones of tolerance classes for ones in
			// variances.
			tolerancesOfCombined.get(extraInvariancesEntry.getKey()).addAll(extraInvariancesEntry.getValue());
			// Maintain U'/TR(B): Additional ones of tolerance classes for ones in
			// in-variances.
			for (Sample toleranceOfVariance : extraInvariancesEntry.getValue())
				tolerancesOfCombined.get(toleranceOfVariance).add(extraInvariancesEntry.getKey());
			// Additional ones in Ux'/TR(B) are updated.
			// variancesUpdated.addAll(extraInvariancesEntry.getValue());
		}
		return tolerancesOfCombined;
	}

	// update总流程
	public ToleranceClassandIDegreeResult calculateTolerances_update(Collection<Sample> samples,
			Collection<Sample> candidates, IntArrayKey attributes,
			Map<Sample, Collection<Sample>> tolerancesOfInvariances,ToleranceCollection variancesTColl ) {
		Map<Sample, Collection<Sample>> tolerances = this.toleranceClassUpdatebyObject(samples, candidates, attributes,
				tolerancesOfInvariances,variancesTColl );
		ToleranceClassandIDegreeResult TCResult = toleranceClassConsideringDecisionValueWithIDegree(tolerances);
		return TCResult;
	}

	// 冗余检验
	public boolean redundancy_update(int attribute, IntArrayKey Reduce, Collection<Sample> U, Collection<Sample> newU,
			ToleranceClassandIDegreeResult BTCResult,ToleranceCollection TColl,ToleranceCollection variancesTColl ) {
		IntArrayKey newAttr = new IntArrayKey(Reduce.key().clone());
		newAttr.deleteKey(attribute);
//		ToleranceCollection TColl = findNotMissing(U, newAttr);
		Map<Sample, Collection<Sample>> tolerances = obtainSampleToleranceClass(U, U, newAttr, TColl);
		// Map<Sample,Collection<Sample>>
		// tolerances=this.ToleranceClassUpdatebyAdding1attr(BTCResult.cloneToleranceofCondAttrs(),
		// newAttr);
		ToleranceClassandIDegreeResult tempTCResult = calculateTolerances_update(U, newU, newAttr, tolerances,variancesTColl );
		// ToleranceClassandIDegreeResult tempTCResult=calculateTolerances(U,U,newAttr);
		// tempTCResult.iDegreeOutPut();
		// tempTCResult.tolerancesOutPut2();;
		Significance sig = calculateSignificance(attribute, newAttr, true, BTCResult.getiDegree(),
				tempTCResult.getiDegree());
		if (sig.getSig() == 0) {
			BTCResult = tempTCResult;
			return true;
		}
		return false;
	}

	// 动态约简
	public StaticReduceResult DIDSReduce(Collection<Sample> U, Collection<Sample> newU, int CSize,
			StaticReduceResult previousResult) {
		System.out.println("||增量约简开始");
		IntArrayKey C = new IntArrayKey(CSize);
		IntArrayKey ReduceKey = new IntArrayKey(
				previousResult.getReduce().stream().mapToInt(Integer::valueOf).toArray());
		List<Integer> Reduce = previousResult.getReduce();
		List<Integer> remainC = Arrays.stream(C.key()).filter(a -> !ReduceKey.contains(a)).boxed()
				.collect(Collectors.toList());
		// List<Integer> delete=new ArrayList<Integer>(remainC.size());
		LinkedHashMap<String, Long> times = new LinkedHashMap<>(10);
		Map<Sample, Collection<Sample>> BtempcondAttr = previousResult.getBTCResult().cloneToleranceofCondAttrs();

		long start = System.currentTimeMillis();
		ToleranceCollection TColl = findNotMissing(U, C);
		ToleranceCollection variancesTColl = findNotMissing(newU, C);
		ToleranceClassandIDegreeResult CTCResult = calculateTolerances_update(U, newU, C,
				previousResult.getCTCResult().getToleranceClassesOfCondAttrs(),variancesTColl);
		long end = System.currentTimeMillis();
		System.out.println("||全C下的等价类更新&iDegree(C)=" + CTCResult.getiDegree() + ",时间：:" + (end - start) + "ms,"
				+ (double) (end - start) / 1000 + "s");
		times.put("updateEquivalenceClassofC", end - start);
		// CTCResult.iDegreeOutPut();
		// CTCResult.tolerancesOutPut2();

		start = System.currentTimeMillis();
		ToleranceClassandIDegreeResult ReduceTCResult = calculateTolerances_update(U, newU, ReduceKey,
				previousResult.getBTCResult().getToleranceClassesOfCondAttrs(),variancesTColl);
		end = System.currentTimeMillis();
		System.out.println("||Reduce下的等价类更新&iDegree(B)=" + ReduceTCResult.getiDegree() + ",时间：" + (end - start) + "ms,"
				+ (double) (end - start) / 1000 + "s");
		times.put("updateEquivalenceClassofB", end - start);
		// ReduceTCResult.iDegreeOutPut();
		// ReduceTCResult.tolerancesOutPut2();
		ToleranceClassandIDegreeResult tempTCResult, maxTCResult = ReduceTCResult;
		Significance max_sig = new Significance();
		int max_a = -1;
		int j = -1;
		// ToleranceClassandIDegreeResult maxBTCResult=BtempTCResult;
		Map<Sample, Collection<Sample>> maxtolerance = BtempcondAttr;

		start = System.currentTimeMillis();
		while (CTCResult.getiDegree() != ReduceTCResult.getiDegree()) {
			max_sig = new Significance();
			int[] partitionAttributes = new int[ReduceKey.key().length + 1];
			int k = 0;
			for (int attr : ReduceKey.key())
				partitionAttributes[k++] = attr;
			for (int i = 0; i < remainC.size(); i++) {
				int attr = remainC.get(i);
				partitionAttributes[partitionAttributes.length - 1] = attr;
				IntArrayKey temp = new IntArrayKey(partitionAttributes);
				// ToleranceCollection TColl=findNotMissing(U,temp);
				// Map<Sample,Collection<Sample>>
				// tolerances=obtainSampleToleranceClass(U,U,temp,TColl);
				Map<Sample, Collection<Sample>> tolerances = this.ToleranceClassUpdatebyAdding1attr(BtempcondAttr,
						temp);
				maxtolerance = cloneMapTolerances(tolerances);
				tempTCResult = calculateTolerances_update(U, newU, temp, tolerances,variancesTColl);
				// tempTCResult.iDegreeOutPut();
				// tempTCResult.tolerancesOutPut2();
				Significance a_sig = calculateSignificance(attr, temp, false, ReduceTCResult.getiDegree(),
						tempTCResult.getiDegree());
				// System.out.println("属性"+attr+"的sig="+a_sig.getSig()+" ");
				if (a_sig.getSig() > max_sig.getSig()) {
					max_a = attr;
					maxTCResult = tempTCResult;
					max_sig = a_sig;
					j = i;
				}
			}
			Reduce.add(max_a);
			ReduceKey.addKey(max_a);
			ReduceTCResult = maxTCResult;
			BtempcondAttr = maxtolerance;
			remainC.remove(j);
			// System.out.print("最优属性："+max_a+"iDegree:"+ReduceTCResult.getiDegree()+"
			// 约简："+Reduce.toString()+" ");
			// System.out.println("remainC="+remainC.toString());
			// ReduceTCResult.tolerancesOutPut2();
			// ReduceTCResult.iDegreeOutPut();
			System.out.println("||最优特征{" + max_a + "}&iDegree(B+{" + max_a + "})=" + ReduceTCResult.getiDegree());
		}
		end = System.currentTimeMillis();
		System.out.println(
				"||迭代&Reduce={" + Reduce + "},时间：" + (end - start) + "ms," + (double) (end - start) / 1000 + "s");
		times.put("iteration", end - start);

		// 冗余检验 无
		start = System.currentTimeMillis();
		System.out.println("||冗余约简开始");
		for (int i = 0; i < Reduce.size(); i++) { // 删除冗余属性
			int a = Reduce.get(i);
			//boolean redundancy = redundancy_update(a, ReduceKey, U, newU, ReduceTCResult,TColl,variancesTColl);
			boolean redundancy=false;
			if (redundancy) {
				Reduce.remove(i);
				ReduceKey.deleteKey(a);
				i--;
				remainC.add(a);
				// System.out.print("删除属性："+a+" ");
				System.out.println("||删除特征{" + a + "}");
			}
		}
		end = System.currentTimeMillis();
		System.out.println("||冗余检验结束：" + (end - start) + "ms," + (double) (end - start) / 1000 + "s");
		times.put("redundancy", end - start);
		long alltime = 0;
		for (long i : times.values())
			alltime += i;
		System.out.println("||最终约简Reduce={" + Reduce + "},约简数量=" + Reduce.size());
		System.out.println("||总时间：" + alltime + "ms," + (double) (alltime) / 1000 + "s");

		U.addAll(newU);
		StaticReduceResult result = new StaticReduceResult(CTCResult, ReduceTCResult, Reduce, times);
		return result;
	}

	public Map<Sample, Collection<Sample>> cloneMapTolerances(Map<Sample, Collection<Sample>> tolerances) {
		Map<Sample, Collection<Sample>> newtolerance = new HashMap<>(tolerances.size());
		for (Entry<Sample, Collection<Sample>> entry : tolerances.entrySet()) {
			Collection<Sample> newtol = new LinkedList<>();
			for (Sample x : entry.getValue())
				newtol.add(x);
			newtolerance.put(entry.getKey(), newtol);
		}
		return newtolerance;
	}

}

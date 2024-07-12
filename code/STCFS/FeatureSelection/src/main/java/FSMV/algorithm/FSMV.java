package main.java.FSMV.algorithm;

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
import java.util.Set;
import java.util.stream.Collectors;

import main.Log4jPrintStream;
import main.basic.model.Sample;
import main.java.FSMV.entity.CombTClassesResult4VariantObjs;
import main.java.FSMV.entity.IntArrayKey;
import main.java.FSMV.entity.MostSignificantAttributeResult;
import main.java.FSMV.entity.PositiveRegion;
import main.java.FSMV.entity.ReductCandidateResult4VariantObjects;
import main.java.FSMV.entity.Significance;
import main.java.FSMV.entity.StaticReduceResult;
import main.java.FSMV.entity.ToleranceClass;
import main.java.FSMV.entity.ToleranceClassandPOSResult;
import main.java.FSMV.entity.ToleranceCollection;

public class FSMV {
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
//		//D
//		List<Sample> notmissinglist=findNotMissingValueCollofAttribute(U,-1);
//		if(!notmissinglist.isEmpty())
//			notmissingSample.set(-1, equivalenceClass(notmissinglist,-1));
		return notmissingSample;
	}

	// 计算ToleranceClass SB(x)
	public Map<Sample, Collection<Sample>> obtainSampleToleranceClass(Collection<Sample> samples,
			Collection<Sample> candidates, IntArrayKey attributes, ToleranceCollection completeColl) {
//		if(attributes.size()==0)
//			return samples.stream().collect(Collectors.toMap(Function.identity(), x->new HashSet<>(candidates)));
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

	// 总流程——计算ToleranceClass SB(x)for all x∈U and the positive region POSB(D)
	public ToleranceClassandPOSResult TCPR(Collection<Sample> samples, Collection<Sample> candidates,
			IntArrayKey attributes,ToleranceCollection TColl) {
		PositiveRegion pos = new PositiveRegion(attributes);
		
		// TColl.outPut();
		Map<Sample, Collection<Sample>> tolerances = obtainSampleToleranceClass(samples, candidates, attributes, TColl);
		pos.calculate(tolerances.entrySet());
		ToleranceClassandPOSResult returnItem = new ToleranceClassandPOSResult(tolerances, pos);
		return returnItem;
	}

	// 增加一个属性下等价类更新
	public ToleranceClassandPOSResult ToleranceClassUpdatebyAdding1attr(ToleranceClassandPOSResult previousTCResult,
			IntArrayKey attributes) { // B+{a}
		// previousTCResult.tolerancesOutPut2();
		ToleranceClassandPOSResult newTCResult = previousTCResult.clone();
		// newTCResult.tolerancesOutPut2();
		int attr = attributes.key()[attributes.key().length - 1];
		// Map<Sample,Collection<Sample> toBRemove=new
		// HashMap<>(newTCResult.getTolerances().size());
		for (Entry<Sample, Collection<Sample>> tolerances : newTCResult.getTolerances().entrySet()) {
			Sample x1 = tolerances.getKey();
			// if(!tolerances.getValue().isEmpty())
			Collection<Sample> remove = new LinkedList<>();
			for (Sample x2 : tolerances.getValue())
				if (x1.getName() != x2.getName())
					if (x1.getAttributeValueByIndex(attr + 1) != -1 && x2.getAttributeValueByIndex(attr + 1) != -1
							&& x1.getAttributeValueByIndex(attr + 1) != x2.getAttributeValueByIndex(attr + 1)) {
						remove.add(x2);
						if (newTCResult.getTolerances().containsKey(x2))
							newTCResult.getTolerances().get(x2).remove(x1);
					}
			tolerances.getValue().removeAll(remove);
		}
		newTCResult.getPos().calculate(newTCResult.getTolerances().entrySet());
		// newTCResult.tolerancesOutPut2();
		return newTCResult;
	}

	// 计算属性重要度
	// 原文中重要度计算为sig=POSC(D)-POSC-{a}(D) 修改为利用属性依赖度计算sig 0<sig<1
	public Significance calculateSignificance(int attribute, IntArrayKey B, boolean is_inner, PositiveRegion initialpos,
			PositiveRegion newpos, int USize) {
		Significance sig = new Significance(attribute, B.key());
		if (is_inner)
			sig.setSig((float) (initialpos.getSize() - newpos.getSize()) / USize);
		else
			sig.setSig((float) (newpos.getSize() - initialpos.getSize()) / USize);
		return sig;
	}

	// 冗余检验
	public boolean redundancy(int attribute, IntArrayKey Reduce, Collection<Sample> U,
			ToleranceClassandPOSResult BTCResult,ToleranceCollection TColl) {
		IntArrayKey newAttr = new IntArrayKey(Reduce.key().clone());
		newAttr.deleteKey(attribute);
		ToleranceClassandPOSResult TempColl = TCPR(U, U, newAttr,TColl);
		Significance sig = calculateSignificance(attribute, newAttr, true, BTCResult.getPos(), TempColl.getPos(),
				U.size());
		if (sig.getSig() == 0) {
			BTCResult = TempColl;
			return true;
		}
		return false;
	}

	// 静态约简
	public StaticReduceResult staticReduce_CFSV(Collection<Sample> U, int CSize) {
		System.out.println("||静态约简开始");
		List<Integer> Reduce = new LinkedList<Integer>();
		IntArrayKey C = new IntArrayKey(CSize);
		LinkedHashMap<String, Long> times = new LinkedHashMap<>(10);

		long start = System.currentTimeMillis();
		ToleranceCollection TColl = findNotMissing(U, C);
		ToleranceClassandPOSResult CPos = TCPR(U, U, C,TColl);
		long end = System.currentTimeMillis();
		System.out.print("||全C下的等价类计算&POS(C)=" + CPos.getPos().getSize() + ",时间：" + (end - start) + "ms,"
				+ (double) (end - start) / 1000 + "s");
		times.put("computeEquivalenceClassofC", end - start);
		// CPos.tolerancesOutPut2();
		// CPos.posOutPut();

		ToleranceClassandPOSResult tempPos;
		List<Integer> remainC = Arrays.stream(C.key()).boxed().collect(Collectors.toList());
		List<Integer> delete = new ArrayList<Integer>(C.key().length);

		start = System.currentTimeMillis();
		for (int i = 0; i < CSize; i++) {
			int attr = C.key()[i];
			IntArrayKey temp = new IntArrayKey(C.key().clone());
			temp.deleteKey(attr);
			tempPos = TCPR(U, U, temp,TColl);
			// tempPos.posOutPut();
			Significance a_sig = calculateSignificance(attr, C, false, CPos.getPos(), tempPos.getPos(), U.size());
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
		ToleranceClassandPOSResult BPos = TCPR(U, U, ReduceKey,TColl);
		// BPos.tolerancesOutPut();
		end = System.currentTimeMillis();
		System.out.println("||B下的等价类计算&POS(B)=" + BPos.getPos().getSize() + ",时间:" + (end - start) + "ms,"
				+ (double) (end - start) / 1000 + "s");
		times.put("computeEquivalenceClassofB", end - start);
		// BPos.posOutPut();

		ToleranceClassandPOSResult maxPos = new ToleranceClassandPOSResult();
		Significance max_sig = new Significance();
		int max_a = -1;
		int j = -1;

		start = System.currentTimeMillis();
		while (BPos.getPos().getSize() != CPos.getPos().getSize()) {
			max_sig = new Significance();
			for (int i = 0; i < remainC.size(); i++) {
				int attr = remainC.get(i);
				IntArrayKey temp = new IntArrayKey(ReduceKey.key().clone());
				temp.addKey(attr);
				tempPos = TCPR(U, U, temp,TColl);
				// tempPos.posOutPut();
				Significance a_sig = calculateSignificance(attr, ReduceKey, false, BPos.getPos(), tempPos.getPos(),
						U.size());
				// System.out.println("属性"+attr+"的sig="+a_sig.getSig()+" ");
				if (a_sig.getSig() > max_sig.getSig()) {
					max_a = attr;
					maxPos = tempPos;
					max_sig = a_sig;
					j = i;
				}
			}
			Reduce.add(max_a);
			ReduceKey.addKey(max_a);
			BPos = maxPos;
			remainC.remove(j);
			// System.out.print("最优属性："+max_a+"POS："+maxPos.getPos().getSize()+"
			// 约简："+Reduce.toString()+" ");
			// System.out.println("remainC="+remainC.toString());
			System.out.println("||最优特征{" + max_a + "}&POS(B+{" + max_a + "})=" + BPos.getPos().getSize());
		}
		end = System.currentTimeMillis();
		System.out.println("||迭代时间：" + (end - start) + "ms," + (double) (end - start) / 1000 + "s");
		times.put("iteration", end - start);

		// 冗余检验 无
//		for(int i=0;i<Reduce.size();i++) {  //删除冗余属性
//			int a=Reduce.get(i);
//			boolean redundancy=redundancy(a, ReduceKey,U,BPos);
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

		StaticReduceResult result = new StaticReduceResult(CPos, BPos, Reduce, times);
		return result;
	}

	// 计算增量后的容差类U'/TR(B)
	public CombTClassesResult4VariantObjs toleranceClasses_update(Collection<Sample> U, Collection<Sample> newU,
			IntArrayKey attributes, Map<Sample, Collection<Sample>> tolerancesOfInvariances,ToleranceCollection variancesTColl) {
		// Get tolerance classes of variances: Ux'/TR(B)
		//ToleranceCollection variancesTColl = findNotMissing(newU, attributes);
		Map<Sample, Collection<Sample>> tolerancesOfVariances = obtainSampleToleranceClass(newU, newU, attributes,
				variancesTColl);
		Map<Sample, Collection<Sample>> tolerancesOfCombined = new HashMap<>(U.size() + newU.size());
		tolerancesOfCombined.putAll(tolerancesOfInvariances);
		tolerancesOfCombined.putAll(tolerancesOfVariances);
		// Get the additional tolerance classes when combining (U'-Ux') and Ux'
		// for "ones to be added" in U'/TR(B) comparing to (U'-Ux')/TR(B) and Ux'/TR(B).
		Map<Sample, Collection<Sample>> additionalTolerances = obtainSampleToleranceClass(U, newU, attributes,
				variancesTColl);
		Collection<Sample> invariancesUpdated = additionalTolerances.keySet();
		Collection<Sample> variancesUpdated = new HashSet<>(newU.size());
		for (Entry<Sample, Collection<Sample>> extraInvariancesEntry : additionalTolerances.entrySet()) {
			// Maintain U'/TR(B): Additional ones of tolerance classes for ones in
			// variances.
			tolerancesOfCombined.get(extraInvariancesEntry.getKey()).addAll(extraInvariancesEntry.getValue());
			// Maintain U'/TR(B): Additional ones of tolerance classes for ones in
			// in-variances.
			for (Sample toleranceOfVariance : extraInvariancesEntry.getValue())
				tolerancesOfCombined.get(toleranceOfVariance).add(extraInvariancesEntry.getKey());
			// Additional ones in Ux'/TR(B) are updated.
			variancesUpdated.addAll(extraInvariancesEntry.getValue());
		}
		return new CombTClassesResult4VariantObjs(invariancesUpdated, variancesUpdated, tolerancesOfInvariances,
				tolerancesOfVariances, tolerancesOfCombined);
	}

	// 计算增量后的正域 POS U' B(D)
	public PositiveRegion calculatePositiveRegion_update(IntArrayKey attributes, Collection<Sample> U, int allUSize,
			CombTClassesResult4VariantObjs updateObj, ToleranceClassandPOSResult invariancesObj) {
		PositiveRegion updatePos = new PositiveRegion(attributes);
		PositiveRegion variancesPos = new PositiveRegion(attributes);
		variancesPos.calculate(updateObj.getTolerancesOfVariances().entrySet());
		Collection<Sample> toBRemoved = new HashSet<>(allUSize);
		ToleranceClassLoop1: for (Sample x : updateObj.getInvariancesUpdated()) {
			Iterator<Sample> insIterator = updateObj.getTolerancesOfCombined().get(x).iterator();
			int dec = insIterator.next().getDecisionValues();
			while (insIterator.hasNext()) {
				if (insIterator.next().getDecisionValues() != dec) {
					toBRemoved.add(x);
					continue ToleranceClassLoop1;
				}
			}
		}
		ToleranceClassLoop2: for (Sample x : updateObj.getVariancesUpdated()) {
			Iterator<Sample> insIterator = updateObj.getTolerancesOfCombined().get(x).iterator();
			int dec = insIterator.next().getDecisionValues();
			while (insIterator.hasNext()) {
				if (insIterator.next().getDecisionValues() != dec) {
					toBRemoved.add(x);
					continue ToleranceClassLoop2;
				}
			}
		}
		updatePos.getPOSSamples().addAll(invariancesObj.getPos().getPOSSamples());
		updatePos.getPOSSamples().addAll(variancesPos.getPOSSamples());
		updatePos.getPOSSamples().removeAll(toBRemoved);
		// updatePos.getPOSSamples().removeAll(U);
		updatePos.setSize(updatePos.getPOSSamples().size());
		return updatePos;
	}

	// 对属性按重要度降序排列
	public ReductCandidateResult4VariantObjects descendingSequenceSortedAttributes(Collection<Sample> U,
			Collection<Sample> newU, int[] C, ToleranceClassandPOSResult previousResult, List<Integer> previousReduce,ToleranceCollection TColl,ToleranceCollection variancesTColl) {
		// Collect reduct candidates: C-B
		Collection<Integer> previousReduct = previousReduce;
		final Collection<Integer> previousReductHash = previousReduct instanceof Set ? previousReduct
				: new HashSet<>(previousReduct);
		List<Integer> reductCandidate = Arrays.stream(C).filter(attr -> !previousReductHash.contains(attr)).boxed()
				.collect(Collectors.toList());
		// Calculate POS<sub>B∪{a}</sub>(D) for every attribute in reduct
		// candidates(C-B).
		int[] partitionAttributes = new int[previousReduct.size() + 1];
		int i = 0;
		for (int attr : previousReduct)
			partitionAttributes[i++] = attr;
		final Map<Integer, Integer> posOfCandidates = new HashMap<>(reductCandidate.size());
		for (int candidate : reductCandidate) {
			partitionAttributes[i] = candidate;
			IntArrayKey BAkey = new IntArrayKey(partitionAttributes);
			ToleranceClassandPOSResult BPartTCResult = ToleranceClassUpdatebyAdding1attr(previousResult, BAkey);
//			ToleranceClassandPOSResult BPartTCResult=TCPR(U,U,BAkey,TColl);
			CombTClassesResult4VariantObjs attrTC = toleranceClasses_update(U, newU, BAkey,
					BPartTCResult.getTolerances(),variancesTColl);
			PositiveRegion BApos = calculatePositiveRegion_update(BAkey, U, U.size() + newU.size(), attrTC,
					BPartTCResult);
			// ToleranceClassandPOSResult tempTCResult=new
			// ToleranceClassandPOSResult(attrTC.getTolerancesOfCombined(),BApos);
			posOfCandidates.put(candidate, BApos.getSize());
			// System.out.println("候选"+candidate+",pos:"+BApos.getSize());
			// tempTCResult.tolerancesOutPut2();
			// posOfCandidates.put(candidate,tempTCResult.getPos().getSize());
		}
		// Sort reduct candidates in descending sequence.
		bubbleSortOpt2(reductCandidate, posOfCandidates);
		// Collections.sort(reductCandidate, (attr1,
		// attr2)->posOfCandidates.get(attr1)-posOfCandidates.get(attr2));
		return new ReductCandidateResult4VariantObjects(previousReductHash, reductCandidate);
	}

	// 排序 同方法（冒泡排序）从大到小
	public void bubbleSortOpt2(List<Integer> reductCandidate, Map<Integer, Integer> posOfCandidates) {
		if (reductCandidate == null) {
		}
		if (reductCandidate.size() < 2) {
			return;
		}
		int tempindex = 0;
		for (int i = 0; i < reductCandidate.size() - 1; i++) {
			for (int j = 0; j < reductCandidate.size() - i - 1; j++) {
				int attr1 = reductCandidate.get(j);
				int attr2 = reductCandidate.get(j + 1);
				if (posOfCandidates.get(attr1) < posOfCandidates.get(attr2)) {

					reductCandidate.set(j, attr2);
					reductCandidate.set(j + 1, attr1);
				}
			}
		}
	}

	// Search for the most significant attribute for the current reduct.
	public MostSignificantAttributeResult mostSignificanceAttr(Collection<Sample> U, Collection<Sample> newU,
			IntArrayKey previousReduct, List<Integer> newAttributes, ToleranceClassandPOSResult previousTCResult,ToleranceCollection TColl,ToleranceCollection variancesTColl) {
		int[] partitionAttributes = new int[previousReduct.size() + 1];
		int i = 0;
		for (int attr : previousReduct.key())
			partitionAttributes[i++] = attr;
		int sigAttr = -1;
		Float sigValue = null, sig = null;
		ToleranceClassandPOSResult TCResult = new ToleranceClassandPOSResult();
		for (int attr : newAttributes) {
			if (previousReduct.contains(attr))
				continue;
			partitionAttributes[partitionAttributes.length - 1] = attr;
			IntArrayKey BAkey = new IntArrayKey(partitionAttributes);
			ToleranceClassandPOSResult BPartTCResult = TCPR(U, U, BAkey,TColl);
			CombTClassesResult4VariantObjs attrTC = toleranceClasses_update(U, newU, BAkey,
					BPartTCResult.getTolerances(),variancesTColl);
			PositiveRegion BApos = calculatePositiveRegion_update(BAkey, U, U.size() + newU.size(), attrTC,
					BPartTCResult);
			// int pos=BApos.getSize();
			// System.out.println("属性"+attr+"possize："+pos);
			sig = calculateSignificance(attr, previousReduct, false, previousTCResult.getPos(), BApos,
					U.size() + newU.size()).getSig();
			if (sigAttr == -1 || sig.floatValue() > sigValue.floatValue()) {
				sigValue = sig;
				sigAttr = attr;
				TCResult = new ToleranceClassandPOSResult(attrTC.getTolerancesOfCombined(), BApos);
				// TCResult.tolerancesOutPut2();
			}
		}
		return new MostSignificantAttributeResult(sigAttr, TCResult);
	}

	// 冗余检验 增量
	public boolean redundancy_update(int attribute, IntArrayKey Reduce, Collection<Sample> U, Collection<Sample> newU,
			ToleranceClassandPOSResult ReduceTCResult, ToleranceClassandPOSResult BtempTCResult,ToleranceCollection TColl,ToleranceCollection variancesTColl) {
		IntArrayKey newAttr = new IntArrayKey(Reduce.key().clone());
		newAttr.deleteKey(attribute);
//		ToleranceClassandPOSResult BPartTCResult=ToleranceClassUpdatebyAdding1attr(BtempTCResult, newAttr);		
		ToleranceClassandPOSResult BPartTCResult = TCPR(U, U, newAttr,TColl);
		CombTClassesResult4VariantObjs combineToleranceResultofReduce = toleranceClasses_update(U, newU, newAttr,
				BPartTCResult.getTolerances(),variancesTColl);
		PositiveRegion BPos = calculatePositiveRegion_update(newAttr, U, U.size() + newU.size(),
				combineToleranceResultofReduce, BPartTCResult);
		ToleranceClassandPOSResult tempTCResult = new ToleranceClassandPOSResult(
				combineToleranceResultofReduce.getTolerancesOfCombined(), BPos);
		// tempTCResult.posOutPut();;
		Significance sig = calculateSignificance(attribute, newAttr, true, ReduceTCResult.getPos(),
				tempTCResult.getPos(), U.size() + newU.size());
		if (sig.getSig() == 0) {
			ReduceTCResult = tempTCResult;
			// ReduceTCResult.posOutPut();
			// BtempTCResult=BPartTCResult;
			return true;
		}
		return false;
	}
	//20230210
//	public boolean redundancy_update_new(int attribute, IntArrayKey Reduce, Collection<Sample> totalU,
//			ToleranceClassandPOSResult ReduceTCResult, ToleranceClassandPOSResult BtempTCResult,ToleranceCollection TColl,ToleranceCollection variancesTColl) {
//		IntArrayKey newAttr = new IntArrayKey(Reduce.key().clone());
//		newAttr.deleteKey(attribute);
//		
//		ToleranceClassandPOSResult TempColl = TCPR(totalU,totalU, newAttr,TColl);
//		Significance sig = calculateSignificance(attribute, newAttr, true, ReduceTCResult.getPos(), TempColl.getPos(),
//				totalU.size());
//		if (sig.getSig() == 0) {
//			ReduceTCResult = TempColl;
//			return true;
//		}
//		return false;
//	}

	// 增量约简
	public StaticReduceResult FSMVReduce(Collection<Sample> U, Collection<Sample> newU, int CSize,
			StaticReduceResult previousResult) {
		System.out.println("||增量约简开始");
		IntArrayKey CKey = new IntArrayKey(CSize);
		IntArrayKey ReduceKey = new IntArrayKey(
				previousResult.getReduce().stream().mapToInt(Integer::valueOf).toArray());
		LinkedHashMap<String, Long> times = new LinkedHashMap<>(10);
		List<Integer> reductCandidate=new LinkedList<Integer>();
		List<Integer> Reduce = previousResult.getReduce();
		ToleranceCollection TColl = findNotMissing(U, CKey);
		ToleranceClassandPOSResult BtempTCResult = previousResult.getBPos().clone();

		// U'/TR(B) & U'/TR(C)
		long start = System.currentTimeMillis();
		ToleranceCollection variancesTColl = findNotMissing(newU, CKey);
		CombTClassesResult4VariantObjs combineToleranceResultofC = toleranceClasses_update(U, newU, CKey,
				previousResult.getCPos().getTolerances(),variancesTColl);
		PositiveRegion CPos = calculatePositiveRegion_update(CKey, U, U.size() + newU.size(), combineToleranceResultofC,
				previousResult.getCPos());
		ToleranceClassandPOSResult CTCResult = new ToleranceClassandPOSResult(
				combineToleranceResultofC.getTolerancesOfCombined(), CPos);
		long end = System.currentTimeMillis();
		System.out.println("||全C下的等价类更新&POS(C)=" + CTCResult.getPos().getSize() + ",时间：:" + (end - start) + "ms,"
				+ (double) (end - start) / 1000 + "s");
		times.put("updateEquivalenceClassofC", end - start);

		start = System.currentTimeMillis();
		CombTClassesResult4VariantObjs combineToleranceResultofReduce = toleranceClasses_update(U, newU, ReduceKey,
				previousResult.getBPos().getTolerances(),variancesTColl);
		PositiveRegion BPos = calculatePositiveRegion_update(ReduceKey, U, U.size() + newU.size(),
				combineToleranceResultofReduce, previousResult.getBPos());
		ToleranceClassandPOSResult ReduceTCResult = new ToleranceClassandPOSResult(
				combineToleranceResultofReduce.getTolerancesOfCombined(), BPos);
		end = System.currentTimeMillis();
		System.out.println("||Reduce下的等价类更新&POS(B)=" + ReduceTCResult.getPos().getSize() + ",时间：" + (end - start)
				+ "ms," + (double) (end - start) / 1000 + "s");
		times.put("updateEquivalenceClassofB", end - start);

//		System.out.print("增量CTCResult：");
//		CTCResult.posOutPut();
//		System.out.print("增量ReduceTCResult：");
//		ReduceTCResult.posOutPut();
		// ReduceTCResult.tolerancesOutPut2();

		start = System.currentTimeMillis();
		// if e=0 and e'=0 variances and invariances 没有更新部分
		if(CTCResult.getPos().getSize() != ReduceTCResult.getPos().getSize()) {
		if (combineToleranceResultofC.getInvariancesUpdated().isEmpty()
				&& combineToleranceResultofC.getVariancesUpdated().isEmpty())
			if (CPos.getSize() == BPos.getSize())
				return new StaticReduceResult(CTCResult, ReduceTCResult, previousResult.getReduce());
		// for any feature c∈C-B，construct a descending sequence by sig2(c,B,D) and
		// record the result by {c1',c2',...,c|C-B|'}
		ReductCandidateResult4VariantObjects descendRemainC = descendingSequenceSortedAttributes(U, newU, CKey.key(),
				BtempTCResult, Reduce,TColl,variancesTColl);
		reductCandidate= descendRemainC.getReductCandidate();
		}
		end = System.currentTimeMillis();
		System.out.println("||对剩余属性按重要度降序排列，时间：" + (end - start) + "ms," + (double) (end - start) / 1000 + "s");
		times.put("descendSortofremainC", end - start);

		
		// System.out.println("Reduce:"+Reduce.toString()+"
		// remainC:"+reductCandidate.toString());
		// IntArrayKey BKey=new
		// IntArrayKey(previousResult.getReduce().stream().mapToInt(Integer::valueOf).toArray());

		start = System.currentTimeMillis();
		int k = 0;// reductCandidate
		while (CTCResult.getPos().getSize() != ReduceTCResult.getPos().getSize()) {
			int a = reductCandidate.get(k++);
//			int[] partitionAttributes = new int[BKey.key().length+1];
//			int i=0;	for (int attr: BKey.key())	partitionAttributes[i++]=attr;
			IntArrayKey newAttr = new IntArrayKey(ReduceKey.key());
			newAttr.addKey(a);
//			ToleranceClassandPOSResult BPartTCResult = ToleranceClassUpdatebyAdding1attr(BtempTCResult, newAttr);
			ToleranceClassandPOSResult BPartTCResult=TCPR(U,U,newAttr,TColl);
			ToleranceClassandPOSResult maxTCResult = BPartTCResult.clone();
			
			CombTClassesResult4VariantObjs attrTC = toleranceClasses_update(U, newU, newAttr,
					BPartTCResult.getTolerances(),variancesTColl);
			PositiveRegion BApos = calculatePositiveRegion_update(newAttr, U, U.size() + newU.size(), attrTC,
					BPartTCResult);
			ToleranceClassandPOSResult tempTCResult = new ToleranceClassandPOSResult(attrTC.getTolerancesOfCombined(),
					BApos);
			Reduce.add(a);
			ReduceKey.addKey(a);
			// BKey.addKey(mostSigAttr.getAttribute());
//			tempTCResult.posOutPut();
//			System.out.print("最优属性"+a+" ");
//			System.out.println("约简："+Reduce.toString());
			ReduceTCResult = tempTCResult;
			BtempTCResult = maxTCResult;
			// ReduceTCResult.tolerancesOutPut2();
			System.out.println("||最优特征{" + a + "}&POS(B+{" + a + "})=" + ReduceTCResult.getPos().getSize());

		}
		end = System.currentTimeMillis();
		System.out.println(
				"||迭代&Reduce={" + Reduce + "},时间：" + (end - start) + "ms," + (double) (end - start) / 1000 + "s");
		times.put("iteration", end - start);
		// 冗余检验
		start = System.currentTimeMillis();
		System.out.println("||冗余约简开始");
		//这里U已经变为totalU
		//U.addAll(newU);  //新改位置 20230210
		//TColl.addAll(variancesTColl);
		for (int i = 0; i < Reduce.size(); i++) { // 删除冗余属性
			int a = Reduce.get(i);
			boolean redundancy = redundancy_update(a, ReduceKey, U,newU, ReduceTCResult, BtempTCResult,TColl,variancesTColl);
			//boolean redundancy = redundancy(a, ReduceKey, U, ReduceTCResult, TColl);
			//boolean redundancy=false;
			if (redundancy) {
				Reduce.remove(i);
				ReduceKey.deleteKey(a);
				i--;
				//reductCandidate.add(a);
				// System.out.print("删除属性："+a);
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
}

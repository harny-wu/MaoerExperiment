package main.java.IFSICE.algorithm;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map.Entry;
import java.util.Set;
import java.util.stream.Collectors;

import main.Log4jPrintStream;
import main.basic.model.Sample;
import main.java.IFSICE.entity.DupdateClass;
import main.java.IFSICE.entity.DupdateCollection;
import main.java.IFSICE.entity.IntArrayKey;
import main.java.IFSICE.entity.Significance;
import main.java.IFSICE.entity.StaticReduceResult;
import main.java.IFSICE.entity.ToleranceCollection;
import main.java.IFSICE.entity.ToleranceCollectionUpdateResult;

public class IFSICE {
	static {
		Log4jPrintStream.redirectSystemOut();
	}

	public IFSICE() {
	}

	// 从查找B条件下的全U等价类
	public ToleranceCollection toleranceClass(IntArrayKey attributeIndex, ArrayList<Sample> U) {
		ToleranceCollection Tcoll = new ToleranceCollection(attributeIndex, U.size());// 初始化要全部x的T
		boolean flag = true;
		for (int i = 0; i < U.size(); i++) {
			Sample x1 = U.get(i);
			if (!Tcoll.getItems().containsKey(x1.getName()))
				Tcoll.getItems().put(x1.getName(), new ArrayList<Sample>(U.size()));
			Tcoll.getItems().get(x1.getName()).add(x1);// 是否包括i本身
			for (int j = i + 1; j < U.size(); j++) {
				Sample x2 = U.get(j);
				flag = true;
				for (int z = 0; z < attributeIndex.key().length; z++) {
					// 条件属性在x中的下标从1开始
					if (x1.getAttributeValueByIndex(attributeIndex.key()[z] + 1) != x2
							.getAttributeValueByIndex(attributeIndex.key()[z] + 1)
							&& x1.getAttributeValueByIndex(attributeIndex.key()[z] + 1) != -1
							&& x2.getAttributeValueByIndex(attributeIndex.key()[z] + 1) != -1) {
						flag = false;
						break;
					}
				}
				if (flag) {
					if (!Tcoll.getItems().containsKey(x2.getName()))
						Tcoll.getItems().put(x2.getName(), new ArrayList<Sample>(U.size()));
					Tcoll.getItems().get(x1.getName()).add(x2);
					Tcoll.getItems().get(x2.getName()).add(x1);
				}
			}
		}
		return Tcoll;
	}

	// 查找在B∪{a}下的全U等价类（添加一个属性）
	public ToleranceCollection toleranceClass_addAttribute(IntArrayKey attributeIndex, int a, ArrayList<Sample> U,
			ToleranceCollection BTcoll) {
		IntArrayKey newAttr = new IntArrayKey(attributeIndex.key().clone());
		newAttr.addKey(a);
		HashMap<Integer, ArrayList<Sample>> items = (HashMap<Integer, ArrayList<Sample>>) BTcoll.getItems().clone();
		ToleranceCollection newTcoll = new ToleranceCollection(newAttr, items);
		// boolean flag=true;
		for (int i = 0; i < U.size(); i++) {
			for (int j = 0; j < newTcoll.getItems().get(U.get(i).getName()).size(); j++) {
				if (U.get(i).getAttributeValueByIndex(a + 1) != U.get(j).getAttributeValueByIndex(a + 1)) {
					newTcoll.getItems().get(U.get(i).getName()).remove(j);
					j--;
				}
			}
		}
		return newTcoll;
	}

	// 计算U/D
	public DupdateCollection computeDCategoryClass(ArrayList<Sample> U, int UCategory) {
		DupdateCollection DCategoryHash = new DupdateCollection(U.size());
		for (Sample x : U) {
			if (!DCategoryHash.getDupdate().containsKey(x.getDecisionValues())) {
				DupdateClass dupdateclass = new DupdateClass(UCategory, U.size());
				DCategoryHash.getDupdate().put(x.getDecisionValues(), dupdateclass);
			}
			DCategoryHash.getDupdate().get(x.getDecisionValues()).getList().add(x);
		}
		return DCategoryHash;
	}

	// 计算在B下的全U条件熵（非增量）
	public float computeConditionalEntropy(ArrayList<Sample> U, ToleranceCollection TColl,
			DupdateCollection DCategoryHash) {
		float THDP = 0;
		Set<Entry<Integer, ArrayList<Sample>>> entryset = TColl.getItems().entrySet();// 代表初始部分U下的sample的等价类
		for (Entry<Integer, ArrayList<Sample>> entrykey : entryset) {
			if (entrykey.getValue() != null && entrykey.getValue().size() != 0) {
				HashMap<Integer, Integer> TCintersectD = new HashMap<Integer, Integer>(
						DCategoryHash.getDupdate().size());
				for (int i = 0; i < entrykey.getValue().size(); i++) {// 在自己领域的
					int di = entrykey.getValue().get(i).getDecisionValues();
					if (!TCintersectD.containsKey(di))
						TCintersectD.put(di, 0);
					TCintersectD.replace(di, TCintersectD.get(di) + 1);
				}
				// System.out.print(TCintersectD.toString());
				Collection<Integer> valueset = TCintersectD.values();
				for (int number : valueset) {
					THDP -= (float) ((float) number / (float) U.size())
							* (float) Math.log10((float) ((float) number / (float) entrykey.getValue().size()));
				}
			}
		}
		return THDP;
	}

	// 计算两个集合中交集的数量 TP(ui)∩Dj
//	public int computetwoCollEqualsNumber(ArrayList<Sample> TP,ArrayList<Sample> Dj) {
//		int number=0;
//		for(Sample x1:TP) 
//			for(Sample x2:Dj) 
//				if(x1.getName()==x2.getName())
//					number++;
//		return number;
//	}
	// 计算属性重要度
	public Significance calculateSignificance(int attribute, int[] B, boolean is_inner, int USize, float initialTHDP,
			float newTHDP) {
		Significance attrSig = new Significance(attribute, B);
		if (!is_inner)
			attrSig.setSig(initialTHDP - newTHDP);
		else
			attrSig.setSig(newTHDP - initialTHDP);
		return attrSig;
	}

	// 冗余检验
	public float redundancy(int attribute, IntArrayKey Reduce, ToleranceCollection ReduceTColl,
			DupdateCollection DCategoryHash, float THDP_B, int USize, ArrayList<Sample> U) {
		IntArrayKey newAttr = new IntArrayKey(Reduce.key().clone());
		newAttr.deleteKey(attribute);
		ToleranceCollection TempColl = this.toleranceClass(newAttr, U);
		float THDP_Bdea = this.computeConditionalEntropy(U, TempColl, DCategoryHash);
		Significance sig = this.calculateSignificance(attribute, newAttr.key(), true, USize, THDP_B, THDP_Bdea);
		// System.out.print(THDP_Bdea);
		if (sig.getSig() == 0) {
			ReduceTColl = TempColl;
			return THDP_Bdea;
		}
		return THDP_B;
	}

	// 静态约简
	public StaticReduceResult staticReduce_IFSICE(ArrayList<Sample> U, int[] CName) {
		System.out.println("||静态约简开始");
		List<Integer> Reduce = new ArrayList<Integer>(CName.length);
		IntArrayKey C = new IntArrayKey(CName.length);
		IntArrayKey ReduceKey = new IntArrayKey();
		LinkedHashMap<String, Long> times = new LinkedHashMap<>(10);

		long start = System.currentTimeMillis();
		ToleranceCollection CTColl = this.toleranceClass(C, U);
		long end = System.currentTimeMillis();
		System.out.println("||全C下的等价类计算,时间：" + (end - start) + "ms," + (double) (end - start) / 1000 + "s");
		times.put("computeEquivalenceClassofC", end - start);
		// CTColl.outPut();

		start = System.currentTimeMillis();
		DupdateCollection DCategoryHash = this.computeDCategoryClass(U, 2);
		end = System.currentTimeMillis();
		System.out.println("||计算D分类,时间：" + (end - start) + "ms," + (double) (end - start) / 1000 + "s");
		times.put("computeDCategory", end - start);

		start = System.currentTimeMillis();
		float THDP_C = this.computeConditionalEntropy(U, CTColl, DCategoryHash);
		end = System.currentTimeMillis();
		System.out.println(
				"||计算全C下的条件熵THDP_C=" + THDP_C + ",时间：" + (end - start) + "ms," + (double) (end - start) / 1000 + "s");
		times.put("computeConditionalEntropyofC", end - start);

		// System.out.println("THDP_C:"+THDP_C+" ");
		// DCategoryHash.output();
		ToleranceCollection TempColl;
		ToleranceCollection max_tempColl = new ToleranceCollection();
		List<Integer> remainC = Arrays.stream(C.key()).boxed().collect(Collectors.toList());
		List<Integer> delete = new ArrayList<Integer>(C.key().length);

		start = System.currentTimeMillis();
		for (int i = 0; i < C.key().length; i++) {
			IntArrayKey newAttr = new IntArrayKey(CName.length); // B-a 初始化未完
			newAttr.deleteKey(i);
			TempColl = this.toleranceClass(newAttr, U);
			float THDP_temp = this.computeConditionalEntropy(U, TempColl, DCategoryHash);
			// TempColl=deleteAttributeCulTolerance(a, C, CTColl);
			Significance a_sig = this.calculateSignificance(i, newAttr.key(), true, U.size(), THDP_C, THDP_temp);
			// System.out.println(a_sig.getSig());
			if (a_sig.getSig() > 0) {
				Reduce.add(i);
				ReduceKey.addKey(i);
				delete.add(i);
			}
		}
		end = System.currentTimeMillis();
		System.out.println(
				"||求核计算,初始约简Reduce={" + Reduce + "},时间：" + (end - start) + "ms," + (double) (end - start) / 1000 + "s");
		times.put("computeCore", end - start);

		remainC.removeAll(delete);
		// System.out.println("remainC:"+remainC);
		Significance maxSig = new Significance();
		int max_a = 0;
		int j = -1;

		start = System.currentTimeMillis();
		max_tempColl = this.toleranceClass(ReduceKey, U);
		float THDP_B = this.computeConditionalEntropy(U, max_tempColl, DCategoryHash);
		end = System.currentTimeMillis();
		System.out.println("||计算B下的等价类及条件熵THDP_B=" + THDP_B + ",时间：" + (end - start) + "ms,"
				+ (double) (end - start) / 1000 + "s");
		times.put("computeECandEntropyofB", end - start);
		// System.out.println("THDP_B:"+THDP_B+" ");

		ToleranceCollection BTColl = max_tempColl;
		float THDP_max = 0;
		// System.out.println("Reduce:"+Reduce);

		start = System.currentTimeMillis();
		while (THDP_B != THDP_C) {
			maxSig = new Significance();
			for (int i = 0; i < remainC.size(); i++) {
				int a = remainC.get(i);
				IntArrayKey newAttr = new IntArrayKey(ReduceKey.key().clone()); // B-a 初始化未完
				newAttr.addKey(a);
				TempColl = this.toleranceClass(newAttr, U);
//				TempColl=this.toleranceClass_addAttribute(ReduceKey, a, U, BTColl);
				float THDP_temp = this.computeConditionalEntropy(U, TempColl, DCategoryHash);
				// System.out.print("THDP_temp:"+THDP_temp+" ");
				Significance a_sig = this.calculateSignificance(a, ReduceKey.key(), false, U.size(), THDP_B, THDP_temp);
				// System.out.println("sig="+a_sig.getSig());
				if (a_sig.getSig() > maxSig.getSig()) {
					max_a = a;
					max_tempColl = TempColl;
					THDP_max = THDP_temp;
					maxSig = a_sig;
					j = i;
				}
			}
			Reduce.add(max_a);
			ReduceKey.addKey(max_a);
			BTColl = max_tempColl;
			THDP_B = THDP_max;
			remainC.remove(j);
			// System.out.print("最优a："+max_a);
			// System.out.print("THDP_Reduce:"+THDP_B+" ");
			// System.out.println(Reduce);
			System.out.println("||最优特征{" + max_a + "}&THDP_B+{" + max_a + "}=" + THDP_B);
		}
		end = System.currentTimeMillis();
		System.out.println(
				"||迭代&Reduce={" + Reduce + "},时间：" + (end - start) + "ms," + (double) (end - start) / 1000 + "s");
		times.put("iteration", end - start);

		// 冗余检验
		start = System.currentTimeMillis();
		System.out.println("||冗余检验开始");
		for (int i = 0; i < Reduce.size(); i++) { // 删除冗余属性
			int a = Reduce.get(i);
			float redundancyTHDP = this.redundancy(a, ReduceKey, BTColl, DCategoryHash, THDP_B, U.size(), U); // 此时max_tempColl即为ReduceTCollection
			if (redundancyTHDP != THDP_B) {
				THDP_B = redundancyTHDP;
				ReduceKey.deleteKey(a);
				Reduce.remove(i);
				i--;
				remainC.add(a);
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

		StaticReduceResult result = new StaticReduceResult(Reduce, remainC, CTColl, BTColl, DCategoryHash, THDP_C,
				THDP_B, times);
		// System.out.println("最终约简："+Reduce);
		return result;
	}

	// 寻找交叉U的容差类
	public ArrayList<ToleranceCollection> toleranceClass_CROSSU(IntArrayKey attributeIndex, ArrayList<Sample> oldU,
			ArrayList<Sample> newU) {
		ToleranceCollection oldTcoll = new ToleranceCollection(attributeIndex, newU.size());// 代表初始部分U下的sample在U`中的等价类
		ToleranceCollection newTcoll = new ToleranceCollection(attributeIndex, oldU.size());// 代表增量部分U`下的sample在U中的等价类
		ArrayList<ToleranceCollection> TCollList = new ArrayList<ToleranceCollection>(2);
		boolean flag = true;
		for (int i = 0; i < oldU.size(); i++) {
			Sample x1 = oldU.get(i);
			for (int j = 0; j < newU.size(); j++) {
				Sample x2 = newU.get(j);
				flag = true;
				for (int z = 0; z < attributeIndex.key().length; z++) {
					// 条件属性在x中的下标从1开始
					if (x1.getAttributeValueByIndex(attributeIndex.key()[z] + 1) != x2
							.getAttributeValueByIndex(attributeIndex.key()[z] + 1)
							&& x1.getAttributeValueByIndex(attributeIndex.key()[z] + 1) != -1
							&& x2.getAttributeValueByIndex(attributeIndex.key()[z] + 1) != -1) {
						flag = false;
						break;
					}
				}
				if (flag) {
					// 如果不存在xi在U'下的等价类则不会新增
					if (!oldTcoll.getItems().containsKey(x1.getName()))
						oldTcoll.getItems().put(x1.getName(), new ArrayList<Sample>(newU.size()));
					if (!newTcoll.getItems().containsKey(x2.getName()))
						newTcoll.getItems().put(x2.getName(), new ArrayList<Sample>(oldU.size()));
					oldTcoll.getItems().get(x1.getName()).add(x2);
					newTcoll.getItems().get(x2.getName()).add(x1);
				}
			}
		}
		TCollList.add(oldTcoll);
		TCollList.add(newTcoll);
//		System.out.println("交叉容差类oldTcoll：");
//		oldTcoll.outPut();
//		System.out.println("交叉容差类newTcoll：");
//		newTcoll.outPut();
		return TCollList;
	}

	// 融合等价类
//	public ToleranceCollection fuseToleranceCollection(ToleranceCollection tcoll1,ToleranceCollection tcoll2) {
//		ToleranceCollection newTColl=new ToleranceCollection(tcoll1.getAttribute(),tcoll1.getItems().size());
//		Set<Entry<Integer,ArrayList<Sample>>> entryset=tcoll1.getItems().entrySet();
//		for(Entry<Integer,ArrayList<Sample>>entrylist:entryset) {
//			if(tcoll2.getItems().containsKey(entrylist.getKey())) {
//				ArrayList<Sample> list=(ArrayList<Sample>)tcoll1.getItems().get(entrylist.getKey()).clone();
//				list.addAll(tcoll2.getItems().get(entrylist.getKey()));
//				newTColl.getItems().put(entrylist.getKey(), list);	 			
//			}else {
//				System.out.print("融合等价类有误");
//			}
//		}
//		return newTColl;
//	}
	// 融合成为U`/D
	// 用完后将所有标签为3和1的变为2******
	public DupdateCollection fuseDCategoryClass_update(DupdateCollection DCategoryHash,
			DupdateCollection newDCategoryHash) {
		DupdateCollection crossDCategoryHash = DCategoryHash.clone();
		Set<Entry<Integer, DupdateClass>> entryset = newDCategoryHash.getDupdate().entrySet();
		for (Entry<Integer, DupdateClass> entrylist : entryset) {
			if (crossDCategoryHash.getDupdate().containsKey(entrylist.getKey())) {
				crossDCategoryHash.getDupdate().get(entrylist.getKey()).getList()
						.addAll(newDCategoryHash.getDupdate().get(entrylist.getKey()).getList());
				crossDCategoryHash.getDupdate().get(entrylist.getKey()).setCategory(1);
			} else {
				crossDCategoryHash.getDupdate().put(entrylist.getKey(),
						newDCategoryHash.getDupdate().get(entrylist.getKey()));
			}
		}
		return crossDCategoryHash;
	}

	// 计算T`p(ui)∩Dj的交集部分TH(两领域交叉部分g+1<=i<=n+h) 这里deta(tempTHDP)为负值
//	System.out.print("1:"+(float)(TCintersectD_self.get(entrykey4.getKey())));
//	System.out.print("2:"+(float)(oldU.size()+newU.size()));
//	System.out.print("3:"+(float)TColl.getItems().get(entrykey.getKey()).size());
//	System.out.print("4:"+(float)TCintersectD.get(entrykey4.getKey()));
//	System.out.print("5:"+(float)(entrykey.getValue().size()+TColl.getItems().get(entrykey.getKey()).size()));
//	System.out.print("6:"+(float)TCintersectD_self.get(entrykey4.getKey()));
//	System.out.println("7:"+Math.log10((float)(((float)TColl.getItems().get(entrykey.getKey()).size()*(float)TCintersectD.get(entrykey4.getKey()))/((float)(entrykey.getValue().size()+TColl.getItems().get(entrykey.getKey()).size())*(float)TCintersectD_self.get(entrykey4.getKey())))));	
	public float computeToleranceIntersectDCrossTHDP_update(ArrayList<Sample> oldU, ArrayList<Sample> newU,
			ToleranceCollection oldTC, ToleranceCollection newTC, ArrayList<ToleranceCollection> crossTC,
			DupdateCollection totalDCategoryHash) {
		float tempTHDP = 0;
		ToleranceCollection TColl;
		for (int k = 0; k < crossTC.size(); k++) {
			Set<Entry<Integer, ArrayList<Sample>>> entryset1 = crossTC.get(k).getItems().entrySet();// 代表初始部分U下的sample在U`中的等价类
			if (k == 0)
				TColl = oldTC;// U中samples在U下的TC
			else
				TColl = newTC;// U'中samples在U'下的TC
			for (Entry<Integer, ArrayList<Sample>> entrykey : entryset1) {
				if (entrykey.getValue() != null && entrykey.getValue().size() != 0) { // 此时g+1<=i<=n+h
					HashMap<Integer, Integer> TCintersectD = new HashMap<Integer, Integer>(
							totalDCategoryHash.getDupdate().size());
					HashMap<Integer, Integer> TCintersectD_self = new HashMap<Integer, Integer>(
							totalDCategoryHash.getDupdate().size());
					// if(!TColl.getItems().get(entrykey.getKey()).isEmpty())
					for (int i = 0; i < TColl.getItems().get(entrykey.getKey()).size(); i++) {// 在自己领域的
						int di = TColl.getItems().get(entrykey.getKey()).get(i).getDecisionValues();
						if (!TCintersectD.containsKey(di))
							TCintersectD.put(di, 0);
						TCintersectD.replace(di, TCintersectD.get(di) + 1);
						if (!TCintersectD_self.containsKey(di))
							TCintersectD_self.put(di, 0);
						TCintersectD_self.replace(di, TCintersectD_self.get(di) + 1);
					}
					HashMap<Integer, Integer> TCintersectD_other = new HashMap<Integer, Integer>(
							totalDCategoryHash.getDupdate().size());
					// if(!entrykey.getValue().isEmpty())
					for (int i = 0; i < entrykey.getValue().size(); i++) {// 在对方领域的
						int di = entrykey.getValue().get(i).getDecisionValues();
						if (!TCintersectD.containsKey(di))
							TCintersectD.put(di, 0);
						TCintersectD.replace(di, TCintersectD.get(di) + 1);
						if (!TCintersectD_other.containsKey(di))
							TCintersectD_other.put(di, 0);
						TCintersectD_other.replace(di, TCintersectD_other.get(di) + 1);
					}
					Set<Entry<Integer, DupdateClass>> entryset4 = totalDCategoryHash.getDupdate().entrySet();
					for (Entry<Integer, DupdateClass> entrykey4 : entryset4) {
						// System.out.print("D="+entrykey4.getKey().toString()+"
						// Category="+entrykey4.getValue().getCategory()+" ");
						if (entrykey4.getValue().getCategory() == 1) { // 1为Ej∪Fj; 2为Ej; 3为F j-d+r
							if (TCintersectD_self.containsKey(entrykey4.getKey()))
								tempTHDP += ((float) (TCintersectD_self.get(entrykey4.getKey())
										/ (float) (oldU.size() + newU.size()))
										* Math.log10((float) (((float) TColl.getItems().get(entrykey.getKey()).size()
												* (float) TCintersectD.get(entrykey4.getKey()))
												/ ((float) (entrykey.getValue().size()
														+ TColl.getItems().get(entrykey.getKey()).size())
														* (float) TCintersectD_self.get(entrykey4.getKey())))));
							if (TCintersectD_other.containsKey(entrykey4.getKey()))
								tempTHDP += ((float) (TCintersectD_other.get(entrykey4.getKey())
										/ (float) (oldU.size() + newU.size()))
										* Math.log10((float) TCintersectD.get(entrykey4.getKey())
												/ (float) (entrykey.getValue().size()
														+ TColl.getItems().get(entrykey.getKey()).size())));
						} else if (entrykey4.getValue().getCategory() == 2) { // 1为Ej∪Fj; 2为Ej; 3为F j-d+r
							if (TCintersectD_self.containsKey(entrykey4.getKey()))
								tempTHDP += ((float) (TCintersectD_self.get(entrykey4.getKey())
										/ (float) (oldU.size() + newU.size()))
										* Math.log10((float) ((float) TColl.getItems().get(entrykey.getKey()).size()
												/ (float) (entrykey.getValue().size()
														+ TColl.getItems().get(entrykey.getKey()).size()))));
							if (TCintersectD_other.containsKey(entrykey4.getKey()))
								tempTHDP += ((float) (TCintersectD_other.get(entrykey4.getKey())
										/ (float) (oldU.size() + newU.size()))
										* Math.log10((float) TCintersectD_other.get(entrykey4.getKey())
												/ (float) (entrykey.getValue().size()
														+ TColl.getItems().get(entrykey.getKey()).size())));
						} else if (entrykey4.getValue().getCategory() == 3) { // 1为Ej∪Fj; 2为Ej; 3为F j-d+r
							if (TCintersectD_self.containsKey(entrykey4.getKey()))
								tempTHDP += ((float) (TCintersectD_self.get(entrykey4.getKey())
										/ (float) (oldU.size() + newU.size()))
										* Math.log10((float) ((float) TColl.getItems().get(entrykey.getKey()).size()
												/ (float) (entrykey.getValue().size()
														+ TColl.getItems().get(entrykey.getKey()).size()))));
							if (TCintersectD_other.containsKey(entrykey4.getKey()))
								tempTHDP += ((float) (TCintersectD_other.get(entrykey4.getKey())
										/ (float) (oldU.size() + newU.size()))
										* Math.log10((float) TCintersectD_other.get(entrykey4.getKey())
												/ (float) (entrykey.getValue().size()
														+ TColl.getItems().get(entrykey.getKey()).size())));
						}
						// System.out.println("tempTHDP="+tempTHDP);
					}
				}
			}
		}
		return tempTHDP;
	}

	// 计算在B下的全U条件熵（增量）
	public float computeConditionalEntropy_update(int oldUSize, int newUSize, float oldTHDP, float newTHDP,
			float crossTHDP) {
		float totalTHDP = ((float) (oldUSize * oldTHDP + newUSize * newTHDP) / (float) (oldUSize + newUSize)
				- crossTHDP);// 这里crossTHDP为负值（原本公式应为-而不是+）
		// System.out.print("THDP_U&newUpart="+(float)(oldUSize*oldTHDP+newUSize*newTHDP)/(float)(oldUSize+newUSize)+"
		// ");
		return totalTHDP;
	}

	// 计算属性attributes下增量条件熵
	public ToleranceCollectionUpdateResult calculateConditionEntropyOfAttributes_update(IntArrayKey attributes,
			ArrayList<Sample> U, ArrayList<Sample> newU, DupdateCollection oldDCategoryHash,
			DupdateCollection crossDCategoryHash, DupdateCollection newDCategoryHash) {
		ToleranceCollection BTColl_temp = this.toleranceClass(attributes, U);
		float THDP_B_newtemp = this.computeConditionalEntropy(U, BTColl_temp, oldDCategoryHash);
		ToleranceCollection newpartBTColl_temp = this.toleranceClass(attributes, newU);
		float THDP_B_newpart = this.computeConditionalEntropy(newU, newpartBTColl_temp, newDCategoryHash);
		ArrayList<ToleranceCollection> crosspartBToll = this.toleranceClass_CROSSU(attributes, U, newU);
		float THDP_B_cross = this.computeToleranceIntersectDCrossTHDP_update(U, newU, BTColl_temp, newpartBTColl_temp,
				crosspartBToll, crossDCategoryHash);
		float THDP_temp = this.computeConditionalEntropy_update(U.size(), newU.size(), THDP_B_newtemp, THDP_B_newpart,
				THDP_B_cross);
		ToleranceCollectionUpdateResult TCResult = new ToleranceCollectionUpdateResult(BTColl_temp, THDP_B_newtemp,
				newpartBTColl_temp, THDP_B_newpart, crosspartBToll, THDP_B_cross, THDP_temp);
		return TCResult;
	}

	// 冗余检验
	public ToleranceCollectionUpdateResult redundancy_update(int attribute, IntArrayKey Reduce,
			DupdateCollection oldDCategoryHash, DupdateCollection crossDCategoryHash,
			DupdateCollection newDCategoryHash, float THDP_B_new, ArrayList<Sample> U, ArrayList<Sample> newU) {
		IntArrayKey newAttr = new IntArrayKey(Reduce.key().clone());
		newAttr.deleteKey(attribute);
		// 写一个方法 包含进去
//		ToleranceCollection BTColl_temp=this.toleranceClass(newAttr, U);
//		float THDP_B_newtemp=this.computeConditionalEntropy(U, BTColl_temp, oldDCategoryHash);
//		ToleranceCollection newpartBTColl_temp=this.toleranceClass(newAttr, newU);
//		float THDP_B_newpart=this.computeConditionalEntropy(newU, newpartBTColl_temp, newDCategoryHash);
//		ArrayList<ToleranceCollection> crosspartBToll=this.toleranceClass_CROSSU(newAttr, U, newU);
//		float THDP_B_cross=this.computeToleranceIntersectDCrossTHDP_update(U, newU, BTColl_temp, newpartBTColl_temp, crosspartBToll, crossDCategoryHash);
//		float THDP_temp=this.computeConditionalEntropy_update(U.size(), newU.size(), THDP_B_newtemp, THDP_B_newpart, THDP_B_cross);				
		ToleranceCollectionUpdateResult TCResult = this.calculateConditionEntropyOfAttributes_update(newAttr, U, newU,
				oldDCategoryHash, crossDCategoryHash, newDCategoryHash);
		Significance sig = this.calculateSignificance(attribute, Reduce.key(), true, U.size(), THDP_B_new,
				TCResult.getTHDP_new());
		// System.out.print(THDP_temp);
		if (sig.getSig() == 0)
			return TCResult;
		return new ToleranceCollectionUpdateResult(true);
	}

	// 增量约简
	public StaticReduceResult IFSICEReduce_Incremental(ArrayList<Sample> U, ArrayList<Sample> newU, int[] CName,
			StaticReduceResult previousResult) {
		StaticReduceResult result=new StaticReduceResult();
		try {
		System.out.println("||增量约简开始");
		List<Integer> newReduce = new ArrayList<Integer>(CName.length);
		newReduce.addAll(previousResult.getOldReduce());
		IntArrayKey C = new IntArrayKey(CName);
		List<Integer> remainC = previousResult.getRemainC();
		IntArrayKey ReduceKey = new IntArrayKey(newReduce.stream().mapToInt(Integer::valueOf).toArray());
		LinkedHashMap<String, Long> times = new LinkedHashMap<>(10);

		// update U`/D`
		long start = System.currentTimeMillis();
		DupdateCollection newDCategory = this.computeDCategoryClass(newU, 3); // 新增部分标签为3
		DupdateCollection crossDCategoryHash = this.fuseDCategoryClass_update(previousResult.getOldDCategoryHash(),
				newDCategory);// D融合
		long end = System.currentTimeMillis();
		System.out.println("||更新D分类,时间：" + (end - start) + "ms," + (double) (end - start) / 1000 + "s");
		times.put("updateDCategory", end - start);
		// System.out.print("corssDCategory:");
		// crossDCategoryHash.output();

		// update 在U∪U`全c下的容差类和THDP
		start = System.currentTimeMillis();
		ToleranceCollection newpartCTColl = this.toleranceClass(C, newU);
		float THDP_C_newpart = this.computeConditionalEntropy(newU, newpartCTColl, newDCategory);
		// .out.print("THDP_C_newpart:"+THDP_C_newpart+" ");
		ArrayList<ToleranceCollection> crosspartCToll = this.toleranceClass_CROSSU(C, U, newU);
//		for(ToleranceCollection tc:crosspartCToll)
//			tc.outPut();
		float THDP_C_cross = this.computeToleranceIntersectDCrossTHDP_update(U, newU, previousResult.getOldCTColl(),
				newpartCTColl, crosspartCToll, crossDCategoryHash);
		// System.out.print("THDP_C_cross:"+THDP_C_cross+" ");
		float THDP_C_new = this.computeConditionalEntropy_update(U.size(), newU.size(), previousResult.getTHDP_C(),
				THDP_C_newpart, THDP_C_cross);
		// System.out.println("THDP_C:"+THDP_C_new+" ");
		end = System.currentTimeMillis();
		System.out.println("||更新全C下的等价类和条件熵THDP_C=" + THDP_C_new + ",时间：" + (end - start) + "ms,"
				+ (double) (end - start) / 1000 + "s");
		times.put("updateECandEntropyofC", end - start);

		// update 在U∪U`B下的容差类和THDP
		start = System.currentTimeMillis();
		ToleranceCollection newpartBTColl = this.toleranceClass(ReduceKey, newU);
		float THDP_B_newpart = this.computeConditionalEntropy(newU, newpartBTColl, newDCategory);
		// System.out.print("THDP_B_newpart:"+THDP_B_newpart+" ");
		ArrayList<ToleranceCollection> crosspartBToll = this.toleranceClass_CROSSU(ReduceKey, U, newU);
		float THDP_B_cross = this.computeToleranceIntersectDCrossTHDP_update(U, newU, previousResult.getOldBTColl(),
				newpartBTColl, crosspartBToll, crossDCategoryHash);
		// System.out.print("THDP_B_corss:"+THDP_B_cross);
		float THDP_B_new = this.computeConditionalEntropy_update(U.size(), newU.size(), previousResult.getTHDP_B(),
				THDP_B_newpart, THDP_B_cross);
		// System.out.println("THDP_B:"+THDP_B_new);
		end = System.currentTimeMillis();
		System.out.println("||更新B下的等价类和条件熵THDP_B=" + THDP_B_new + ",时间：" + (end - start) + "ms,"
				+ (double) (end - start) / 1000 + "s");
		times.put("updateECandEntropyofB", end - start);

		Significance maxSig = new Significance();
		int max_a = 0;
		int j = -1;
		ToleranceCollection max_BTColl_temp = previousResult.getOldBTColl();
		ToleranceCollection max_newpartBTColl_temp = newpartBTColl;
		float THDP_temp = 0;
		float THDP_max = 0;
		ToleranceCollection BTColl = previousResult.getOldBTColl();
		// System.out.println("remainC:"+previousResult.getRemainC().toString());

		start = System.currentTimeMillis();
		while (Math.abs(THDP_C_new - THDP_B_new) >= 0.001||remainC.size()!=0) {
			maxSig = new Significance();
			for (int i = 0; i < remainC.size(); i++) {
				int a = remainC.get(i);
				IntArrayKey B = new IntArrayKey(ReduceKey.key().clone());
				B.addKey(a);
				ToleranceCollectionUpdateResult TCUpdateResult = calculateConditionEntropyOfAttributes_update(B, U,
						newU, previousResult.getOldDCategoryHash(), crossDCategoryHash, newDCategory);
//				ToleranceCollection BTColl_temp=this.toleranceClass(B, U);
//				ToleranceCollection newpartBTColl_temp=this.toleranceClass(B, newU);
//				float THDP_B_newtemp=this.computeConditionalEntropy(U, BTColl, oldDCategoryHash);
//				//System.out.print("THDP_B_newtemp:"+THDP_B_newtemp+"  ");
//				THDP_B_newpart=this.computeConditionalEntropy(newU, newpartBTColl_temp, newDCategory);
//				crosspartBToll=this.toleranceClass_CROSSU(B, U, newU);
//				THDP_B_cross=this.computeToleranceIntersectDCrossTHDP_update(U, newU, BTColl_temp, newpartBTColl_temp, crosspartBToll, crossDCategoryHash);
//				THDP_temp=this.computeConditionalEntropy_update(U.size(), newU.size(), THDP_B_newtemp, THDP_B_newpart, THDP_B_cross);				
//				System.out.print("THDP_temp:"+THDP_temp+"  ");		
				Significance a_sig = this.calculateSignificance(a, ReduceKey.key(), false, U.size(), THDP_B_new,
						TCUpdateResult.getTHDP_new());
				// System.out.println("sig:"+a_sig.getSig());
				if (a_sig.getSig() > maxSig.getSig()) {
					max_a = a;
					max_BTColl_temp = TCUpdateResult.getBTColl_temp();
					max_newpartBTColl_temp = TCUpdateResult.getNewpartBTColl_temp();
					THDP_max = TCUpdateResult.getTHDP_new();
					maxSig = a_sig;
					j = i;
				}
			}
			if (maxSig.getSig() < 0 && Math.abs(THDP_C_new - THDP_B_new) <= 0.01) {
				System.out.println("**********精度问题出错");
				break;
			}
//			if(THDP_B_new == THDP_max)  //20230224
//				break;
			THDP_B_new = THDP_max;
			newReduce.add(max_a);
			ReduceKey.addKey(max_a);
			BTColl = max_BTColl_temp;
			newpartBTColl = max_newpartBTColl_temp;			
			remainC.remove(j);
			// System.out.print("最优a："+max_a+",THDP="+THDP_B_new+" ");
			// System.out.println(newReduce);
			System.out.println("||最优特征{" + max_a + "}&THDP_B+{" + max_a + "}=" + THDP_B_new+",remainC:"+remainC.size());
			if(remainC.size()==0)
				break;
		}
		end = System.currentTimeMillis();
		System.out.println(
				"||迭代&Reduce={" + newReduce + "},时间：" + (end - start) + "ms," + (double) (end - start) / 1000 + "s");
		times.put("iteration", end - start);

		// 冗余检验
		start = System.currentTimeMillis();
		System.out.println("||冗余约简开始");
		for (int i = 0; i < newReduce.size(); i++) { // 删除冗余属性
			int a = newReduce.get(i);
			ToleranceCollectionUpdateResult redundancyTCResult = this.redundancy_update(a, ReduceKey,
					previousResult.getOldDCategoryHash(), crossDCategoryHash, newDCategory, THDP_B_new, U, newU); // 此时max_tempColl即为ReduceTCollection
			if (!redundancyTCResult.is_Empty()) {
				newReduce.remove(i);
				ReduceKey.deleteKey(a);
				i--;
				remainC.add(a);
				THDP_B_new = redundancyTCResult.getTHDP_new();
				System.out.println("||删除特征{" + a + "}");
			}
		}
		end = System.currentTimeMillis();
		System.out.println("||冗余检验结束：" + (end - start) + "ms," + (double) (end - start) / 1000 + "s");
		times.put("redundancy", end - start);
		long alltime = 0;
		for (long i : times.values())
			alltime += i;
		System.out.println("||最终约简Reduce={" + newReduce + "},约简数量=" + newReduce.size());
		System.out.println("||总时间：" + alltime + "ms," + (double) (alltime) / 1000 + "s");

//		// System.out.println("最终约简:"+newReduce); //newU=new
//		// ArrayList<Sample>();//this.CTColl=this.toleranceClass(C, U);
//		// //this.ReduceTColl=this.toleranceClass(ReduceKey, U);
//		U.addAll(newU);
//		this.changeDCategoryHashLabelto2(crossDCategoryHash);
//		// this.DCategoryHash=crossDCategoryHash;
//		StaticReduceResult result = new StaticReduceResult(newReduce, remainC, this.toleranceClass(C, U),
//				this.toleranceClass(ReduceKey, U), crossDCategoryHash, THDP_C_new, THDP_B_new, times);
//		// newU=new ArrayList<Sample>();
//		return result;
		
		result=new StaticReduceResult(newReduce,times);
		//System.out.println("最终约简:"+newReduce);		//newU=new ArrayList<Sample>();//this.CTColl=this.toleranceClass(C, U);	//this.ReduceTColl=this.toleranceClass(ReduceKey, U);
				
			U.addAll(newU);
			this.changeDCategoryHashLabelto2(crossDCategoryHash);
			//this.DCategoryHash=crossDCategoryHash;	
			ToleranceCollection oldCTColl=this.toleranceClass(C, U);
			ToleranceCollection oldBTColl=this.toleranceClass(ReduceKey, U);
			result=new StaticReduceResult(newReduce,remainC,oldCTColl,oldBTColl,crossDCategoryHash,THDP_C_new,THDP_B_new,times);	
			return result;
		//newU=new ArrayList<Sample>();
		}catch(Throwable e){
			System.out.println("||Error:"+e);
			return result;
		}
	}

	// 修改所有DCatrgoryHash标签为2
	public DupdateCollection changeDCategoryHashLabelto2(DupdateCollection DCategoryHash) {
		// Set<Entry<Integer,DupdateClass>>
		// entryset=DCategoryHash.getDupdate().entrySet();
		for (DupdateClass i : DCategoryHash.getDupdate().values())
			i.setCategory(2);
		return DCategoryHash;
	}
}

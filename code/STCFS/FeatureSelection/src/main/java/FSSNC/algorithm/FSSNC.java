package main.java.FSSNC.algorithm;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.Set;
import java.util.Map.Entry;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import main.Log4jPrintStream;
import main.basic.model.ProcessingResult;
import main.java.FSSNC.entity.DstrippedCover;
import main.java.FSSNC.entity.IntArrayKey;
import main.java.FSSNC.entity.Sample;
//import main.java.FSSNC.entity.ToleranceEquivalenceClass;
import main.java.FSSNC.entity.Significance;
import main.java.FSSNC.entity.StaticReduceResult;

public class FSSNC {
//	public String filePath;
//	public ArrayList<Sample> U;
//	public int USize;
//	public int[] CName;
//	public ArrayList<String[]> dataArray;
//	public List<Integer> Reduce;
//	public float σ;
//	public int[] numberDataCindex;
//	public HashMap<Integer,ArrayList<String[]>> dividedata;
//	public LinkedList<ProcessingResult> processingResultList=new LinkedList<>();
	
	static {Log4jPrintStream.redirectSystemOut();}
	public FSSNC() {}
	
//****************************************************************************
	
	//判断属性a是否属于number属性
	public boolean isAinNumber(int Cindex,int[]numberDataCindex) {
		for(int a:numberDataCindex)
			if(Cindex==a)
				return true;
		return false;
	}
	//从查找B条件下的D剥离邻域覆盖的等价类
	public DstrippedCover toleranceClass_old(IntArrayKey attributeIndex,ArrayList<Sample> U,float σ,int[] numberDataCindex){
		DstrippedCover dsc=new DstrippedCover(attributeIndex,U.size());
		boolean flag=true;
		for(int i=0;i<U.size();i++){
			Sample x1=U.get(i);	
			if(!dsc.getNotDTolerance().containsKey(i)) {
				dsc.getNotDTolerance().put(i, new LinkedList<Integer>());
				dsc.getDTolerance().put(i, new LinkedList<Integer>());
			}
			dsc.getNotDTolerance().get(i).add(i);
			dsc.getDTolerance().get(i).add(i);		
			for(int j=i+1;j<U.size();j++){
				Sample x2=U.get(j);
				flag=true;
				//float dis=0;
				for(int z=0;z<attributeIndex.key().length;z++){
					float x1value=x1.getAttributeValueByIndex(attributeIndex.key()[z]+1);
					float x2value=x2.getAttributeValueByIndex(attributeIndex.key()[z]+1);
					//条件属性在x中的下标从1开始
//					if(!isAinNumber(z, numberDataCindex)) {
//						if(x1.getAttributeValueByIndex(attributeIndex.key()[z]+1)!=x2.getAttributeValueByIndex(attributeIndex.key()[z]+1)&&x1.getAttributeValueByIndex(attributeIndex.key()[z]+1)!=(float)-1.0&&x2.getAttributeValueByIndex(attributeIndex.key()[z]+1)!=(float)-1.0){
//							flag=false;
//							break;
//						}
//					}else {
						if(x1value!=(float)-1.0&&x2value!=(float)-1.0){
							//dis+=Math.pow((x1.getAttributeValueByIndex(attributeIndex.key()[z]+1)-x2.getAttributeValueByIndex(attributeIndex.key()[z]+1)), 2);
							if((float)Math.sqrt(Math.pow((x1value-x2value), 2))>σ) {
								flag=false;
								break;
							}
								
						}
					//}
				}
//				dis=(float)Math.sqrt(dis);
//				if(dis>σ)
//					flag=false;
				if(flag){    
					if(!dsc.getNotDTolerance().containsKey(j)) {
						dsc.getNotDTolerance().put(j, new LinkedList<Integer>());
						dsc.getDTolerance().put(j, new LinkedList<Integer>());
					}
					dsc.getNotDTolerance().get(j).add(i);
					dsc.getNotDTolerance().get(i).add(j);
					if(x1.getAttributeValueByIndex(0)==x2.getAttributeValueByIndex(0)){   //D
						dsc.getDTolerance().get(j).add(i);
						dsc.getDTolerance().get(i).add(j);
					}
				}
			}	
			//如果相等即xi属于POS 则删除
			if(dsc.getDTolerance().get(i).size()==dsc.getNotDTolerance().get(i).size()) {
				dsc.getDTolerance().remove(i);
				dsc.getNotDTolerance().remove(i);
			}else {
				dsc.getTotalNotDNumber()[i]=dsc.getNotDTolerance().get(i).size();
				dsc.getTotalDNumber()[i]=dsc.getDTolerance().get(i).size();
			}			
		}		
		return dsc;
	}
	//新 节省空间 20230201
	public DstrippedCover toleranceClass(IntArrayKey attributeIndex,ArrayList<Sample> U,float σ,int[] numberDataCindex){
		DstrippedCover dsc=new DstrippedCover(attributeIndex,U.size());
		boolean flag=true;		
		for(int i=0;i<U.size();i++){
			Sample x1=U.get(i);	
			LinkedList<Integer> notDlist=new LinkedList<Integer>();
			LinkedList<Integer> Dlist=new LinkedList<Integer>();	
			for(int j=0;j<U.size();j++){
				Sample x2=U.get(j);
				flag=true;
				if(i!=j)
				for(int z=0;z<attributeIndex.key().length;z++){
					float x1value=x1.getAttributeValueByIndex(attributeIndex.key()[z]+1);
					float x2value=x2.getAttributeValueByIndex(attributeIndex.key()[z]+1);
					//条件属性在x中的下标从1开始
						if(x1value!=(float)-1.0&&x2value!=(float)-1.0){
							if((float)Math.sqrt(Math.pow((x1value-x2value), 2))>σ) {
								flag=false;
								break;
							}								
						}
				}
				if(flag){    
					notDlist.add(j);
					if(x1.getAttributeValueByIndex(0)==x2.getAttributeValueByIndex(0)){   //D
						Dlist.add(j);
					}
				}
			}	
			//如果相等即xi属于POS 则添加
			if(notDlist.size()!=Dlist.size()) {
				dsc.getNotDTolerance().put(i, notDlist);
				dsc.getDTolerance().put(i, Dlist);
				dsc.getTotalNotDNumber()[i]=notDlist.size();
				dsc.getTotalDNumber()[i]=Dlist.size();	
			}
		}		
		return dsc;
	}
	//从B中删除一个元素计算容差类
//	public DstrippedCover deleteAttributeCulTolerance(int attribute,IntArrayKey attributes,DstrippedCover dsc) {
//		
//		return dsc;
//	}
	//从B中添加一个元素计算容差类
	public DstrippedCover addAttributeCulTolerance_old(int attribute,IntArrayKey attributes,DstrippedCover oneAttrdsc,DstrippedCover dsc,int[] numberDataCindex,ArrayList<Sample> U) {
		//DstrippedCover attrdsc=this.toleranceClass(new IntArrayKey(attribute), U, this.σ,numberDataCindex);
		DstrippedCover newdsc=new DstrippedCover().clone(dsc);
//		IntArrayKey newAttr=new IntArrayKey(attributes.key().clone());  //B-a  初始化未完
//		newAttr.addKey(attribute);
//		newdsc.setAttributes(attributes);
		newdsc.getAttributes().addKey(attribute);
		for(int index:dsc.getNotDTolerance().keySet()) {  //20220820
			if(!oneAttrdsc.getNotDTolerance().containsKey(index)) {
				newdsc.getNotDTolerance().remove(index);
				newdsc.getDTolerance().remove(index);
				newdsc.getTotalNotDNumber()[index]=0;
				newdsc.getTotalDNumber()[index]=0;
			}else {
				LinkedList<Integer> noDvaluelist=new LinkedList<Integer>();
				LinkedList<Integer> Dvaluelist=new LinkedList<Integer>();
				float indexD=U.get(index).getAttributeValueByIndex(0);
				//boolean flag=true;
				for(int i=0;i<newdsc.getNotDTolerance().get(index).size();i++) {
					int value=newdsc.getNotDTolerance().get(index).get(i);
					if(oneAttrdsc.getNotDTolerance().get(index).contains(value)) {
						noDvaluelist.add(value);
						if(U.get(value).getAttributeValueByIndex(0)==indexD)
							Dvaluelist.add(value);
					}
				}				
				if(noDvaluelist.size()!=Dvaluelist.size()) {
					newdsc.getNotDTolerance().replace(index,noDvaluelist);
					newdsc.getDTolerance().replace(index,Dvaluelist);
					newdsc.getTotalNotDNumber()[index]=newdsc.getNotDTolerance().get(index).size();
					newdsc.getTotalDNumber()[index]=newdsc.getDTolerance().get(index).size();
				}else {
					newdsc.getDTolerance().remove(index);
					newdsc.getNotDTolerance().remove(index);
					newdsc.getTotalNotDNumber()[index]=0;
					newdsc.getTotalDNumber()[index]=0;
				}
			}
		//}
		}
		return newdsc;
	}
	public DstrippedCover addAttributeCulTolerance(int attribute,IntArrayKey attributes,DstrippedCover oneAttrdsc,DstrippedCover dsc,int[] numberDataCindex,ArrayList<Sample> U) {
		DstrippedCover newdsc=new DstrippedCover(U.size());
		//IntArrayKey newattributes=new IntArrayKey(attributes.key());//不将attributes添加到newdsc中		
		for(int index:dsc.getNotDTolerance().keySet()) {  //20220820
			if(oneAttrdsc.getNotDTolerance().containsKey(index)) {
				LinkedList<Integer> noDvaluelist=new LinkedList<Integer>();
				LinkedList<Integer> Dvaluelist=new LinkedList<Integer>();
				float indexD=U.get(index).getAttributeValueByIndex(0);
				//boolean flag=true;
				for(int i=0;i<dsc.getNotDTolerance().get(index).size();i++) {
					int value=dsc.getNotDTolerance().get(index).get(i);
					if(oneAttrdsc.getNotDTolerance().get(index).contains(value)) {
						noDvaluelist.add(value);
						if(U.get(value).getAttributeValueByIndex(0)==indexD)
							Dvaluelist.add(value);
					}
				}				
				if(noDvaluelist.size()!=Dvaluelist.size()) {
					newdsc.getNotDTolerance().put(index,noDvaluelist);
					newdsc.getDTolerance().put(index,Dvaluelist);
					newdsc.getTotalNotDNumber()[index]=noDvaluelist.size();
					newdsc.getTotalDNumber()[index]=Dvaluelist.size();	
				}
			}
		//}
		}
		return newdsc;
	}
	public DstrippedCover addAttributeCulTolerance_new2(int attribute,IntArrayKey attributes,DstrippedCover oneAttrdsc,DstrippedCover dsc,int[] numberDataCindex,ArrayList<Sample> U) {
		DstrippedCover newdsc=new DstrippedCover(U.size());
		//IntArrayKey newattributes=new IntArrayKey(attributes.key());//不将attributes添加到newdsc中		
		for(int index:dsc.getNotDTolerance().keySet()) {  //20220820
			if(oneAttrdsc.getNotDTolerance().containsKey(index)) {
				LinkedList<Integer> noDvaluelist=new LinkedList<Integer>();
				LinkedList<Integer> Dvaluelist=new LinkedList<Integer>();
				float indexD=U.get(index).getAttributeValueByIndex(0);
				List<Integer> collect = dsc.getNotDTolerance().get(index).stream().filter(item -> oneAttrdsc.getNotDTolerance().get(index).contains(item)).collect(Collectors.toList());
				noDvaluelist=collect.stream().collect(Collectors.toCollection(LinkedList::new));
				for(int x2:noDvaluelist) {
					if(U.get(x2).getAttributeValueByIndex(0)==indexD)
						Dvaluelist.add(x2);
				}
				if(noDvaluelist.size()!=Dvaluelist.size()) {
					newdsc.getNotDTolerance().put(index,noDvaluelist);
					newdsc.getDTolerance().put(index,Dvaluelist);
					newdsc.getTotalNotDNumber()[index]=noDvaluelist.size();
					newdsc.getTotalDNumber()[index]=Dvaluelist.size();	
				}
			}
		}
		return newdsc;
	}
	public DstrippedCover addAttributeCulTolerance_new3(int attribute,IntArrayKey attributes,float σ,DstrippedCover dsc,int[] numberDataCindex,ArrayList<Sample> U) {
		DstrippedCover newdsc=new DstrippedCover(U.size());
		IntArrayKey attributekey=new IntArrayKey();
		attributekey.addKey(attribute);
		DstrippedCover oneAttrdsc=this.toleranceClass(attributekey, U,σ, numberDataCindex);
		//IntArrayKey newattributes=new IntArrayKey(attributes.key());//不将attributes添加到newdsc中		
		for(int index:dsc.getNotDTolerance().keySet()) {  //20220820
			if(oneAttrdsc.getNotDTolerance().containsKey(index)) {
				LinkedList<Integer> noDvaluelist=new LinkedList<Integer>();
				LinkedList<Integer> Dvaluelist=new LinkedList<Integer>();
				float indexD=U.get(index).getAttributeValueByIndex(0);
				//方法1
				List<Integer> collect = dsc.getNotDTolerance().get(index).stream().filter(item -> oneAttrdsc.getNotDTolerance().get(index).contains(item)).collect(Collectors.toList());
				noDvaluelist=collect.stream().collect(Collectors.toCollection(LinkedList::new));
				for(int x2:noDvaluelist) {
					if(U.get(x2).getAttributeValueByIndex(0)==indexD)
						Dvaluelist.add(x2);
				}
				//方法2
//				for(int i=0;i<dsc.getNotDTolerance().get(index).size();i++) {
//					int value=dsc.getNotDTolerance().get(index).get(i);
//					if(oneAttrdsc.getNotDTolerance().get(index).contains(value)) {
//						noDvaluelist.add(value);
//						if(U.get(value).getAttributeValueByIndex(0)==indexD)
//							Dvaluelist.add(value);
//					}
//				}	
				if(noDvaluelist.size()!=Dvaluelist.size()) {
					newdsc.getNotDTolerance().put(index,noDvaluelist);
					newdsc.getDTolerance().put(index,Dvaluelist);
					newdsc.getTotalNotDNumber()[index]=noDvaluelist.size();
					newdsc.getTotalDNumber()[index]=Dvaluelist.size();	
				}
			}
		}
		return newdsc;
	}
	//计算重要度
	public Significance calculateSignificance(int attribute,int[] B,boolean is_inner,int USize,DstrippedCover initialCover,DstrippedCover newCover) {
		Significance attrSig=new Significance(attribute,B);
		attrSig.calculateSig_common(is_inner, USize, initialCover, newCover);
		return attrSig;
	}
	//冗余检验
	public boolean redundancy(IntArrayKey B,DstrippedCover ReduceCover,ArrayList<Sample> U,float σ,int[] numberDataCindex) {		
		DstrippedCover newCover=this.toleranceClass(B, U, σ,numberDataCindex);		
		//float newSize=newCover.calculateeBValue(USize);
		if(newCover.getDTolerance().size()==ReduceCover.getDTolerance().size()) {
			ReduceCover=newCover;
			return true;
		}
		return false;
	}
	//冒泡排序 从小到大
//	public void bubbleSortOpt(List<DstrippedCover> index,float[] q) {
//		if(index == null) {}
//	    if(index.size() < 2) {
//	        return;
//	    }
//	    float temp = 0;DstrippedCover tempindex=new DstrippedCover(USize);
//	    for(int i = 0; i < index.size() - 1; i++) {
//	        for(int j = 0; j < index.size() - i - 1; j++) {
//	            if(q[j] > q[j + 1]) {
//	                temp = q[j];
//	                tempindex=index.get(j);
//	                q[j] = q[j + 1];
//	                index.set(j, index.get(j+1));
//	                q[j + 1] = temp;
//	                index.set(j+1, tempindex);
//	            }
//	        }
//	    }
//	}
	
	//约简
	public StaticReduceResult FSSNCReduce(ArrayList<Sample> U,float σ,int[] CName,int[]numberDataCindex) {
		System.out.println("||静态约简开始");
		List<Integer> Reduce=new ArrayList<Integer>(CName.length);
		IntArrayKey C=new IntArrayKey(CName);
		LinkedHashMap<String,Long> times=new LinkedHashMap<>(10);
		IntArrayKey ReduceKey=new IntArrayKey();
		
		long start = System.currentTimeMillis();	
		DstrippedCover CTCover=this.toleranceClass(C, U, σ,numberDataCindex);
		CTCover.calculateeBValue(U.size());
		//CTCover.outPut();
		long end = System.currentTimeMillis();
		System.out.println("||全C下的等价类计算&eB(C)="+CTCover.geteBvalue()+",时间:"+(end-start)+"ms,"+(double)(end-start)/1000+"s");
		times.put("computeEquivalenceClassofC",end-start);
		
		DstrippedCover TempCover;
		DstrippedCover max_tempCover=new DstrippedCover();
		DstrippedCover ReduceCover;	
		List<Integer> remainC=Arrays.stream(CName).boxed().collect(Collectors.toList());
		//List<Integer> delete=new ArrayList<Integer>(C.key().length);
		List<DstrippedCover> tempCoverlist=new ArrayList<DstrippedCover>(C.key().length);
		float mineB=Integer.MAX_VALUE;
		int j=-1,max_a=-1;
		float[] eBvaluelist=new float[C.key().length];
		
		start = System.currentTimeMillis();	
		for(int i=0;i<C.key().length;i++) {
			int a=C.key()[i];
			IntArrayKey newAttr=new IntArrayKey(); 
			newAttr.addKey(a);
			TempCover=this.toleranceClass(newAttr, U, σ,numberDataCindex);
			//TempCover.outPut();
			//tempCoverlist.add(i, TempCover);
			eBvaluelist[i]=TempCover.calculateeBValue(U.size()); //计算eBValue
			//System.out.print("ei:"+eBvaluelist[i]);
			if(eBvaluelist[i]<mineB) {
				mineB=eBvaluelist[i];
				max_a=a;
				max_tempCover=TempCover;
				j=i;
			}
			TempCover=null;
		}
		//this.bubbleSortOpt(tempCoverlist, eBvaluelist);
		Reduce.add(max_a);
		ReduceKey.addKey(max_a);
		ReduceCover=max_tempCover;
		//ReduceCover.outPut();
		remainC.remove(j);
		//tempCoverlist.remove(j);
		//System.out.print("remainC："+remainC);
		end = System.currentTimeMillis();
		System.out.println("||最优特征{"+max_a+"}&eB(B)="+ReduceCover.geteBvalue()+",时间:"+(end-start)+"ms,"+(double)(end-start)/1000+"s");
		times.put("computeMaxAttribute",end-start);
		
		Significance maxSig=new Significance();
		max_a=0;
		j=-1;
		//System.out.print(Reduce);	
		//System.out.println("ReduceCover:"+ReduceCover.getDTolerance().size()+"  CTCover:"+CTCover.getDTolerance().size());
		
		start = System.currentTimeMillis();	
		while(ReduceCover.getDTolerance().size()!=CTCover.getDTolerance().size()) {//Math.abs(ReduceCover.geteBvalue()-CTCover.geteBvalue())>=0.00001
			maxSig=new Significance();	
			IntArrayKey newAttr=new IntArrayKey(ReduceKey.key().clone());  //B-a  初始化未完
			for(int i=0;i<remainC.size();i++) {
				int a=remainC.get(i);	
//				IntArrayKey newAttr=new IntArrayKey(ReduceKey.key().clone());
//				newAttr.addKey(a);
//				TempCover=this.toleranceClass(newAttr, U, σ, numberDataCindex);
				//TempCover=this.addAttributeCulTolerance(a, newAttr,tempCoverlist.get(i),ReduceCover,numberDataCindex,U);
				TempCover=this.addAttributeCulTolerance_new3(a, newAttr,σ,ReduceCover,numberDataCindex,U);
				//TempCover.outPut();			
				TempCover.calculateeBValue(U.size());
				Significance a_sig=this.calculateSignificance(a, ReduceKey.key(), false, U.size(), ReduceCover, TempCover);
				//System.out.println(a_sig.getSig()+"  TempCoverSize:"+TempCover.getDTolerance().size());
//				if(TempCover.getDTolerance().size()==ReduceCover.getDTolerance().size()) {		//TempCover.geteBvalue()==ReduceCover.geteBvalue()	,TempCover.getDTolerance().size()==ReduceCover.getDTolerance().size()
//					remainC.remove(i);tempCoverlist.remove(i);  i--;
//				}else {
					if(a_sig.getSig()>maxSig.getSig()) {
						max_a=a;
						max_tempCover=TempCover;
						maxSig=a_sig;
						j=i;
					}
					TempCover=null;
				//}	
			}
			Reduce.add(max_a);
			ReduceKey.addKey(max_a);
			ReduceCover=max_tempCover;
			//System.out.print("remainCSize:"+remainC.size());			
			//System.out.print("最优a："+max_a);
			//System.out.println("Reduce:"+Reduce+", size:"+Reduce.size());
			//System.out.println("ReduceCoverSize:"+ReduceCover.geteBvalue()+" CCoverSize:"+CTCover.geteBvalue());
			//System.out.println("ReduceCover:"+ReduceCover.getDTolerance().size()+"  CTCover:"+CTCover.getDTolerance().size());
			remainC.remove(j);
			//tempCoverlist.remove(j);
			System.out.println("||最优特征{"+max_a+"}&eB(B)="+ReduceCover.geteBvalue());
		}
		end = System.currentTimeMillis();
		System.out.println("||迭代&Reduce={"+Reduce+"},时间："+(end-start)+"ms,"+(double)(end-start)/1000+"s");
		times.put("iteration",end-start);
		
		//冗余检验
		start = System.currentTimeMillis();	
		System.out.println("||冗余检验开始");
		for(int i=0;i<Reduce.size();i++) {  //删除冗余属性
			int a=Reduce.get(i);
			IntArrayKey tempreduce=new IntArrayKey(ReduceKey.key().clone());
			tempreduce.deleteKey(a);
			boolean redundancy=this.redundancy(tempreduce, max_tempCover,U,σ,numberDataCindex); //此时max_tempCover即为ReduceTCover
			if(redundancy) {
				Reduce.remove(i);
				i--;
				remainC.add(a);
				//System.out.print("删除属性："+a+" ");
				System.out.println("||删除特征{"+a+"}");
			}		
		}
		end = System.currentTimeMillis();
		System.out.println("||冗余检验结束："+(end-start)+"ms,"+(double)(end-start)/1000+"s");
		times.put("redundancy",end-start);
		long alltime=0;
		for(long i:times.values())
			alltime+=i;
		System.out.println("||最终约简Reduce={"+Reduce+"},约简数量="+Reduce.size());
		System.out.println("||总时间："+alltime+"ms,"+(double)(alltime)/1000+"s");
		StaticReduceResult result=new StaticReduceResult(Reduce,times);
		//this.Reduce=Reduce;
		return result;
		
	}
}

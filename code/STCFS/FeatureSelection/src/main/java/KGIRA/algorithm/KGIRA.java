package main.java.KGIRA.algorithm;

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
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedHashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Random;
import java.util.Set;
import java.util.stream.Collectors;

import main.java.KGIRA.entity.ToleranceEquivalenceClass;
import main.java.KGIRA.entity.IntArrayKey;
import main.basic.model.Sample;
import main.java.KGIRA.entity.Significance;
import main.java.KGIRA.entity.ToleranceCollection;

public class KGIRA {
	public ArrayList<Sample> U;
	//public int[] C;
	public int[] CName;
	public int DName;
	//public ToleranceCollection TC;
	public float GP_C=0;
	public List<Integer> Reduce;
	public ArrayList<String[]> dataArray;
	public HashMap<Integer,ArrayList<String[]>> dividedata;
	public ArrayList<Sample> Uad;
	public ArrayList<Sample> Ude;
	
	public KGIRA() {}
	
	public KGIRA(String filePath) {
		//this.filePath=filePath;
	}
	
	public void inputData(String filePath) {
		File file=new File(filePath);
		ArrayList<String[]> dataArray=new ArrayList<String[]>();		
		try{
			BufferedReader in=new BufferedReader(new FileReader(file));
			String str;
			String[] tempArray;
			while((str=in.readLine())!=null){
				tempArray=str.split(",");
				dataArray.add(tempArray);
			}
			in.close();
		}catch(IOException e){
			e.getStackTrace();
		}
		this.dataArray=dataArray;
		ArrayList<Sample> U=new ArrayList<Sample>(dataArray.size());
		CName=new int[dataArray.get(0).length-2];
		int n=0;
		for(int i=0;i<dataArray.get(0).length;i++) {
			String[] data=dataArray.get(0);		
			if(i!=data.length-1&&i!=0) {
				CName[n]=Integer.valueOf(data[i]);	
				n++;
			}
		}		
		for(int i=1;i<dataArray.size();i++) {
			String[] data=dataArray.get(i);
			Sample x=new Sample(Integer.parseInt(data[0])-1,new int[data.length-1]);
				for(int j=0;j<data.length;j++) {	
					if(j!=data.length-1&&j!=0) {
						x.setAttributeValueOf(j,Integer.parseInt(data[j]));
						if(Integer.parseInt(data[j])==-1)
							x.setIs_Incomplete(true);
					}else if(j==data.length-1) 
						x.setAttributeValueOf(0,Integer.parseInt(data[j]));
				}
			U.add(x);							
		}
		this.U=U;
	}
	//将数据拆分成十份
	public void divideDatato10_add(ArrayList<String[]> dataArray) {
		int size=dataArray.size();
		int row=dataArray.size()-1;  //行，减第一行
		int column=dataArray.get(0).length-2;   //列，减name和D	
		int finalsize=0;
		ArrayList<String[]> alldata=new ArrayList<>();
		alldata.addAll(dataArray);
		HashMap<Integer,ArrayList<String[]>> dataDivide=new HashMap<>();
		Random random = new Random();	
		CName=new int[dataArray.get(0).length-2];
		int k=0;
		for(int j=0;j<dataArray.get(0).length-1;j++)
			if(j!=dataArray.get(0).length-1&&j!=0) {
				CName[k]=Integer.valueOf(dataArray.get(0)[j]);
				k++;
			}
		//dataArray.remove(0);
		for(int i=0;i<10;i++) {
			Set<Integer> set = new LinkedHashSet<Integer>();//LinkedHashSet是有顺序不重复集合
			random = new Random();
			String str = String.valueOf(((double)row-i*((double)row/10)));//浮点变量a转换为字符串str
		    int idx = str.lastIndexOf(".");//查找小数点的位置
		    String strNum = str.substring(0,idx);//截取从字符串开始到小数点位置的字符串，就是整数部分
		    int nowrow=0;
		   // System.out.print(Integer.valueOf(str.substring(str.lastIndexOf(".")+1)));
		    if(Integer.valueOf(str.substring(str.lastIndexOf(".")+1,str.lastIndexOf(".")+2))>5) 
		    	 nowrow = Integer.valueOf(strNum)+1;	    
		    else nowrow = Integer.valueOf(strNum);//把整数部分通过Integer.valueof方法转换为数字
		    ArrayList<String[]> datatemp=new ArrayList<>();
		    //System.out.println(nowrow);
		    //System.out.println(nowrow);
		    if(i!=9) {
				while(set.size()<((double)row/10)) {					
					Integer number=random.nextInt(nowrow-i);
					set.add(number);  //重复就不会添加
				}
				for(Integer number:set) 
					datatemp.add(alldata.get(number+1));//得到第几行  行的前面要+1	
				int temp=0,min=Integer.MAX_VALUE;
				for(int n=0;n<datatemp.size();n++) {	
					for(int m=0;m<alldata.size();m++) {
						if(alldata.get(m)[0].equals(datatemp.get(n)[0])) {
							//System.out.println(alldata.get(m)[0]+"  "+datatemp.get(n)[0]);
							alldata.remove(m);
						}
					}
					
				}	
			}else {
				datatemp.addAll(alldata);
			    datatemp.remove(0);  //删除第一行
			}
		    dataDivide.put(i, datatemp);
		    finalsize+=datatemp.size();
		}
		this.dividedata=dataDivide;
		System.out.println("完成划分10份,共"+finalsize);
	}
	//通过划分的数据集input
	public void inputData_divideInitial(int num) {  //num为将几份数据作为原始数据
		this.U=new ArrayList<>();
		ArrayList<String[]> dataArray=new ArrayList<>();
		for(int m=0;m<num;m++)
			dataArray.addAll(this.dividedata.get(m));//前num份数据组成初始数据	
//		CName=new int[dataArray.get(0).length-2];
//		this.CLength=CName.length;
//		int n=0;
//		for(int i=0;i<dataArray.get(0).length;i++) {
//			String[] data=dataArray.get(0);		
//			if(i!=data.length-1&&i!=0) {
//				CName[n]=Integer.valueOf(data[i]);	
//				n++;
//			}
//		}
		ArrayList<Sample> U=new ArrayList<Sample>(dataArray.size());
		//int k=0;
		for(int i=0;i<dataArray.size();i++) {
			String[] data=dataArray.get(i);
			Sample x=new Sample(Integer.valueOf(data[0])-1,new int[data.length-1]);				
			for(int j=0;j<data.length;j++) {					
				if(j!=data.length-1&&j!=0) { 
					x.setAttributeValueOf(j,Integer.parseInt(data[j]));
					if(Integer.parseInt(data[j])==-1)
						x.setIs_Incomplete(true);
				}else if(j==data.length-1) 
					x.setAttributeValueOf(0,Integer.parseInt(data[j]));							
			}	
			U.add(x);
			//System.out.println(x.toString());
			//k++;
		}
		this.U=U;
		//System.out.println(k);
	}
		
	//通过划分的数据集input
	public void inputData_divideAdd(int num) {   //num是添加第几部分		
		ArrayList<String[]> dataArray=new ArrayList<>();
		dataArray.addAll(this.dividedata.get(num));
		ArrayList<Sample> Uad=new ArrayList<>(dataArray.size());
		for(int i=0;i<dataArray.size();i++) {
			String[] data=dataArray.get(i);
			Sample x=new Sample(Integer.valueOf(data[0])-1,new int[data.length-1]);			
			for(int j=0;j<data.length;j++) {					
				if(j!=data.length-1&&j!=0) {
					x.setAttributeValueOf(j,Integer.parseInt(data[j]));
					if(Integer.parseInt(data[j])==-1)
						x.setIs_Incomplete(true);
				}else if(j==data.length-1) 
					x.setAttributeValueOf(0,Integer.parseInt(data[j]));
			}
			Uad.add(x);
		}
		this.Uad=Uad;
		this.U.addAll(Uad);
		//this.CLength=dataArray.get(0).length-2;
	}
	//通过划分的数据集input
	public void inputData_divideDelete(int num) {   //num是删除第几部分
		ArrayList<String[]> dataArray=new ArrayList<>();
		dataArray.addAll(this.dividedata.get(num));
		ArrayList<Sample> Ude=new ArrayList<>(dataArray.size());
		for(int i=0;i<dataArray.size();i++) {
			String[] data=dataArray.get(i);
			Sample x=new Sample(Integer.valueOf(data[0])-1,new int[data.length-1]);
			for(int j=0;j<data.length;j++) {					
				if(j!=data.length-1&&j!=0) {
					x.setAttributeValueOf(j,Integer.parseInt(data[j]));
					if(Integer.parseInt(data[j])==-1)
						x.setIs_Incomplete(true);
				}else if(j==data.length-1) 
					x.setAttributeValueOf(0,Integer.parseInt(data[j]));
			}
			Ude.add(x);			
		}
		for(int k=0;k<dataArray.size();k++) {
			U.remove(Ude.get(k));
		}
		//System.out.print(Ude.size());
	}
	//输出得到Reduce划分后的文件
//	public void outReduceFile() {
//		ArrayList<String[]> data=new ArrayList<>();
//		data.addAll(this.dataArray);
//		ArrayList<String> Reducedata=new ArrayList<>();
//		ArrayList<Integer> num=new ArrayList<>();
//		num.addAll(this.Reduce);
//		//num.add(data.get(0).length-1);  //加上D
//		StringBuilder strx=new StringBuilder();
//		for(int i=1;i<data.size();i++) {
//			strx=new StringBuilder();
//			for(int s:num) 
//				if(Integer.valueOf(data.get(i)[s])==-1)
//					strx.append("100000,");
//				else strx.append(data.get(i)[s]+",");
//			strx.append(data.get(i)[data.get(i).length-1]);
//			strx.append(System.getProperty("line.separator"));
//			Reducedata.add(strx.toString());
//		}
//		File inFile,outFile,outPath;
//		String str1=filePath.substring(0,filePath.lastIndexOf("\\"));
//		String str2=filePath.substring(filePath.lastIndexOf("\\"),filePath.lastIndexOf("."));
//		String str3=filePath.substring(filePath.lastIndexOf("."));
//		String dirPath=str1;
//		String outFilePath=str1+str2+"_Reduce"+str3;		
//		try{
//			outPath = new File(dirPath);
//			outFile = new File(outFilePath);	
//			if (!outPath.exists()) {
//				outPath.mkdirs();
//			}
//			if(!outFile.exists()) {
//	            outFile.createNewFile();
//	        }
//			BufferedWriter out=new BufferedWriter(new FileWriter(outFile));
//			for(String str:Reducedata) {
//				out.write(str);
//			}
//			out.close();
//		}catch(IOException e){
//			e.getStackTrace();
//		}
//		System.out.println("文件"+str2+"_Reduce完成");
//	}
	//步骤 1先找到全C下的容差类 2在C中删除a判断重要度，重要度大于0则添加到B
	//3 while(GP(B)!=GP(C)) 计算B下的容差类 4在B中判断添加哪个添加a（属于C-B）计算容差类判断重要度 最大的添加进B
	
	//从查找B条件下的全U等价类
	public ToleranceCollection toleranceClass(IntArrayKey attributeIndex,ArrayList<Sample> U){
		ToleranceCollection Tcoll=new ToleranceCollection(attributeIndex);//初始化要全部x的T
		Tcoll.initialize(U);
//		Collection<Integer> ne=new ArrayList<Integer>();
//		List<Integer> a=new ArrayList<Integer>();
//		ne.addAll(a);
//		System.out.print(ne);
		
		boolean flag=true;
		for(int i=0;i<U.size();i++){
			Sample x1=U.get(i);
			for(int j=i+1;j<U.size();j++){
				Sample x2=U.get(j);
				flag=true;
				for(int z=0;z<attributeIndex.key().length;z++){
					//条件属性在x中的下标从1开始
					if(x1.getAttributeValueByIndex(attributeIndex.key()[z]+1)!=x2.getAttributeValueByIndex(attributeIndex.key()[z]+1)&&x1.getAttributeValueByIndex(attributeIndex.key()[z]+1)!=-1&&x2.getAttributeValueByIndex(attributeIndex.key()[z]+1)!=-1){
						flag=false;
						break;
					}
				}
				if(flag){    
					Tcoll.getNotDTolerance().get(i).add(x2);
					Tcoll.getNotDTolerance().get(j).add(x1);
					if(x1.getAttributeValueByIndex(0)==x2.getAttributeValueByIndex(0)){   //D
						Tcoll.getDTolerance().get(i).add(x2);
						Tcoll.getDTolerance().get(j).add(x1);
					}
				}
			}
			Tcoll.setTotalNotDNumber(Tcoll.getTotalNotDNumber()+Tcoll.getNotDTolerance().get(i).getItems().size());
			Tcoll.setTotalDNumber(Tcoll.getTotalDNumber()+Tcoll.getDTolerance().get(i).getItems().size());
		}
		return Tcoll;
	}
	//从B中删除一个元素计算容差类
	public ToleranceCollection deleteAttributeCulTolerance(int attribute,IntArrayKey attributes,ToleranceCollection BTColl) {
		IntArrayKey newAttr=new IntArrayKey(attributes.key());  //B-a  初始化未完
		newAttr.deleteKey(attribute);
		ToleranceCollection newBTColl=new ToleranceCollection(newAttr,BTColl.getNotDTolerance(),BTColl.getDTolerance(),BTColl.getTotalNotDNumber(),BTColl.getTotalDNumber());
//		newBTColl.initialize(U);
//		newBTColl.setNotDTolerance(BTColl.getNotDTolerance());
//		newBTColl.setDTolerance(BTColl.getDTolerance());
		boolean flag=true;
		for(int i=0;i<U.size();i++){
			Sample x1=U.get(i);			
			for(int j=i+1;j<U.size();j++){
				Sample x2=U.get(j);
				if(!newBTColl.getNotDTolerance().get(i).getItems().contains(x2)) {
					flag=true;
					for(int z=0;z<newAttr.key().length;z++){
						if(x1.getAttributeValueByIndex(newAttr.key()[z]+1)!=x2.getAttributeValueByIndex(newAttr.key()[z]+1)&&x1.getAttributeValueByIndex(newAttr.key()[z]+1)!=-1&&x2.getAttributeValueByIndex(newAttr.key()[z]+1)!=-1){
							flag=false;
							break;
						}
					}
					if(flag){    
						newBTColl.getNotDTolerance().get(x1.getName()).add(x2);
						newBTColl.getNotDTolerance().get(x2.getName()).add(x1);
						if(x1.getAttributeValueByIndex(0)==x2.getAttributeValueByIndex(0)){
							newBTColl.getDTolerance().get(x1.getName()).add(x2);
							newBTColl.getDTolerance().get(x2.getName()).add(x1);
						}
					}
				}		
			}  
			newBTColl.setTotalNotDNumber(newBTColl.getTotalNotDNumber()+newBTColl.getNotDTolerance().get(x1.getName()).getItems().size()-BTColl.getNotDTolerance().get(x1.getName()).getItems().size());
			newBTColl.setTotalDNumber(newBTColl.getTotalDNumber()+newBTColl.getDTolerance().get(x1.getName()).getItems().size()-BTColl.getDTolerance().get(x1.getName()).getItems().size());
			//System.out.println(newBTColl.getNotDTolerance().get(x1.getName()).getItems().size()+"  "+BTColl.getNotDTolerance().get(x1.getName()).getItems().size());
		}
		//ToleranceCollection Tcol=new ToleranceCollection(newAttr);
		return newBTColl;
	}
	//从B中添加一个元素计算容差类
	public ToleranceCollection addAttributeCulTolerance(int attribute,IntArrayKey attributes,ToleranceCollection BTColl) {
		IntArrayKey newAttr=new IntArrayKey(attributes.key());  //B-a  初始化未完
		newAttr.addKey(attribute);
		ToleranceCollection newBTColl=new ToleranceCollection(newAttr,BTColl.getNotDTolerance(),BTColl.getDTolerance(),BTColl.getTotalNotDNumber(),BTColl.getTotalDNumber());
//		newBTColl.initialize(U);
//		newBTColl.setNotDTolerance(BTColl.getNotDTolerance());
//		newBTColl.setDTolerance(BTColl.getDTolerance());
		Set<Sample> deleteNotDSet;
		//Set<Sample> deleteDSet;
		boolean flag=true;
		for(int i=0;i<BTColl.getNotDTolerance().size();i++){
			Sample x1=U.get(BTColl.getNotDTolerance().get(i).getXIndex());
			Set<Sample> set=newBTColl.getNotDTolerance().get(i).getItems();
			deleteNotDSet=new HashSet<Sample>(set.size());
			//deleteDSet=new HashSet<Sample>(set.size());
			for(Sample x2:set){
				flag=true;
				if(x1.getAttributeValueByIndex(attribute+1)!=x2.getAttributeValueByIndex(attribute+1)&&x1.getAttributeValueByIndex(attribute+1)!=-1&&x2.getAttributeValueByIndex(attribute+1)!=-1)
					flag=false;				
				if(!flag){    
					newBTColl.getNotDTolerance().get(x2.getName()).getItems().remove(x1);
					deleteNotDSet.add(x2);
					if(newBTColl.getDTolerance().get(i).getItems().contains(x2)){
						newBTColl.getDTolerance().get(x2.getName()).getItems().remove(x1);
						newBTColl.getDTolerance().get(i).getItems().remove(x2);
						//deleteDSet.add(x2);
					}
				}				
			}
			set.removeAll(deleteNotDSet);	
			newBTColl.setTotalNotDNumber(newBTColl.getTotalNotDNumber()+newBTColl.getNotDTolerance().get(x1.getName()).getItems().size()-BTColl.getNotDTolerance().get(x1.getName()).getItems().size());
			newBTColl.setTotalDNumber(newBTColl.getTotalDNumber()+newBTColl.getDTolerance().get(x1.getName()).getItems().size()-BTColl.getDTolerance().get(x1.getName()).getItems().size());
		}
		return newBTColl;
	}
	//计算重要度
	public Significance calculateSignificance(int attribute,int[] B,boolean is_inner,int USize,ToleranceCollection initialTColl,ToleranceCollection newTColl) {
		Significance attrSig=new Significance(attribute,B);
		attrSig.calculateSig_common(is_inner, USize, initialTColl, newTColl);
		return attrSig;
	}
	public Significance calculateSignificance_update(int attribute,int[] B,boolean is_inner,int USize,int newUSize,float initial_GP_B,float new_GP_B) {
		Significance attrSig=new Significance(attribute,B);
		attrSig.calculateSig_update(is_inner, USize, newUSize, initial_GP_B, new_GP_B);
		return attrSig;
	}
	//冗余检验
	public boolean redundancy(int attribute,IntArrayKey Reduce,ToleranceCollection ReduceTColl,float GP_C) {		
		ToleranceCollection TempColl=this.deleteAttributeCulTolerance(attribute, Reduce, ReduceTColl);		
		float GP_Bdea=((float)1/(U.size()*U.size()))*(Math.abs(TempColl.getTotalNotDNumber())-Math.abs(TempColl.getTotalDNumber()));
		if(GP_Bdea==GP_C)
			return true;
		return false;
	}
	public boolean redundancy_update(int attribute,IntArrayKey Reduce,float GP_C) {
		IntArrayKey newAttr=new IntArrayKey(Reduce.key());  //B-a  初始化未完
		newAttr.deleteKey(attribute);
		ToleranceCollection TempColl=this.toleranceClass(newAttr, U);
		float oldGP_B=((float)1/(U.size()*U.size()))*(Math.abs(TempColl.getTotalNotDNumber())-Math.abs(TempColl.getTotalDNumber()));
		ToleranceCollection partUpdateCTColl_B=this.toleranceClass_initial_update(newAttr, U, Uad);
		ToleranceCollection allUpdateCTColl_B=this.toleranceClass(newAttr, Uad);
		float tempGP_B=((float)1/(U.size()+Uad.size())*(U.size()+Uad.size()))*((U.size()*U.size())*oldGP_B+2*(Math.abs(partUpdateCTColl_B.getTotalNotDNumber())-Math.abs(partUpdateCTColl_B.getTotalDNumber()))+(Math.abs(allUpdateCTColl_B.getTotalNotDNumber())-Math.abs(allUpdateCTColl_B.getTotalDNumber())));
		if(tempGP_B==GP_C)
			return true;
		return false;
	}
	//约简
	public List<Integer> KGIRAReduce(ArrayList<Sample> U) {
		List<Integer> Reduce=new ArrayList<Integer>(CName.length);
		IntArrayKey C=new IntArrayKey(this.CName.length);
		IntArrayKey ReduceKey=new IntArrayKey();
		ToleranceCollection CTColl=this.toleranceClass(C, U);
		float GP_C=((float)1/(U.size()*U.size()))*(Math.abs(CTColl.getTotalNotDNumber())-Math.abs(CTColl.getTotalDNumber()));
		//System.out.print(GP_C);
		ToleranceCollection TempColl;
		ToleranceCollection max_tempColl=new ToleranceCollection();	
		this.GP_C=GP_C;
		List<Integer> remainC=Arrays.stream(CName).boxed().collect(Collectors.toList());
		//List<Integer> delete=new ArrayList<Integer>(C.key().length);
		for(int i=0;i<C.key().length;i++) {
			//int a=C.key()[i];
			//System.out.print(a);
			IntArrayKey newAttr=new IntArrayKey(this.CName.length);  //B-a  初始化未完
			newAttr.deleteKey(i);
			TempColl=this.toleranceClass(newAttr, U);
			//TempColl=deleteAttributeCulTolerance(a, C, CTColl);
			Significance a_sig=this.calculateSignificance(i, CName, true, U.size(), CTColl, TempColl);
			//System.out.println(a_sig.getSig());
			if(a_sig.getSig()>0) {
				Reduce.add(i);
				ReduceKey.addKey(i);
				//delete.add(i);
				remainC.remove(i);
			}
		}
		//remainC.removeAll(delete);
		//System.out.print(remainC);
		Significance maxSig=new Significance();
		int max_a=0;
		int j=-1;
		max_tempColl=this.toleranceClass(ReduceKey, U);
		ToleranceCollection BTColl=max_tempColl;
		float GP_B=((float)1/(U.size()*U.size()))*(Math.abs(max_tempColl.getTotalNotDNumber())-Math.abs(max_tempColl.getTotalDNumber()));
		System.out.print(Reduce);
		//System.out.print(GP_B);
		while(GP_B!=GP_C) {
			maxSig=new Significance();
			for(int i=0;i<remainC.size();i++) {
				int a=remainC.get(i);
				IntArrayKey newAttr=new IntArrayKey(ReduceKey.key().clone());  //B-a  初始化未完
				newAttr.addKey(a);
				TempColl=this.toleranceClass(newAttr, U);
				//TempColl=this.addAttributeCulTolerance(a, ReduceKey, CTColl);
				Significance a_sig=this.calculateSignificance(a, ReduceKey.key(), false, U.size(), BTColl, TempColl);
				//System.out.println(a_sig.getSig());
				if(a_sig.getSig()>maxSig.getSig()) {
					max_a=a;
					max_tempColl=TempColl;
					maxSig=a_sig;
					j=i;
				}
			}
			Reduce.add(max_a);
			ReduceKey.addKey(max_a);				
			remainC.remove(j);
			BTColl=max_tempColl;
			GP_B=((float)1/(U.size()*U.size()))*(Math.abs(max_tempColl.getTotalNotDNumber())-Math.abs(max_tempColl.getTotalDNumber()));			
			System.out.println("最优a："+max_a);
			System.out.print(Reduce);
		}	
		//冗余检验
		for(int i=0;i<Reduce.size();i++) {  //删除冗余属性
			int a=Reduce.get(i);
			boolean redundancy=this.redundancy(a, ReduceKey, max_tempColl, GP_C); //此时max_tempColl即为ReduceTCollection
			if(redundancy) {
				Reduce.remove(i);
				i--;
			}				
		}
		this.Reduce=Reduce;
		return Reduce;
		
	}
	
	//查找在B=attributeIndex下的initial_U和update_U的等价类
	public ToleranceCollection toleranceClass_initial_update(IntArrayKey attributeIndex,ArrayList<Sample> initial_U,ArrayList<Sample> update_U){
		ToleranceCollection Tcoll=new ToleranceCollection(attributeIndex);//初始化要全部x的T
		Tcoll.initialize(update_U);
//		Collection<Integer> ne=new ArrayList<Integer>();
//		List<Integer> a=new ArrayList<Integer>();
//		ne.addAll(a);
//		System.out.print(ne);			
		boolean flag=true;
		for(int i=0;i<update_U.size();i++){
			Sample x1=update_U.get(i);
			for(int j=0;j<initial_U.size();j++){
				Sample x2=initial_U.get(j);
				flag=true;
				for(int z=0;z<attributeIndex.key().length;z++){
					//条件属性在x中的下标从1开始
					if(x1.getAttributeValueByIndex(attributeIndex.key()[z]+1)!=x2.getAttributeValueByIndex(attributeIndex.key()[z]+1)&&x1.getAttributeValueByIndex(attributeIndex.key()[z]+1)!=-1&&x2.getAttributeValueByIndex(attributeIndex.key()[z]+1)!=-1){
						flag=false;
						break;
					}
				}
				if(flag){    
					Tcoll.getNotDTolerance().get(i).add(x2);
					if(x1.getAttributeValueByIndex(0)==x2.getAttributeValueByIndex(0)){   //D
						Tcoll.getDTolerance().get(i).add(x2);
					}
				}
			}
			Tcoll.setTotalNotDNumber(Tcoll.getTotalNotDNumber()+Tcoll.getNotDTolerance().get(i).getItems().size());
			Tcoll.setTotalDNumber(Tcoll.getTotalDNumber()+Tcoll.getDTolerance().get(i).getItems().size());
		}
		return Tcoll;
	}
	
	//约简_addSample
	public List<Integer> KGIRAReduce_addSample(ArrayList<Sample> U,ArrayList<Sample> Uad,float GP_C,float GP_B,List<Integer> Reduce) {
		//List<Integer> Reduce=new ArrayList<Integer>(CName.length);
		IntArrayKey C=new IntArrayKey(this.CName);
		IntArrayKey ReduceKey=new IntArrayKey(Reduce.stream().mapToInt(Integer::valueOf).toArray());
		//ToleranceCollection CTColl=this.toleranceClass(C, U);
		ToleranceCollection partUpdateCTColl_B=this.toleranceClass_initial_update(ReduceKey, U, Uad);
		ToleranceCollection allUpdateCTColl_B=this.toleranceClass(ReduceKey, Uad);
		ToleranceCollection partUpdateCTColl_C=this.toleranceClass_initial_update(C, U, Uad);
		ToleranceCollection allUpdateCTColl_C=this.toleranceClass(C, Uad);
		float newGP_C=((float)1/(U.size()+Uad.size())*(U.size()+Uad.size()))*((U.size()*U.size())*GP_C+2*(Math.abs(partUpdateCTColl_C.getTotalNotDNumber())-Math.abs(partUpdateCTColl_C.getTotalDNumber()))+(Math.abs(allUpdateCTColl_C.getTotalNotDNumber())-Math.abs(allUpdateCTColl_C.getTotalDNumber())));
		float newGP_B=((float)1/(U.size()+Uad.size())*(U.size()+Uad.size()))*((U.size()*U.size())*GP_B+2*(Math.abs(partUpdateCTColl_B.getTotalNotDNumber())-Math.abs(partUpdateCTColl_B.getTotalDNumber()))+(Math.abs(allUpdateCTColl_B.getTotalNotDNumber())-Math.abs(allUpdateCTColl_B.getTotalDNumber())));
		if (newGP_B==newGP_C)
			return Reduce;		
		this.GP_C=newGP_C;
		List<Integer> remainC=new ArrayList<Integer>(C.key().length);
		for(int i=0;i<C.key().length;i++) 
			if(!Reduce.contains(C.key()[i]))
				remainC.add(C.key()[i]);	
		//List<Integer> delete=new ArrayList<Integer>(C.key().length);
		Significance maxSig=new Significance();
		int max_a=0;
		int j=-1;
		//ToleranceCollection max_tempAllColl;
		ToleranceCollection TempColl;
		//ToleranceCollection max_tempPartColl;
		float max_tempGP_B=newGP_B;
		float oldGP_B=GP_B;
		//System.out.print(Reduce);
		//System.out.print(GP_B);
		while(newGP_B!=newGP_C) {
			maxSig=new Significance();			
			for(int i=0;i<remainC.size();i++) {
				int a=remainC.get(i);
				IntArrayKey newAttr=new IntArrayKey(ReduceKey.key().clone());  //B-a  初始化未完
				newAttr.addKey(a);			
				partUpdateCTColl_B=this.toleranceClass_initial_update(newAttr, U, Uad);
				allUpdateCTColl_B=this.toleranceClass(newAttr, Uad);
				//TempColl=this.addAttributeCulTolerance(a, ReduceKey, CTColl);				
				float tempGP_B=((float)1/(U.size()+Uad.size())*(U.size()+Uad.size()))*((U.size()*U.size())*oldGP_B+2*(Math.abs(partUpdateCTColl_B.getTotalNotDNumber())-Math.abs(partUpdateCTColl_B.getTotalDNumber()))+(Math.abs(allUpdateCTColl_B.getTotalNotDNumber())-Math.abs(allUpdateCTColl_B.getTotalDNumber())));
				Significance a_sig=this.calculateSignificance_update(a, ReduceKey.key(), false, U.size(), Uad.size(), newGP_B, tempGP_B);
				//System.out.println(a_sig.getSig());
				if(a_sig.getSig()>maxSig.getSig()) {
					max_a=a;
					//max_tempPartColl=partUpdateCTColl_B;
					//max_tempAllColl=allUpdateCTColl_B;
					max_tempGP_B=tempGP_B;
					maxSig=a_sig;
					j=i;
				}
			}
			Reduce.add(max_a);
			ReduceKey.addKey(max_a);				
			remainC.remove(j);
			TempColl=this.toleranceClass(ReduceKey, U);
			oldGP_B=((float)1/(U.size()*U.size()))*(Math.abs(TempColl.getTotalNotDNumber())-Math.abs(TempColl.getTotalDNumber()));
			newGP_B=max_tempGP_B;
			//GP_Reduce=((float)1/(U.size()+Uad.size())*(U.size()+Uad.size()))*((U.size()*U.size())*GP_B+2*(Math.abs(partUpdateCTColl_B.getTotalNotDNumber())-Math.abs(partUpdateCTColl_B.getTotalDNumber()))+(Math.abs(allUpdateCTColl_B.getTotalNotDNumber())-Math.abs(allUpdateCTColl_B.getTotalDNumber())));
			System.out.println("最优a："+max_a);
			System.out.print(Reduce);
		}	
		//冗余检验
		for(int i=0;i<Reduce.size();i++) {  //删除冗余属性
			int a=Reduce.get(i);
			boolean redundancy=this.redundancy_update(a, ReduceKey, newGP_C); 
			if(redundancy)
				Reduce.remove(i);
		}
		this.Reduce=Reduce;
		return Reduce;
	}
	
	//根据attribute一个属性对U排序后找容差类
//	public static Collection<ToleranceEquivalenceClass> equivalenceClass(List<Sample> samples, int attribute){
//		// sort the objects in U<sub>i</su> by feature values;
//		Collections.sort(
//			samples,
//			(ins1, ins2)->(ins1.getAttributeValueByIndex(attribute) - ins2.getAttributeValueByIndex(attribute)));
//		// let U<sub>i</sub> = {x'[1], x'[2], ..., x'[n]}, z=1, s=1, U<sub>is</sub> = {x'[1]}
//		// for j=2 to n' do
//		//	if b<sub>i</sub>(x[z]')=b<sub>i</sub>(x[j]') then
//		//		U<sub>is</sub>.add( {x'[j]} ).
//		//	else 
//		//		s=s+1, U<sub>is</sub>={x'[j]}, z=j
//		// for the above actions, is to partition U<sub>i</sub> based on their attribute values.
//		int attrValuePointer;
//		Sample x;
//		ToleranceEquivalenceClass equClass;
//		Collection<ToleranceEquivalenceClass> equClasses = new LinkedList<>();
//		Iterator<Sample> insIterator = samples.iterator();
//		
//		x = insIterator.next();
//		attrValuePointer = x.getAttributeValueByIndex(attribute);
//		equClasses.add(equClass=new ToleranceEquivalenceClass(attrValuePointer));
//		equClass.add(x);
//		while (insIterator.hasNext()) {
//			// next instance
//			x = insIterator.next();
//			// check if a new equivalent class is required.
//			if (attrValuePointer!=x.getAttributeValueByIndex(attribute)) {
//				attrValuePointer = x.getAttributeValueByIndex(attribute);
//				equClasses.add(equClass=new ToleranceEquivalenceClass(attrValuePointer));
//			}
//			// add instance into equivalent class.
//			equClass.add(x);
//		}
//		return equClasses;
//	}
	


}

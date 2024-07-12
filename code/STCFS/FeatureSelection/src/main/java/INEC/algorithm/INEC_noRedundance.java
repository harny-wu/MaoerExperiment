package main.java.INEC.algorithm;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map.Entry;
import java.util.Set;
import java.util.stream.Collectors;

import main.Log4jPrintStream;
import main.basic.model.Sample;
import main.java.INEC.entity.equivalenceClass.IntArrayKey;
import main.java.INEC.entity.equivalenceClass.Significance;
import main.java.INEC.entity.equivalenceClass.StaticReduceResult;
import main.java.INEC.entity.equivalenceClass.TNECSizeCount;
import main.java.INEC.entity.equivalenceClass.tE;
import main.java.INEC.entity.equivalenceClass.tEListCollection;
import main.java.INEC.entity.equivalenceClass.tEtempCollection;
import main.java.INEC.entity.equivalenceClass.teCollection;
import main.java.INEC.entity.equivalenceClass.teListUpdateResult;
import main.java.INEC.entity.equivalenceClass.toleranceClass;

//主方法
public class INEC_noRedundance {
//	public ArrayList<Sample> U=new ArrayList<>();
//	public ArrayList<Sample> Uad=new ArrayList<>();
//	public ArrayList<Sample> Ude=new ArrayList<>();
//	public int CLength;
//	public int[] CName;
//	public int[] Cad;
//	public int[] Cde;
//	public ArrayList<String[]> dataArray=new ArrayList<>();
	// private teCollection Initial_te=new teCollection();
	// private tEListCollection tEList=new tEListCollection();
//	private int[] CName;
//	private int DName=0;
	// public HashMap<IntArrayKey,toleranceClass> add_te=new
	// HashMap<IntArrayKey,toleranceClass>();//新增te
//	public HashMap<IntArrayKey,toleranceClass> delete_te=new HashMap<IntArrayKey,toleranceClass>();//删除te
	// private List<Integer> Reduce;
	// List<Integer> list =
	// Arrays.stream(Reduce).boxed().collect(Collectors.toList());
	// public boolean flag_CdeContainsReduce=false;
	// public String filePath=new String();//文件地址
	// public boolean flag_notcontains1=false;
	// public HashMap<Integer,ArrayList<String[]>> dividedata=new HashMap<>();
	// public long start = System.currentTimeMillis();
	// public long end = System.currentTimeMillis();
	static {
		Log4jPrintStream.redirectSystemOut();
	}

	public INEC_noRedundance() {
	}
//	public INEC(String filePath) {
//		this.filePath=filePath;
//	}

//	public String ReduceListtoString(List<Integer> Reduce) {
//		StringBuilder ReduceString=new StringBuilder();
//		for(Integer a:Reduce)
//			ReduceString.append(a+",");
//		return ReduceString.toString();
//	}
//	public List<Integer> ReduceStringtoList(String ReduceString) {
//		List<Integer> Reduce=new ArrayList<>();
//		String[] tempArray;
//		if((ReduceString)!=null) {
//			tempArray=ReduceString.split(",");
//			for(String str:tempArray)
//				Reduce.add(Integer.parseInt(str));
//		}			
//		return Reduce;
//	}

	// 输出Initial_te
	public void outPutInitial_te(teCollection Initial_te) {
		// this.Initial_te;
		Set<Entry<IntArrayKey, toleranceClass>> CompleteSet = Initial_te.getComplete().entrySet();
		Set<Entry<IntArrayKey, toleranceClass>> IncompleteSet = Initial_te.getIncomplete().entrySet();
		for (Entry<IntArrayKey, toleranceClass> entry : CompleteSet) {
			toleranceClass te = entry.getValue();
			System.out.println(te.toString());
		}
		System.out.println("---------------");
		for (Entry<IntArrayKey, toleranceClass> entry : IncompleteSet) {
			toleranceClass te = entry.getValue();
			System.out.println(te.toString());
		}
		System.out.println();
	}

	// 输出tE_temp
	public void outPuttE_temp(tEtempCollection tE_temp) {
		if (!tE_temp.getComplete().isEmpty()) {
			Set<Entry<IntArrayKey, tE>> CompleteSet = tE_temp.getComplete().entrySet();
			for (Entry<IntArrayKey, tE> entry : CompleteSet) {
				tE tE = entry.getValue();
				System.out.println(tE.toString());
			}
		} else
			System.out.println("Complete为空");
		System.out.println("---------------");
		if (!tE_temp.getIncomplete().isEmpty()) {
			Set<Entry<IntArrayKey, tE>> IncompleteSet = tE_temp.getIncomplete().entrySet();
			for (Entry<IntArrayKey, tE> entry : IncompleteSet) {
				tE tE = entry.getValue();
				System.out.println(tE.toString());
			}
			System.out.println();
		} else
			System.out.println("Incomplete为空");
	}

//	//随机选取百分之x的数据转化为*
//	public void inputExchangeIncomplete(String filePath,double x,int num) {
//		File file=new File(filePath);
//		this.filePath=filePath;
//		ArrayList<String[]> dataArray=new ArrayList<String[]>();
//		//ArrayList<int[]> dataArrayInt=new ArrayList<int[]>();
//		int row=0,column=0;  //行列
//		try{
//			BufferedReader in=new BufferedReader(new FileReader(file));
//			String str;
//			String[] tempArray;
//			while((str=in.readLine())!=null){
//				tempArray=str.split(",");
//				dataArray.add(tempArray);
//			}
//			in.close();
//		}catch(IOException e){
//			e.getStackTrace();
//		}
//		row=dataArray.size()-1;  //行，减第一行
//		column=dataArray.get(0).length-2;   //列，减name和D
//		Random random = new Random();
//		Set<Integer> set = new LinkedHashSet<Integer>();//LinkedHashSet是有顺序不重复集合
//		double size=row*column*x;
////		String str = String.valueOf(row*column*x);//浮点变量a转换为字符串str
////	    int idx = str.lastIndexOf(".");//查找小数点的位置
////	    String strNum = str.substring(0,idx);//截取从字符串开始到小数点位置的字符串，就是整数部分
////	    int size = Integer.valueOf(strNum);//把整数部分通过Integer.valueof方法转换为数字
//		//System.out.print(column);
//		for(int m=0;m<num;m++) {
//			while(set.size()<size) {
//				Integer number=random.nextInt(row*column);
//				set.add(number);  //重复就不会添加
//			}
//			for(Integer number:set) {
//				int num1=number/column;  //得到第几行  行的前面要+1
//				int num2=number%column;  //得到第几列  列的前面要+1
//				dataArray.get(num1+1)[num2+1]="-1";		//Incomplete		
//			}
////			for(int i=0;i<dataArray.size();i++) {
////				//int[] dataline=new int[dataArray.get(i).length];
////				String[] dataString=new String[dataArray.get(i).length];
////				for(int j=0;j<dataArray.get(i).length;j++) {
////					dataString[j]=dataArray.get(i)[j];
////				}
////				dataArray.add(dataString);
////			}
//			this.dataArray=dataArray;
//			File inFile,outFile,outPath;
//			String str1=filePath.substring(0,filePath.lastIndexOf("\\"));
//			String str2=filePath.substring(filePath.lastIndexOf("\\"),filePath.lastIndexOf("."));
//			String str3=filePath.substring(filePath.lastIndexOf("."));
//			String dirPath=str1;
//			String outFilePath=str1+str2+"_"+num+str3;		
//			try{
//				outPath = new File(dirPath);
//				outFile = new File(outFilePath);	
//				if (!outPath.exists()) {
//					outPath.mkdirs();
//				}
//				if(!outFile.exists()) {
//		            outFile.createNewFile();
//		        }
//				BufferedWriter out=new BufferedWriter(new FileWriter(outFile));
//				String[] tempArray;
//				for(int i=0;i<dataArray.size();i++) {
//					tempArray=dataArray.get(i);
//					String str=new String();
//					for(int j=0;j<tempArray.length;j++) {
//						str+=tempArray[j]+",";
//					}
//					str+=System.getProperty("line.separator");
//					//System.out.print(str);
//					out.write(str);
//				}
//				out.close();
//			}catch(IOException e){
//				e.getStackTrace();
//			}
//			System.out.println("文件"+str2+"_"+num+"转换完成"+x*100+"%变为*");
//		}		
//	}
	// 输出得到Reduce划分后的文件
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
//	//将数据拆分成十份
//	public void divideDatato10_add(ArrayList<String[]> dataArray) {
//		int size=dataArray.size();
//		int row=dataArray.size()-1;  //行，减第一行
//		int column=dataArray.get(0).length-2;   //列，减name和D	
//		int finalsize=0;
//		ArrayList<String[]> alldata=new ArrayList<>();
//		alldata.addAll(dataArray);
//		HashMap<Integer,ArrayList<String[]>> dataDivide=new HashMap<>();
//		Random random = new Random();	
//		CName=new int[dataArray.get(0).length-2];
//		this.CLength=CName.length;
//		int k=0;
//		for(int j=0;j<dataArray.get(0).length-1;j++)
//			if(j!=dataArray.get(0).length-1&&j!=0) {
//				CName[k]=Integer.valueOf(dataArray.get(0)[j]);
//				k++;
//			}
//		//dataArray.remove(0);
//		for(int i=0;i<10;i++) {
//			Set<Integer> set = new LinkedHashSet<Integer>();//LinkedHashSet是有顺序不重复集合
//			random = new Random();
//			String str = String.valueOf(((double)row-i*((double)row/10)));//浮点变量a转换为字符串str
//		    int idx = str.lastIndexOf(".");//查找小数点的位置
//		    String strNum = str.substring(0,idx);//截取从字符串开始到小数点位置的字符串，就是整数部分
//		    int nowrow=0;
//		   // System.out.print(Integer.valueOf(str.substring(str.lastIndexOf(".")+1)));
//		    if(Integer.valueOf(str.substring(str.lastIndexOf(".")+1,str.lastIndexOf(".")+2))>5) 
//		    	 nowrow = Integer.valueOf(strNum)+1;	    
//		    else nowrow = Integer.valueOf(strNum);//把整数部分通过Integer.valueof方法转换为数字
//		    ArrayList<String[]> datatemp=new ArrayList<>();
//		    //System.out.println(nowrow);
//		    //System.out.println(nowrow);
//		    if(i!=9) {
//				while(set.size()<((double)row/10)) {					
//					Integer number=random.nextInt(nowrow-i);
//					set.add(number);  //重复就不会添加
//				}
//				for(Integer number:set) 
//					datatemp.add(alldata.get(number+1));//得到第几行  行的前面要+1	
//				int temp=0,min=Integer.MAX_VALUE;
//				for(int n=0;n<datatemp.size();n++) {	
//					for(int m=0;m<alldata.size();m++) {
//						if(alldata.get(m)[0].equals(datatemp.get(n)[0])) {
//							//System.out.println(alldata.get(m)[0]+"  "+datatemp.get(n)[0]);
//							alldata.remove(m);
//						}
//					}
//					
//				}	
//			}else {
//				datatemp.addAll(alldata);
//			    datatemp.remove(0);  //删除第一行
//			}
//		    dataDivide.put(i, datatemp);
//		    finalsize+=datatemp.size();
//		}
//		this.dividedata=dataDivide;
//		System.out.println("完成划分10份,共"+finalsize);
//	}
	// 将数据一半拆分成十份共11份
//	public void divideHalfDatato10(ArrayList<String[]> dataArray) {
//		int size=dataArray.size();
//		int row=dataArray.size()-1;  //行，减第一行
//		int column=dataArray.get(0).length-2;   //列，减name和D	
//		ArrayList<String[]> alldata=new ArrayList<>();
//		alldata.addAll(dataArray);
//		HashMap<Integer,ArrayList<String[]>> dataDivide=new HashMap<>();
//		Random random = new Random();	
//		CName=new int[dataArray.get(0).length-2];
//		this.CLength=CName.length;
//		int k=0;
//		for(int j=0;j<dataArray.get(0).length-1;j++)
//			if(j!=dataArray.get(0).length-1&&j!=0) {
//				CName[k]=Integer.valueOf(dataArray.get(0)[j]);
//				k++;
//			}
//		Set<Integer> set = new LinkedHashSet<Integer>();
//		ArrayList<String[]> datatemp=new ArrayList<>();
//		while(set.size()<((double)row/2)) {					
//			Integer number=random.nextInt(row-1);
//			set.add(number);  //重复就不会添加
//		}
//		for(Integer number:set) 
//			datatemp.add(alldata.get(number+1));//得到第几行  行的前面要+1	
//		int temp=0,min=Integer.MAX_VALUE;
//		for(int n=0;n<datatemp.size();n++) {	
//			for(int m=0;m<alldata.size();m++) {
//				if(alldata.get(m)[0].equals(datatemp.get(n)[0])) {
//					//System.out.println(alldata.get(m)[0]+"  "+datatemp.get(n)[0]);
//					alldata.remove(m);
//				}
//			}
//		}	
//		dataDivide.put(0, datatemp);  //一半作为初始数据
//		for(int i=0;i<10;i++) {
//			set = new LinkedHashSet<Integer>();//LinkedHashSet是有顺序不重复集合
//			random = new Random();
//			String str = String.valueOf(((double)row/2-i*((double)row/20)));//浮点变量a转换为字符串str
//		    int idx = str.lastIndexOf(".");//查找小数点的位置
//		    String strNum = str.substring(0,idx);//截取从字符串开始到小数点位置的字符串，就是整数部分
//		    int nowrow=0;
//		   // System.out.print(Integer.valueOf(str.substring(str.lastIndexOf(".")+1)));
//		    if(Integer.valueOf(str.substring(str.lastIndexOf(".")+1,str.lastIndexOf(".")+2))>5) 
//		    	 nowrow = Integer.valueOf(strNum)+1;	    
//		    else nowrow = Integer.valueOf(strNum);//把整数部分通过Integer.valueof方法转换为数字
//		    datatemp=new ArrayList<>();
//		   // System.out.println((double)row/2-i*((double)row/20));
//		   // System.out.println(row);
//		    if(i!=9) {
//				while(set.size()<((double)row/20)) {					
//					Integer number=random.nextInt(nowrow-i);
//					set.add(number);  //重复就不会添加
//				}
//				for(Integer number:set) 
//					datatemp.add(alldata.get(number+1));//得到第几行  行的前面要+1	
//				temp=0;min=Integer.MAX_VALUE;
//				for(int n=0;n<datatemp.size();n++) {	
//					for(int m=0;m<alldata.size();m++) {
//						if(alldata.get(m)[0].equals(datatemp.get(n)[0])) {
//							//System.out.println(alldata.get(m)[0]+"  "+datatemp.get(n)[0]);
//							alldata.remove(m);
//						}
//					}
//				}	
//				//System.out.println(alldata.size());
//			}else {
//				datatemp.addAll(alldata);
//			    datatemp.remove(0);  //删除第一行
//			}
//		    dataDivide.put(i+1, datatemp);	   
//		}
//		this.dividedata=dataDivide;
//		System.out.println("完成将一半数据作为初始数据，另一半划分成10份");
//	}
	// 将数据拆分成十份
//	public void divideDatato10_delete(ArrayList<String[]> dataArray) {
//		int size=dataArray.size();
//		int row=dataArray.size()-1;  //行，减第一行
//		int column=dataArray.get(0).length-2;   //列，减name和D	
//		ArrayList<String[]> alldata=new ArrayList<>();
//		alldata.addAll(dataArray);
//		HashMap<Integer,ArrayList<String[]>> dataDivide=new HashMap<>();
//		Random random = new Random();	
////		CName=new int[dataArray.get(0).length-2];
////		this.CLength=CName.length;
////		int k=0;
////		for(int j=0;j<dataArray.get(0).length-1;j++)
////			if(j!=dataArray.get(0).length-1&&j!=0) {
////				CName[k]=Integer.valueOf(dataArray.get(0)[j]);
////				k++;
////			}
//		for(int i=0;i<10;i++) {
//			Set<Integer> set = new LinkedHashSet<Integer>();//LinkedHashSet是有顺序不重复集合
//			random = new Random();
//			String str = String.valueOf(((double)row-i*((double)row/10)));//浮点变量a转换为字符串str
//		    int idx = str.lastIndexOf(".");//查找小数点的位置
//		    String strNum = str.substring(0,idx);//截取从字符串开始到小数点位置的字符串，就是整数部分
//		    int nowrow=0;
//		   // System.out.print(Integer.valueOf(str.substring(str.lastIndexOf(".")+1)));
//		    if(Integer.valueOf(str.substring(str.lastIndexOf(".")+1,str.lastIndexOf(".")+2))>5) 
//		    	 nowrow = Integer.valueOf(strNum)+1;	    
//		    else nowrow = Integer.valueOf(strNum);//把整数部分通过Integer.valueof方法转换为数字
//		    ArrayList<String[]> datatemp=new ArrayList<>();
//		    //System.out.println(nowrow);
//		    //System.out.println(nowrow);
//		    if(i!=9) {
//				while(set.size()<((double)row/10)) {					
//					Integer number=random.nextInt(nowrow-i);
//					set.add(number);  //重复就不会添加
//				}
//				for(Integer number:set) 
//					datatemp.add(alldata.get(number+1));//得到第几行  行的前面要+1	
//				int temp=0,min=Integer.MAX_VALUE;
//				for(int n=0;n<datatemp.size();n++) {	
//					for(int m=0;m<alldata.size();m++) {
//						if(alldata.get(m)[0].equals(datatemp.get(n)[0])) {
//							//System.out.println(alldata.get(m)[0]+"  "+datatemp.get(n)[0]);
//							alldata.remove(m);
//						}
//					}
//					
//				}	
//				//System.out.println(alldata.size());
//			}else {
//				datatemp.addAll(alldata);
//			    datatemp.remove(0);  //删除第一行
//			}
//		    dataDivide.put(i, datatemp);	   
//		}
//		this.dividedata=dataDivide;
//		System.out.println("完成划分10份");
//	}

//	//通过划分的数据集input
//	public void inputData_divideInitial(int num) {  //num为将几份数据作为原始数据
//		this.U=new ArrayList<>();
//		ArrayList<String[]> dataArray=new ArrayList<>();
//		for(int m=0;m<num;m++)
//			dataArray.addAll(this.dividedata.get(m));//前num份数据组成初始数据	
////		CName=new int[dataArray.get(0).length-2];
////		this.CLength=CName.length;
////		int n=0;
////		for(int i=0;i<dataArray.get(0).length;i++) {
////			String[] data=dataArray.get(0);		
////			if(i!=data.length-1&&i!=0) {
////				CName[n]=Integer.valueOf(data[i]);	
////				n++;
////			}
////		}
//		for(int i=0;i<dataArray.size();i++) {
//			String[] data=dataArray.get(i);
//			Sample x=new Sample(Integer.valueOf(data[0]),new int[data.length-1]);				
//			for(int j=0;j<data.length;j++) {					
//				if(j!=data.length-1&&j!=0) { 
//					x.setAttributeValueOf(j,Integer.parseInt(data[j]));
//					if(Integer.parseInt(data[j])==-1)
//						x.setIs_Incomplete(true);
//				}else if(j==data.length-1) 
//					x.setAttributeValueOf(0,Integer.parseInt(data[j]));							
//			}	
//			this.U.add(x);
//		}
//		//this.CLength=dataArray.get(0).length-2;
//	}
//	
//	//通过划分的数据集input
//	public void inputData_divideAdd(int num) {   //num是添加第几部分
//		this.Uad=new ArrayList<>();
//		ArrayList<String[]> dataArray=new ArrayList<>();
//		dataArray.addAll(this.dividedata.get(num));
//		for(int i=0;i<dataArray.size();i++) {
//			String[] data=dataArray.get(i);
//			Sample x=new Sample(Integer.valueOf(data[0]),new int[data.length-1]);			
//			for(int j=0;j<data.length;j++) {					
//				if(j!=data.length-1&&j!=0) {
//					x.setAttributeValueOf(j,Integer.parseInt(data[j]));
//					if(Integer.parseInt(data[j])==-1)
//						x.setIs_Incomplete(true);
//				}else if(j==data.length-1) 
//					x.setAttributeValueOf(0,Integer.parseInt(data[j]));
//			}
//			this.Uad.add(x);
//		}
//		this.U.addAll(Uad);
//		//this.CLength=dataArray.get(0).length-2;
//	}
//	//通过划分的数据集input
//	public void inputData_divideDelete(int num) {   //num是删除第几部分
//		this.Ude=new ArrayList<>();
//		ArrayList<String[]> dataArray=new ArrayList<>();
//		dataArray.addAll(this.dividedata.get(num));
//		for(int i=0;i<dataArray.size();i++) {
//			String[] data=dataArray.get(i);
//			Sample x=new Sample(Integer.valueOf(data[0]),new int[data.length-1]);
//			for(int j=0;j<data.length;j++) {					
//				if(j!=data.length-1&&j!=0) {
//					x.setAttributeValueOf(j,Integer.parseInt(data[j]));
//					if(Integer.parseInt(data[j])==-1)
//						x.setIs_Incomplete(true);
//				}else if(j==data.length-1) 
//					x.setAttributeValueOf(0,Integer.parseInt(data[j]));
//			}
//			this.Ude.add(x);
//			
//		}
//		for(int k=0;k<dataArray.size();k++) {
//			U.remove(Ude.get(k));
//		}
//		this.CLength=dataArray.get(0).length-2;
//		//System.out.print(Ude.size());
//	}
//	
//	public void inputData(String filePath) {
//		File file=new File(filePath);
//		this.filePath=filePath;
//		ArrayList<String[]> dataArray=new ArrayList<String[]>();
//		//ArrayList<int[]> dataArrayInt=new ArrayList<int[]>();
//		//this.dataArray=dataArray;
//		try{
//			BufferedReader in=new BufferedReader(new FileReader(file));
//			String str;
//			String[] tempArray;
//			while((str=in.readLine())!=null){
//				tempArray=str.split(",");
//				dataArray.add(tempArray);
//			}
//			in.close();
//		}catch(IOException e){
//			e.getStackTrace();
//		}
//		this.dataArray=dataArray;
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
//		for(int i=1;i<dataArray.size();i++) {
//			String[] data=dataArray.get(i);
//			//int[] dataInt=new int[dataArray.get(i).length];
//			Sample x=new Sample(Integer.parseInt(data[0]),new int[data.length-1]);
//				for(int j=0;j<data.length;j++) {	
//					//dataInt[j]=Integer.parseInt(data[j]);
//					if(j!=data.length-1&&j!=0) {
//						x.setAttributeValueOf(j,Integer.parseInt(data[j]));
//						if(Integer.parseInt(data[j])==-1)
//							x.setIs_Incomplete(true);
//					}else if(j==data.length-1) 
//						x.setAttributeValueOf(0,Integer.parseInt(data[j]));
//				}
//			//this.dataArray.add(dataInt);
//			this.U.add(x);							
//		}
//		//this.CLength=dataArray.get(0).length-2;
//	}

	// addSample
//	public void inputData_add(String filePath) {
//		File file=new File(filePath);
//		ArrayList<String[]> dataArray=new ArrayList<String[]>();
//		try{
//			BufferedReader in=new BufferedReader(new FileReader(file));
//			String str;
//			String[] tempArray;
//			while((str=in.readLine())!=null){
//				tempArray=str.split(",");
//				dataArray.add(tempArray);
//			}
//			in.close();
//		}catch(IOException e){
//			e.getStackTrace();
//		}
//		for(int i=0;i<dataArray.size();i++) {
//			String[] data=dataArray.get(i);
//			Sample x=new Sample(Integer.parseInt(data[0]),new int[data.length-1]);
//			if(i!=0) {
//				for(int j=0;j<data.length;j++) {					
//					if(j!=data.length-1&&j!=0) {
//						x.setAttributeValueOf(j,Integer.parseInt(data[j]));
//						if(Integer.parseInt(data[j])==-1)
//							x.setIs_Incomplete(true);
//					}else if(j==data.length-1) 
//						x.setAttributeValueOf(0,Integer.parseInt(data[j]));
//				}
//				this.Uad.add(x);	
//			}
//		}
//		this.U.addAll(Uad);
//	}

	// deleteSample
//	public void inputData_delete(String filePath) {
//		File file=new File(filePath);
//		ArrayList<String[]> dataArray=new ArrayList<String[]>();
//		try{
//			BufferedReader in=new BufferedReader(new FileReader(file));
//			String str;
//			String[] tempArray;
//			while((str=in.readLine())!=null){
//				tempArray=str.split(",");
//				dataArray.add(tempArray);
//			}
//			in.close();
//		}catch(IOException e){
//			e.getStackTrace();
//		}
//		for(int i=0;i<dataArray.size();i++) {
//			String[] data=dataArray.get(i);
//			Sample x=new Sample(Integer.parseInt(data[0]),new int[data.length-1]);
//			if(i!=0) {
//				for(int j=0;j<data.length;j++) {					
//					if(j!=data.length-1&&j!=0) {
//						x.setAttributeValueOf(j,Integer.parseInt(data[j]));
//						if(Integer.parseInt(data[j])==-1)
//							x.setIs_Incomplete(true);
//					}else if(j==data.length-1) 
//						x.setAttributeValueOf(0,Integer.parseInt(data[j]));
//				}				
//				this.Ude.add(x);
//			}		
//		}
//		for(int k=0;k<dataArray.size();k++) {
//			U.remove(Ude.get(k));
//		}
//	}

	// addSample
//	public void inputData_multi(String addfilePath,String deletefilePath) {
//		this.inputData_add(addfilePath);
//		this.inputData_delete(deletefilePath);
//	}

	// addSample
//	public void inputData_deleteAttribute(String filePath) {		
//		File file=new File(filePath);
//		ArrayList<String[]> dataArray=new ArrayList<String[]>();
//		try{
//			BufferedReader in=new BufferedReader(new FileReader(file));
//			String str;
//			String[] tempArray;
//			while((str=in.readLine())!=null){
//				tempArray=str.split(",");
//				dataArray.add(tempArray);
//			}
//			in.close();
//		}catch(IOException e){
//			e.getStackTrace();
//		}
//		this.Cde=new int[dataArray.get(0).length];
//		for(int i=0;i<dataArray.size();i++) {
//			String[] data=dataArray.get(i);
//			for(int j=0;j<data.length;j++) 				
//				this.Cde[j]=Integer.parseInt(data[j]);								
//		}
//	}

	// 12 判断B的属性值中是否含有*
	public boolean containsIncomplete(List<Integer> BAttr) {
		for (Integer attribute : BAttr)
			if (attribute == -1)
				return true;
		return false;
	}

	// 1 生成初始等价类te表（未含TE）
	public teCollection generateInitialEquivalenceClasses_te(Collection<Sample> U) {
		HashMap<IntArrayKey, toleranceClass> Complete = new HashMap<>(U.size());
		HashMap<IntArrayKey, toleranceClass> Incomplete = new HashMap<>(U.size());
		HashMap<IntArrayKey, toleranceClass> temp;
		for (Sample x : U) {
			IntArrayKey hashkey = new IntArrayKey(x.getConditionValues());
			if (x.isIs_Incomplete()) // 当x不含*
				temp = Incomplete;
			else
				temp = Complete;
			if (temp.containsKey(hashkey)) { // temp含x.c
				toleranceClass te = temp.get(hashkey);
				te.getMember().add(x);
				te.setCount(te.getCount() + 1);
				if (x.getDecisionValues() != te.getDec()) {
					te.setDec(-1);
					te.setCnst(-1);
					te.settCnst(-1);
					te.settDec(-1);
				}
			} else { // temp不含x.c
				toleranceClass te = new toleranceClass(x.getConditionValues(), x, 1, 1, x.getDecisionValues(),
						new LinkedList<>(), x.getDecisionValues(), 1); // 新建，默认tnst=tCnst=1
				temp.put(hashkey, te);
			}
		}
		teCollection Initial_te = new teCollection(Complete, Incomplete);
		// this.outPutInitial_te(Initial_te); //输出Initial——te
		return Initial_te;
	}

	// 2 在te表中添加TE
	public teCollection addTE_te(teCollection Initial_te) {
		Set<Entry<IntArrayKey, toleranceClass>> IncompleteSet = Initial_te.getIncomplete().entrySet();
		Set<Entry<IntArrayKey, toleranceClass>> CompleteSet = Initial_te.getComplete().entrySet();
		Set<Entry<IntArrayKey, toleranceClass>> IncompleteSet_tempSet = new HashSet<>(IncompleteSet);
		if (IncompleteSet.size() != 0)
			for (Entry<IntArrayKey, toleranceClass> entry1 : IncompleteSet) {
				toleranceClass te1 = entry1.getValue();
				IncompleteSet_tempSet.remove(entry1);
				for (Entry<IntArrayKey, toleranceClass> entry2 : IncompleteSet_tempSet) {
					toleranceClass te2 = entry2.getValue();
					if (te1.tolerateEqual(te2.getValue())) { // 除*之外值都相同
						// if(!te1.getTE().contains(te2)) { //不确定是否删除这一步
						te1.getTE().add(te2);
						te2.getTE().add(te1);
						if (te1.getDec() != te2.getDec()) { // 包含两种情况，一相同且不为/，二相同为/
							te2.settDec(-1);
							te2.settCnst(-1);
							te1.settDec(-1);
							te1.settCnst(-1);
						}
						// }
					}
					// Initial_te.getIncomplete().replace(entry2.getKey(),te2);
				}
				// Initial_te.getIncomplete().replace(entry1.getKey(), te1);
			}
		if (IncompleteSet.size() != 0 && CompleteSet.size() != 0)
			for (Entry<IntArrayKey, toleranceClass> entry1 : IncompleteSet) {
				toleranceClass te1 = entry1.getValue();
				for (Entry<IntArrayKey, toleranceClass> entry2 : CompleteSet) {
					toleranceClass te2 = entry2.getValue();
					if (te1.tolerateEqual(te2.getValue())) { // 除*之外值都相同
						// if(!te1.getTE().contains(te2)) {
						te1.getTE().add(te2);
						te2.getTE().add(te1);
						if (te1.getDec() != te2.getDec()) { // 包含两种情况，一相同且不为/，二相同为/
							te2.settDec(-1);
							te2.settCnst(-1);
							te1.settDec(-1);
							te1.settCnst(-1);
						}
						// }
					}
					// Initial_te.getComplete().replace(entry2.getKey(), te2);
				}
				// Initial_te.getIncomplete().replace(entry1.getKey(), te1);
			}
		// this.Initial_te=Initial_te;
		// this.outPutInitial_te(Initial_te); //输出Initial——te
		return Initial_te;
	}

	// 4 得到初始等价类tE表（针对一个属性）
	public tEtempCollection generateInitial_tE_single(teCollection Initial_te, int attribute) {
		tEtempCollection tE_temp = new tEtempCollection(
				Initial_te.getComplete().size() + Initial_te.getIncomplete().size());
		Set<Entry<IntArrayKey, toleranceClass>> CompleteKeySet = Initial_te.getComplete().entrySet();
		Set<Entry<IntArrayKey, toleranceClass>> IncompleteKeySet = Initial_te.getIncomplete().entrySet();
//		ArrayList<String> attrC=B;
//		attrC.add(attribute);
		for (Entry<IntArrayKey, toleranceClass> entry : CompleteKeySet) { // Complete
			toleranceClass te = entry.getValue();
			// ArrayList<Integer> value=(ArrayList<Integer>) te.getBValuetoList(B);
			IntArrayKey hashkey = new IntArrayKey(te.getAttributeValue(attribute));
			// System.out.println(hashkey.toString());
//			if (B!=null)
//				for(int a:B) {
//					value.add(te.getAttributeValue(a));
//					//attrValue+=te.getValue().get(a);
//					}
			if (tE_temp.getComplete().containsKey(hashkey)) {
				// System.out.print("存在"+te.getValue().get(attribute));
				tE tE = tE_temp.getComplete().get(hashkey);
				if (te.gettCnst() == 1)
					tE.setM_tCnst(true);
				tE.setCount(tE.getCount() + te.getCount());
				tE.settCount(tE.gettCount() + te.getCount());
				tE.getMember().add(te);
				if (tE.getDec() == te.getDec() && tE.getCnst() == 1 && te.getCnst() == 1) {
				} else if (tE.getCnst() == -1 && te.getCnst() == -1) {
				} else {
					tE.setCnst(0);
					tE.setDec(-1);
					tE.settCnst(-1);
					tE.settDec(-1);
				}
				if (tE.isM_tCnst() && tE.gettCnst() != 1)
					tE.settCnst(0);
			} else {
				ArrayList<Integer> valuenew = new ArrayList<Integer>(1);
				valuenew.add(te.getAttributeValue(attribute));
				tE tE = new tE(valuenew, te, te.getCount(), te.getCnst(), te.getDec(), te.istetCnst(),
						new LinkedList<toleranceClass>(), te.getCount(), te.getDec(), te.getCnst()); // 新建
				tE_temp.getComplete().put(hashkey, tE);
				// value.remove(value.size()-1);
				// System.out.print(tE_temp.getComplete().get(hashkey));
				// this.outPuttE_temp(tE_temp);
			}
		}
		for (Entry<IntArrayKey, toleranceClass> entry : IncompleteKeySet) {
			toleranceClass te = entry.getValue();
			IntArrayKey hashkey = new IntArrayKey(te.getAttributeValue(attribute));
			// System.out.println(hashkey.toString());
			if (tE_temp.getIncomplete().containsKey(hashkey) || tE_temp.getComplete().containsKey(hashkey)) {
				tE tE = new tE();
				if (tE_temp.getComplete().containsKey(hashkey))
					tE = tE_temp.getComplete().get(hashkey);
				else if (tE_temp.getIncomplete().containsKey(hashkey))
					tE = tE_temp.getIncomplete().get(hashkey);
				if (te.gettCnst() == 1)
					tE.setM_tCnst(true);
				tE.setCount(tE.getCount() + te.getCount());
				tE.settCount(tE.gettCount() + te.getCount());
				tE.getMember().add(te);
				if (tE.getDec() == te.getDec() && tE.getCnst() == 1 && te.getCnst() == 1) {
				} else if (tE.getCnst() == -1 && te.getCnst() == -1) {
				} else {
					tE.setCnst(0);
					tE.setDec(-1);
					tE.settCnst(-1);
					tE.settDec(-1);
				}
				if (tE.isM_tCnst() && tE.gettCnst() != 1)
					tE.settCnst(0);
			} else if (te.getAttributeValue(attribute) == -1) {
				ArrayList<Integer> valuenew = new ArrayList<Integer>(1);
				valuenew.add(te.getAttributeValue(attribute));
				tE tE = new tE(valuenew, te, te.getCount(), te.getCnst(), te.getDec(), te.istetCnst(),
						new LinkedList<toleranceClass>(), te.getCount(), te.getDec(), te.getCnst()); // 新建
				tE_temp.getIncomplete().put(hashkey, tE);
			} else if (te.getAttributeValue(attribute) != -1) {
				ArrayList<Integer> valuenew = new ArrayList<Integer>(1);
				valuenew.add(te.getAttributeValue(attribute));
				tE tE = new tE(valuenew, te, te.getCount(), te.getCnst(), te.getDec(), te.istetCnst(),
						new LinkedList<toleranceClass>(), te.getCount(), te.getDec(), te.getCnst()); // 新建
				tE_temp.getComplete().put(hashkey, tE);
			}
		}
		return tE_temp;
	}

	// 5 在tE表中添加TE（针对一个属性）
	public tEtempCollection addTE_tE_single(tEtempCollection tE_temp) {
		// this.outPuttE_temp(tE_temp);
		Set<Entry<IntArrayKey, tE>> CompleteSet = tE_temp.getComplete().entrySet();
		if (tE_temp.getIncomplete().containsKey(new IntArrayKey(-1)) && CompleteSet != null) {
			tE tE = tE_temp.getIncomplete().get(new IntArrayKey(-1)); // Incomplete
			for (Entry<IntArrayKey, tE> entry : CompleteSet) {
				tE tE1 = entry.getValue(); // Complete
				tE1.addNotContaintE(tE.getMember());
				tE.addNotContaintE(tE1.getMember());
				tE.addtCount(tE1.getCount());
				tE1.addtCount(tE.getCount());
				if (tE1.getDec() == tE.getDec() && tE1.getCnst() == 1 && tE.getCnst() == 1) {
				} else if (tE1.getCnst() == -1 && tE.getCnst() == -1) {
				} else {
					tE1.settDec(-1);
					tE.settDec(-1);
					tE.settCnst(-1);
					tE1.settCnst(-1);
				}
				if (tE1.isM_tCnst() && tE1.gettCnst() != 1)
					tE1.settCnst(0);
				// tE_temp.getComplete().replace(entry.getKey(), tE1);
			}
			if (tE.isM_tCnst() && tE.gettCnst() != 1)
				tE.settCnst(0);
			// tE_temp.getIncomplete().replace(new IntArrayKey(-1),tE);
		}
		return tE_temp;
	}

	// 6 得到初始等价类tE表（针对多个属性）
	public tEtempCollection generateInitial_tE_multi(teCollection Initial_te, int[] B) {
		tEtempCollection tE_temp = new tEtempCollection(
				Initial_te.getComplete().size() + Initial_te.getIncomplete().size());
		Set<Entry<IntArrayKey, toleranceClass>> tempKeySet;
		for (int k = 0; k < 2; k++) {
			if (k == 0)
				tempKeySet = Initial_te.getComplete().entrySet(); // CompleteKeySet
			else
				tempKeySet = Initial_te.getIncomplete().entrySet(); // IncompleteKeySet
			for (Entry<IntArrayKey, toleranceClass> entry : tempKeySet) {
				toleranceClass te = entry.getValue();
				int[] valueCollection = te.getBValue(B);
				ArrayList<Integer> value = (ArrayList<Integer>) Arrays.stream(valueCollection).boxed()
						.collect(Collectors.toList());
				IntArrayKey hashkey = new IntArrayKey(valueCollection);
				HashMap<IntArrayKey, tE> temp;
				if (!te.is_BValueIncomplete(B)) // 判断是否包含*
					temp = tE_temp.getComplete();
				else
					temp = tE_temp.getIncomplete();
				if (temp.containsKey(hashkey)) {
					tE tE = temp.get(hashkey);
					if (te.gettCnst() == 1)
						tE.setM_tCnst(true);
					tE.setCount(tE.getCount() + te.getCount());
					tE.settCount(tE.gettCount() + te.getCount());
					tE.getMember().add(te);
					if (tE.getDec() == te.getDec() && tE.getCnst() == 1 && te.getCnst() == 1) {
					} else if (tE.getCnst() == -1 && te.getCnst() == -1) {
					} else {
						tE.setCnst(0);
						tE.setDec(-1);
						tE.settCnst(-1);
						tE.settDec(-1);
					}
					if (tE.isM_tCnst() && tE.gettCnst() != 1)
						tE.settCnst(0);
				} else {
					tE tE = new tE(value, te, te.getCount(), te.getCnst(), te.getDec(), te.istetCnst(),
							new LinkedList<toleranceClass>(), te.getCount(), te.getDec(), te.getCnst()); // 新建
					temp.put(hashkey, tE);
				}
			}
		}
		return tE_temp;
	}

	// 7 在tE表中添加TE（针对多个属性）
	public tEtempCollection addTE_tE_multi(tEtempCollection tE_temp) {
		Set<Entry<IntArrayKey, tE>> IncompleteSet = tE_temp.getIncomplete().entrySet();
		Set<Entry<IntArrayKey, tE>> CompleteSet = tE_temp.getComplete().entrySet();
		Set<Entry<IntArrayKey, tE>> IncompleteSet_temp = new HashSet<Entry<IntArrayKey, tE>>(IncompleteSet);
		if (IncompleteSet.size() != 0)
			for (Entry<IntArrayKey, tE> entry1 : IncompleteSet) {
				tE tE1 = entry1.getValue();
				IncompleteSet_temp.remove(entry1);
				for (Entry<IntArrayKey, tE> entry2 : IncompleteSet_temp) {
					tE tE2 = entry2.getValue();
					if (tE1.getValue().size() == tE2.getValue().size()) // 20220803新增
						if (tE1.tolerateEqual(tE2.getValue())) { // 除*之外值都相同
							tE1.addNotContaintE(tE2.getMember());
							tE2.addNotContaintE(tE1.getMember());
							tE1.addtCount(tE2.getCount());
							tE2.addtCount(tE1.getCount());
							if (tE1.getDec() == tE2.getDec() && tE1.getCnst() == 1 && tE2.getCnst() == 1) {
							} else if (tE1.getCnst() == -1 && tE2.getCnst() == -1) {
							} else {
								tE1.settDec(-1);
								tE2.settDec(-1);
								tE1.settCnst(-1);
								tE2.settCnst(-1);
							}
						}
					if (tE2.isM_tCnst() && tE2.gettCnst() != 1)
						tE2.settCnst(0);
					// tE_temp.get(1).replace(Key2, tE2);
				}
				if (tE1.isM_tCnst() && tE1.gettCnst() != 1)
					tE1.settCnst(0);
				// tE_temp.get(1).replace(Key1, tE1);
			}
		if (IncompleteSet.size() != 0 && CompleteSet.size() != 0)
			for (Entry<IntArrayKey, tE> entry1 : IncompleteSet) {
				tE tE1 = entry1.getValue();
				for (Entry<IntArrayKey, tE> entry2 : CompleteSet) {
					tE tE2 = entry2.getValue();
					if (tE1.getValue().size() == tE2.getValue().size()) // 20220803新增
						if (tE1.tolerateEqual(tE2.getValue())) { // 除*之外值都相同
							tE1.addNotContaintE(tE2.getMember());
							tE2.addNotContaintE(tE1.getMember());
							tE1.addtCount(tE2.getCount());
							tE2.addtCount(tE1.getCount());
							if (tE1.getDec() == tE2.getDec() && tE1.getCnst() == 1 && tE2.getCnst() == 1) {
							} else if (tE1.getCnst() == -1 && tE2.getCnst() == -1) {
							} else {
								tE1.settDec(-1);
								tE2.settDec(-1);
								tE1.settCnst(-1);
								tE2.settCnst(-1);
							}
						}
					if (tE2.isM_tCnst() && tE2.gettCnst() != 1)
						tE2.settCnst(0);
					// tE_temp.get(0).replace(Key2, tE2);
				}
				if (tE1.isM_tCnst() && tE1.gettCnst() != 1)
					tE1.settCnst(0);
				// tE_temp.get(1).replace(Key1, tE1);
			}
		return tE_temp;
	}

	// 得到初始等价类tE表_针对迭代member+TE_sigletE //只以tE_temp.member
	public tEtempCollection generateInitial_tE_iteration_singletE(
			ArrayList<HashMap<IntArrayKey, toleranceClass>> teList, int attribute, int[] B) {
		tEtempCollection tE_temp = new tEtempCollection(teList.get(0).size() + teList.get(1).size());
		Set<Entry<IntArrayKey, toleranceClass>> memberKeySet = teList.get(0).entrySet();
		Set<Entry<IntArrayKey, toleranceClass>> TEKeySet = teList.get(1).entrySet();
		for (Entry<IntArrayKey, toleranceClass> entry : memberKeySet) { // 只添加member作为tE
			toleranceClass te = entry.getValue();
			int[] valueCollection = te.getBValue(B);
			ArrayList<Integer> value = (ArrayList<Integer>) Arrays.stream(valueCollection).boxed()
					.collect(Collectors.toList());
			// IntArrayKey hashkey=new IntArrayKey(valueCollection);
			IntArrayKey attrvalue = new IntArrayKey(te.getAttributeValue(attribute));
			HashMap<IntArrayKey, tE> temp;
			if (te.getAttributeValue(attribute) != -1) // Complete
				temp = tE_temp.getComplete();
			else
				temp = tE_temp.getIncomplete();
			if (temp.containsKey(attrvalue)) {
				tE tE = temp.get(attrvalue);
				if (te.gettCnst() == 1)
					tE.setM_tCnst(true);
				tE.setCount(tE.getCount() + te.getCount());
				tE.settCount(tE.gettCount() + te.getCount());
				tE.getMember().add(te);
				if (tE.getDec() == te.getDec() && tE.getCnst() == 1 && te.getCnst() == 1) {
				} else if (tE.getCnst() == -1 && te.getCnst() == -1) {
				} else {
					tE.setCnst(0);
					tE.setDec(-1);
					tE.settCnst(-1);
					tE.settDec(-1);
				}
				if (tE.isM_tCnst() && tE.gettCnst() != 1)
					tE.settCnst(0);
			} else {
				ArrayList<Integer> newvalue = (ArrayList<Integer>) value.clone();
				newvalue.add(te.getAttributeValue(attribute));
				tE tE = new tE(newvalue, te, te.getCount(), te.getCnst(), te.getDec(), te.istetCnst(),
						new LinkedList<toleranceClass>(), te.getCount(), te.getDec(), te.getCnst()); // 新建
				temp.put(attrvalue, tE);
				// value.remove(value.size()-1);
			}
		}
		for (Entry<IntArrayKey, toleranceClass> entry : TEKeySet) { // 将TE中的te直接添加到tE.TE中
			toleranceClass te = entry.getValue();
			// LinkedList<Integer> value=(LinkedList<Integer>)
			// Arrays.stream(B).boxed().collect(Collectors.toList());
			// IntArrayKey hashkey=new IntArrayKey(valueCollection);
			IntArrayKey attrvalue = new IntArrayKey(te.getAttributeValue(attribute));
			if (tE_temp.getIncomplete().size() != 0)
				if (tE_temp.getComplete().containsKey(attrvalue) || te.getAttributeValue(attribute) == -1) { // tE_temp.get(0).containsKey(attrValue+te.getValue().get(attribute))
					tE tE = new tE();
					if (tE_temp.getComplete().containsKey(attrvalue)) {
						tE = tE_temp.getComplete().get(attrvalue);
//					if (te.gettCnst()==1) 
//						tE.settCnst(1);
						tE.getTE().add(te);
						tE.settCount(tE.gettCount() + te.getCount());
						if (tE.getDec() == te.getDec() && tE.getCnst() == 1 && te.getCnst() == 1) {
						} else if (tE.getCnst() == -1 && te.getCnst() == -1) {
						} else {
							tE.settCnst(-1);
							tE.settDec(-1);
						}
						if (tE.isM_tCnst() && tE.gettCnst() != 1)
							tE.settCnst(0);
					} else { // te="*"
						Set<Entry<IntArrayKey, tE>> entrySet1 = tE_temp.getComplete().entrySet();
						for (Entry<IntArrayKey, tE> entry1 : entrySet1) {
							tE = entry1.getValue();
//						if (te.gettCnst()==1) 
//							tE.settCnst(1);
							tE.getTE().add(te);
							tE.settCount(tE.gettCount() + te.getCount());
							if (tE.getDec() == te.getDec() && tE.getCnst() == 1 && te.getCnst() == 1) {
							} else if (tE.getCnst() == -1 && te.getCnst() == -1) {
							} else {
								tE.settCnst(-1);
								tE.settDec(-1);
							}
							if (tE.isM_tCnst() && tE.gettCnst() != 1)
								tE.settCnst(0);
						}
					}
				}
			if (tE_temp.getIncomplete().size() != 0) {
				if (tE_temp.getIncomplete().containsKey(attrvalue) || te.getAttributeValue(attribute) == -1
						|| tE_temp.getIncomplete().containsKey(new IntArrayKey(-1))) {
					tE tE = tE_temp.getIncomplete().get(new IntArrayKey(-1));
					tE.getTE().add(te);
					tE.settCount(tE.gettCount() + te.getCount());
					if (tE.getDec() == te.getDec() && tE.getCnst() == 1 && te.getCnst() == 1) {
					} else if (tE.getCnst() == -1 && te.getCnst() == -1) {
					} else {
						tE.settCnst(-1);
						tE.settDec(-1);
					}
					if (tE.isM_tCnst() && tE.gettCnst() != 1)
						tE.settCnst(0);
				}
			}
		}
		return tE_temp;
	}

	// 得到初始等价类tE表_针对迭代member+TE_multitE //只以tE_temp.member
	public tEtempCollection generateInitial_tE_iteration_multitE(ArrayList<HashMap<IntArrayKey, toleranceClass>> teList,
			int attribute, int[] B) {
		tEtempCollection tE_temp = new tEtempCollection(teList.get(0).size() + teList.get(1).size());
		Set<Entry<IntArrayKey, toleranceClass>> memberKeySet = teList.get(0).entrySet();
		Set<Entry<IntArrayKey, toleranceClass>> TEKeySet = teList.get(1).entrySet();
		for (Entry<IntArrayKey, toleranceClass> entry : memberKeySet) { // 只添加member作为tE
			toleranceClass te = entry.getValue();
			// boolean flag=te.is_BValueIncomplete(B);
			int[] valueCollection = te.getBValue(B);
			ArrayList<Integer> value = (ArrayList<Integer>) Arrays.stream(valueCollection).boxed()
					.collect(Collectors.toList());
			IntArrayKey hashkey = new IntArrayKey(valueCollection);
			hashkey.addKey(te.getAttributeValue(attribute));
			// IntArrayKey attrvalue=new IntArrayKey(te.getAttributeValue(attribute));
			HashMap<IntArrayKey, tE> temp;
			if (te.getAttributeValue(attribute) != -1 && !te.is_BValueIncomplete(B)) // Complete
				temp = tE_temp.getComplete();// Complete
			else
				temp = tE_temp.getIncomplete(); // Incomplete
			if (temp.containsKey(hashkey)) {
				tE tE = temp.get(hashkey);
				if (te.gettCnst() == 1)
					tE.setM_tCnst(true);
				tE.setCount(tE.getCount() + te.getCount());
				tE.settCount(tE.gettCount() + te.getCount());
				tE.getMember().add(te);
				if (tE.getDec() == te.getDec() && tE.getCnst() == 1 && te.getCnst() == 1) {
				} else if (tE.getCnst() == -1 && te.getCnst() == -1) {
				} else {
					tE.setCnst(0);
					tE.setDec(-1);
					tE.settCnst(-1);
					tE.settDec(-1);
				}
				if (tE.isM_tCnst() && tE.gettCnst() != 1)
					tE.settCnst(0);
			} else {
				ArrayList<Integer> newvalue = (ArrayList<Integer>) value.clone();
				newvalue.add(te.getAttributeValue(attribute));
				tE tE = new tE(newvalue, te, te.getCount(), te.getCnst(), te.getDec(), te.istetCnst(),
						new LinkedList<toleranceClass>(), te.getCount(), te.getDec(), te.getCnst()); // 新建
				temp.put(hashkey, tE);
				// value.remove(value.size()-1);
			}
		}
		for (Entry<IntArrayKey, toleranceClass> entry : TEKeySet) { // 将TE中的te直接添加到tE.TE中
			toleranceClass te = entry.getValue();
			ArrayList<Integer> value = (ArrayList<Integer>) te.getBValuetoList(B);
			value.add(te.getAttributeValue(attribute));
			// attrValue+=te.getValue().get(attribute)+",";
			HashMap<IntArrayKey, tE> temp;
			for (int k = 0; k < 2; k++) {
				if (k == 0)
					temp = tE_temp.getComplete();
				else
					temp = tE_temp.getIncomplete();
				if (temp.size() != 0) {
					Set<Entry<IntArrayKey, tE>> keyset = temp.entrySet();
					for (Entry<IntArrayKey, tE> entry2 : keyset) {
						tE tE = entry2.getValue();
						if (tE.tolerateEqual(value)) {
							tE.getTE().add(te);
							tE.settCount(tE.gettCount() + te.getCount());
							if (tE.getDec() == te.getDec() && tE.getCnst() == 1 && te.getCnst() == 1) {
							} else if (tE.getCnst() == -1 && te.getCnst() == -1) {
							} else {
								tE.settCnst(-1);
								tE.settDec(-1);
							}
							if (tE.isM_tCnst() && tE.gettCnst() != 1)
								tE.settCnst(0);
						}
					}
				}
			}
//			value.remove(value.size()-1);
		}
		return tE_temp;
	}
//	// 得到初始等价类tE表_针对迭代member+TE_multitE   //只以tE_temp.member
//	public tEtempCollection generateInitial_tE_iteration_multitE2(ArrayList<tE> EFFtE_List,int attribute,int[] B){
//		tEtempCollection tE_temp=new tEtempCollection();			
////		Set<Entry<IntArrayKey,toleranceClass>> memberKeySet=teList.get(0).entrySet();
////		Set<Entry<IntArrayKey,toleranceClass>> TEKeySet=teList.get(1).entrySet();
//		LinkedList<toleranceClass> memberKeySet=new LinkedList<toleranceClass>();
//		LinkedList<toleranceClass> TEKeySet=new LinkedList<toleranceClass>();
//		for(tE tE:EFFtE_List) 
//			for(toleranceClass te:tE.getMember()) 
//				memberKeySet.put(te.getteValue(),te);
//		for(tE tE:EFFtE_List) 
//			for(toleranceClass te:tE.getTE()) 
//				if(!tEmember.containsKey(te.getteValue()))
//					TEKeySet.put(te.getteValue(),te);
//		//int[] attrC=new int[B.length+1];
//		//attrC=B;
//		//attrC[attrC.length-1]=attribute;
//		for (toleranceClass te: memberKeySet) {      //只添加member作为tE
//			//toleranceClass te=entry.getValue();
//			HashMap<Integer,Integer> value=new HashMap<>();
//			boolean flag=false;
//			int[] valueCollection=new int[B.length];
//			if (B!=null)
//				for(int i=0;i<B.length;i++) {
//					int a=B[i];
//					value.put(a, te.getAttributeValue(a));
//					valueCollection[i]=te.getAttributeValue(a);
//					if(te.getAttributeValue(a)==-1)
//						flag=true;
//				}
//			IntArrayKey hashkey=new IntArrayKey(valueCollection);
//			hashkey.addKey(te.getAttributeValue(attribute));
//			//IntArrayKey attrvalue=new IntArrayKey(te.getAttributeValue(attribute));
//			if(te.getAttributeValue(attribute)==-1)
//				flag=true;
//			if (!flag) {   //Complete
//				if (tE_temp.getComplete().containsKey(hashkey)) {  //tE_temp.get(0).containsKey(attrValue+te.getValue().get(attribute))
//					tE tE=tE_temp.getComplete().get(hashkey);
//					if (te.gettCnst()==1) 
//						tE.setM_tCnst(true);
//					tE.setCount(tE.getCount()+te.getCount());
//					tE.settCount(tE.gettCount()+te.getCount());
//					tE.getMember().add(te);
//					if (tE.getDec()==te.getDec()&&tE.getCnst()==1&&te.getCnst()==1) {
//					}else if (tE.getCnst()==-1&&te.getCnst()==-1) {		
//					}else {
//						tE.setCnst(0);
//						tE.setDec(-1);
//						tE.settCnst(-1);
//						tE.settDec(-1);
//					}
//					if(tE.isM_tCnst()&&tE.gettCnst()!=1)
//						tE.settCnst(0);
//				}else {
//					HashMap<Integer,Integer> valuenew=new HashMap<Integer,Integer>(value);
//					valuenew.put(attribute, te.getAttributeValue(attribute));
//					LinkedList<toleranceClass> member=new LinkedList<toleranceClass>();
//					LinkedList<toleranceClass> TE=new LinkedList<toleranceClass>();
//					member.add(te);
//					tE tE=new tE(valuenew,member,te.getCount(),te.getCnst(),te.getDec(),te.istetCnst(),TE,te.getCount(),te.getDec(),te.getCnst());  //新建
//					tE_temp.getComplete().put(hashkey, tE);
//				}
//			}else {    //Incomplete
//				if (tE_temp.getIncomplete().containsKey(hashkey)) {  //tE_temp.get(0).containsKey(attrValue+te.getValue().get(attribute))
//					tE tE=tE_temp.getIncomplete().get(hashkey);
//					if (te.gettCnst()==1) 
//						tE.setM_tCnst(true);
//					tE.setCount(tE.getCount()+te.getCount());
//					tE.settCount(tE.gettCount()+te.getCount());
//					//tE.settCnst(tE.getCount());
//					tE.getMember().add(te);
//					if (tE.getDec()==te.getDec()&&tE.getCnst()==1&&te.getCnst()==1) {
//					}else if (tE.getCnst()==-1&&te.getCnst()==-1) {		
//					}else {
//						tE.setCnst(0);
//						tE.setDec(-1);
//						tE.settCnst(-1);
//						tE.settDec(-1);
//					}
//					if(tE.isM_tCnst()&&tE.gettCnst()!=1)
//						tE.settCnst(0);
//				}else {
//					HashMap<Integer,Integer> valuenew=value;
//					valuenew.put(attribute, te.getAttributeValue(attribute));
//					LinkedList<toleranceClass> member=new LinkedList<toleranceClass>();
//					LinkedList<toleranceClass> TE=new LinkedList<toleranceClass>();
//					member.add(te);
//					tE tE=new tE(valuenew,member,te.getCount(),te.getCnst(),te.getDec(),te.istetCnst(),TE,te.getCount(),te.getDec(),te.getCnst());  //新建
//					tE_temp.getIncomplete().put(hashkey, tE);
//				}
//			}
//		}
//		for (toleranceClass te: TEKeySet) {  //将TE中的te直接添加到tE.TE中
//			HashMap<Integer,Integer> value=new HashMap<>();
//			HashMap<Integer,Integer> valueTest=new HashMap<>();	
//			if (B!=null)
//				for(int a:B) {
//					value.put(Integer.valueOf(a), te.getAttributeValue(a));
//					}
//			valueTest.putAll(value);
//			valueTest.put(Integer.valueOf(attribute),Integer.valueOf(te.getAttributeValue(attribute)));
//			//attrValue+=te.getValue().get(attribute)+",";
//			if(tE_temp.getComplete().size()!=0) {
//				Set<Entry<IntArrayKey,tE>> keyset=tE_temp.getComplete().entrySet();
//				for(Entry<IntArrayKey,tE> entry2:keyset) {
//					tE tE=entry2.getValue();
//					if(tE.tolerateEqual(valueTest)) {
//						tE.getTE().add(te);
//						tE.settCount(tE.gettCount()+te.getCount());
//						if (tE.getDec()==te.getDec()&&tE.getCnst()==1&&te.getCnst()==1) {
//						}else if (tE.getCnst()==-1&&te.getCnst()==-1) {		
//						}else {
//							tE.settCnst(-1);
//							tE.settDec(-1);
//						}
//						if(tE.isM_tCnst()&&tE.gettCnst()!=1)
//							tE.settCnst(0);
//					}
//				}
//			}
//			if(tE_temp.getIncomplete().size()!=0) {
//				Set<Entry<IntArrayKey,tE>> keyset=tE_temp.getIncomplete().entrySet();
//				for(Entry<IntArrayKey,tE> entry2:keyset) {
//					tE tE=entry2.getValue();
//					if(tE.tolerateEqual(valueTest)) {
//						tE.getTE().add(te);
//						tE.settCount(tE.gettCount()+te.getCount());
//						if (tE.getDec()==te.getDec()&&tE.getCnst()==1&&te.getCnst()==1) {
//						}else if (tE.getCnst()==-1&&te.getCnst()==-1) {		
//						}else {
//							tE.settCnst(-1);
//							tE.settDec(-1);
//						}
//						if(tE.isM_tCnst()&&tE.gettCnst()!=1)
//							tE.settCnst(0);
//					}
//				}
//			}
//		}
//		return tE_temp;   
//
//	}
	// 在tE表中添加TE_针对迭代member+TE //只以tE_temp.member
//		public ArrayList<HashMap<String,tE>> addTE_tE_iteration(ArrayList<HashMap<String,tE>> tE_temp,ArrayList<HashMap<String,toleranceClass>> teList){
//			Set<String> TEKeySet=tE_temp.get(1).keySet();
//			Set<String> memberKeySet=tE_temp.get(0).keySet();
//			tE tE=tE_temp.get(0).get("*");   //Incomplete
//			//this.outPuttE_temp(tE_temp);
//			if (tE!=null) {
//				//Set<String> CompleteSet=tE_temp.get(0).keySet();
//				for (String key:memberKeySet) {
//					tE tE1=tE_temp.get(0).get(key);  //Complete
//				//	System.out.print(tE.getMember()==null);
//					tE1.addTE(tE.getMember());
//					tE.addTE(tE1.getMember());
//					tE.addtCount(tE1.getCount());
//					tE1.addtCount(tE.getCount());
//					if (tE1.gettDec().equals(tE.getDec())&&tE1.getCnst()==1&&tE.getCnst()==1) {
//					}else if(tE1.gettCnst()==-1&&tE.getCnst()==-1){
//					}else {
//						tE1.settDec("/");
//						tE.settDec("/");
//						tE.settCnst(-1);
//						tE1.settCnst(-1);
//					}
//					if(tE1.isM_tCnst()&&tE1.gettCnst()!=1)
//						tE1.settCnst(0);
//					tE_temp.get(0).replace(key, tE1);
//				}
//				if(tE.isM_tCnst()&&tE.gettCnst()!=1)
//					tE.settCnst(0);
//				tE_temp.get(0).replace("*",tE);
//			}			
//			for (String Key1 : TEKeySet) {
//				tE tE1=tE_temp.get(1).get(Key1);
//				for(String Key2: memberKeySet){
//					tE tE2=tE_temp.get(0).get(Key2);
//					if (tolerateEqual(tE1.getValue(),tE1.getValue())){  //除*之外值都相同
//						tE2.addTE(tE1.getMember());
//						tE2.addtCount(tE1.getCount());
//						if (tE1.gettDec().equals(tE2.getDec())&&tE1.gettCnst()==1&&tE2.getCnst()==1) {
//						}else if(tE1.gettCnst()==-1&&tE2.getCnst()==-1) {
//						}else {
//							tE2.settDec("/");
//							tE2.settCnst(-1);
//						}
//					}
//					if(tE2.isM_tCnst()&&tE2.gettCnst()!=1)
//						tE2.settCnst(0);
//					tE_temp.get(0).replace(Key2, tE2);
//				}
//				tE tE3=tE_temp.get(1).get("*");
//				tE3.addTE(tE1.getMember());
//				tE3.addtCount(tE1.getCount());
//				if (tE1.gettDec().equals(tE3.getDec())&&tE1.gettCnst()==1&&tE3.getCnst()==1) {
//				}else if(tE1.gettCnst()==-1&&tE3.getCnst()==-1) {
//				}else {
//					tE3.settDec("/");
//					tE3.settCnst(-1);
//				}
//				if(tE3.isM_tCnst()&&tE3.gettCnst()!=1)
//					tE3.settCnst(0);
//				tE_temp.get(0).replace("*", tE3);
//			}
//			return tE_temp;
//		}

	// 8 划分有效表与无效表
	public tEListCollection divideEffectiveList(tEtempCollection tE_temp, tEListCollection tEList, int[] B, int a) {
		// tEListCollection newtEList=new tEListCollection(new
		// LinkedHashMap<String,ArrayList<tE>>(),new
		// LinkedHashMap<String,ArrayList<tE>>());
//		Collection<tE> IncompleteSet=tE_temp.getIncomplete().values();
//		Collection<tE> CompleteSet=tE_temp.getComplete().values();
		Iterator<tE> completetE = tE_temp.getComplete().values().iterator();
		Iterator<tE> IncompletetE = tE_temp.getIncomplete().values().iterator();
		ArrayList<tE> EfftE = new ArrayList<>(tE_temp.getComplete().size() + tE_temp.getIncomplete().size());
		ArrayList<tE> InefftE = new ArrayList<>(tE_temp.getComplete().size() + tE_temp.getIncomplete().size());
		int[] Bnew = B.clone();
		IntArrayKey attributekey = new IntArrayKey(Bnew);
		IntArrayKey Bkey = new IntArrayKey(Bnew);
		if (a != -1) {
			attributekey.addKey(a);
		}
		while (completetE.hasNext()) { // Complete
			tE tE = completetE.next();
			if (tE.isM_tCnst() && tE.gettCnst() == 0)
				EfftE.add(tE);
			else
				InefftE.add(tE);
		}
		while (IncompletetE.hasNext()) { // Complete
			tE tE = IncompletetE.next();
			if (tE.isM_tCnst() && tE.gettCnst() == 0)
				EfftE.add(tE);
			else
				InefftE.add(tE);
		}
		// System.out.print(EfftE.size());
		if (EfftE.size() != 0) // 要修改为null吗？20220810
			tEList.getEffective().put(attributekey, EfftE);
		if (InefftE.size() != 0) // 要修改为null吗？20220810
			tEList.getIneffective().put(attributekey, InefftE);
		if (B.length != 0 && a != -1) { // 将Effective中的要删除的tcnst=0的tE添加回Ineffective对应项中（为后续添加和删除操作简便计算）
			ArrayList<tE> list = new ArrayList<>();
			list.addAll(tEList.getEffective().get(Bkey));
//			tEList.getIneffective().remove(Bkey);
//			tEList.getIneffective().put(Bkey, list);
			if (tEList.getIneffective().containsKey(Bkey)) {
				list.addAll(tEList.getIneffective().get(Bkey));
				tEList.getIneffective().replace(Bkey, list);
			} else {
				tEList.getIneffective().put(Bkey, list);
			}
			tEList.getEffective().remove(Bkey);
		}
		// tEList.clear();
		return tEList;
	}

	// 根据tEList记录TNECSize
	public TNECSizeCount countTNECSize(tEListCollection tEList) {
		int zero_size = 0, one_size = 0, minusone_size = 0; // 0 1 -1
		if (!tEList.getEffective().isEmpty())
			for (ArrayList<tE> effectEntry : tEList.getEffective().values())
				for (int i = 0; i < effectEntry.size(); i++)
					zero_size += effectEntry.get(i).countAllSample();
		if (!tEList.getIneffective().isEmpty())
			for (ArrayList<tE> IneffectEntry : tEList.getIneffective().values())
				for (int i = 0; i < IneffectEntry.size(); i++) {
					if (IneffectEntry.get(i).gettCnst() == 1) {
						one_size += IneffectEntry.get(i).countAllSample();
					} else if (IneffectEntry.get(i).gettCnst() == -1)
						minusone_size += IneffectEntry.get(i).countAllSample();
				}
		TNECSizeCount TNEC = new TNECSizeCount(zero_size, one_size, minusone_size);
		return TNEC;
	}

	public TNECSizeCount countTNECSizeoftE(tEListCollection tEList) {
		int zero_size = 0, one_size = 0, minusone_size = 0; // 0 1 -1
		if (!tEList.getEffective().isEmpty())
			for (ArrayList<tE> effectEntry : tEList.getEffective().values())
				for (int i = 0; i < effectEntry.size(); i++)
					zero_size += effectEntry.get(i).getMember().size();
		if (!tEList.getIneffective().isEmpty())
			for (ArrayList<tE> IneffectEntry : tEList.getIneffective().values())
				for (int i = 0; i < IneffectEntry.size(); i++) {
					if (IneffectEntry.get(i).gettCnst() == 1) {
						one_size += IneffectEntry.get(i).getMember().size();
					} else if (IneffectEntry.get(i).gettCnst() == -1)
						minusone_size += IneffectEntry.get(i).getMember().size();
				}
		TNECSizeCount TNEC = new TNECSizeCount(zero_size, one_size, minusone_size);
		return TNEC;
	}

	// 9 属性重要度计算（非冗余计算）
	public Significance significance(tEtempCollection tE_temp, int[] B, int a, int frontPos) {
		Significance sig = new Significance(a, B);
		// sig.significance(tE_temp, fronttCount);
		sig.POS(tE_temp, frontPos);
		return sig;
	}

	public Significance significance(ArrayList<tE> tE_temp, int[] B, int a, int frontPos) {
		Significance sig = new Significance(a, B);
		// sig.significance(tE_temp, fronttCount);
		sig.POS(tE_temp, frontPos);
		return sig;
	}

	// 10 冗余检验 根据Reduce-{a}来构建tE_temp
	public boolean redundancy(teCollection Initial_te, List<Integer> Reduce, int a) {
		int[] B = new int[Reduce.size() - 1];
		tEtempCollection tE_temp = new tEtempCollection(
				Initial_te.getComplete().size() + Initial_te.getIncomplete().size());
		int num = 0;
		for (Integer b : Reduce)
			if (b.intValue() != a)
				B[num++] = b;
		// System.out.println();
		// 根据Reduce-{a}来构建tE_temp（未含TE）
		tE_temp = this.generateInitial_tE_multi(Initial_te, B);
		tE_temp = this.addTE_tE_multi(tE_temp);
		Set<Entry<IntArrayKey, tE>> IncompleteSet = tE_temp.getIncomplete().entrySet();
		Set<Entry<IntArrayKey, tE>> CompleteSet = tE_temp.getComplete().entrySet();
		for (Entry<IntArrayKey, tE> entry1 : CompleteSet) { // Complete
			tE tE = entry1.getValue();
			if (tE.gettCnst() == 0)
				return false;
		}
		for (Entry<IntArrayKey, tE> entry2 : IncompleteSet) { // Incomplete
			tE tE = entry2.getValue();
			if (tE.gettCnst() == 0)
				return false;
		}
		return true;
	}
	// 删除冗余属性
//	public List<Integer> deleteRedundancy(teCollection Initial_te,List<Integer> Reduce){
//		for(int i=0;i<Reduce.size();i++) {  //删除冗余属性
//			int a=Reduce.get(i);
//			boolean redundancy=this.redundancy(Initial_te, Reduce, a);
//			if(redundancy)
//				Reduce.remove(i);
//		}
//		return Reduce;
//	}		
	// 约简迭代过程
//	public tEListCollection ReduceIteration(tEListCollection tEList,List<Integer> Reduce,IntArrayKey Reducekey,List<Integer> remainC) {
//		//start=System.currentTimeMillis();
//		//tEListCollection tEList=new tEListCollection();
//		int j=0;
//		Significance maxSig=new Significance();
//		int max_a=-1; 
//		tEtempCollection max_tE_temp=new tEtempCollection(); 
//		tEtempCollection tE_temp=new tEtempCollection();
//		while(tEList.getEffective().size()!=0 && remainC.size()!=0) {  //Effective
//			maxSig=new Significance();
//			int[] ReduceInt = Reduce.stream().mapToInt(Integer::valueOf).toArray();
//			IntArrayKey ReduceKey=new IntArrayKey(ReduceInt);
//			for(int k=0;k<remainC.size();k++) {									
//				float count=0;
//				int a=remainC.get(k).intValue();
//				ArrayList<HashMap<IntArrayKey,toleranceClass>> teList=this.generateInitial_te_tEMember_bymultitE(tEList.getEffective().get(Reducekey));
//				tE_temp=this.generateInitial_tE_iteration_multitE(teList,a,ReduceInt);
//				tE_temp=this.addTE_tE_multi(tE_temp);
//				for (tE tEcount:tEList.getEffective().get(ReduceKey))
//					count+=tEcount.gettCount();				
//				//this.outPuttE_temp(tE_temp);
//				Significance a_sig=this.significance(tE_temp, ReduceInt, a, count);
//				//System.out.println("确认度："+a_sig.getCertainlyValue()+"不确认度："+a_sig.getUncertainlyValue());
//				if(a_sig.getPOS()>maxSig.getPOS()) {
//					max_a=a;
//					max_tE_temp=tE_temp;
//					maxSig=a_sig;
//					j=k;			
//				}
//				//System.out.println("迭代："+a);
//				//this.outPuttE_temp(tE_temp);
//			}
//			//System.out.println("最优："+max_a);
//			//this.outPuttE_temp(max_tE_temp);
//			//System.out.println(Reduce);
//			tEList=this.divideEffectiveList(max_tE_temp, tEList, ReduceInt, max_a);
//			Reduce.add(max_a);
//			ReduceKey.addKey(max_a);
//			remainC.remove(j);		
//		}
//		//end=System.currentTimeMillis();
//		//System.out.print("第3步："+(end-start)+"ms,"+(double)(end-start)/1000+"s");
//		return tEList;
//	}

	// 根据tE生成tE.member+TE的初始等价类te表
	public ArrayList<HashMap<IntArrayKey, toleranceClass>> generateInitial_te_tEMember(tE tE) {
		ArrayList<HashMap<IntArrayKey, toleranceClass>> teList = new ArrayList<HashMap<IntArrayKey, toleranceClass>>();
		HashMap<IntArrayKey, toleranceClass> tEmember = new HashMap<>(tE.getMember().size());
		HashMap<IntArrayKey, toleranceClass> tE_TE = new HashMap<>(tE.getTE().size());
		for (toleranceClass te : tE.getMember()) {
			tEmember.put(te.getteValue(), te);
		}
		for (toleranceClass te : tE.getTE()) {
			tE_TE.put(te.getteValue(), te);
		}
		teList.add(tEmember);
		teList.add(tE_TE);
		return teList;
	}

	// 根据多个tE=0生成tE.member+TE的初始等价类te表
	public ArrayList<HashMap<IntArrayKey, toleranceClass>> generateInitial_te_tEMember_bymultitE(
			ArrayList<tE> EFFtE_List, int size) {
		ArrayList<HashMap<IntArrayKey, toleranceClass>> teList = new ArrayList<HashMap<IntArrayKey, toleranceClass>>();
		HashMap<IntArrayKey, toleranceClass> tEmember = new HashMap<>(size);
		HashMap<IntArrayKey, toleranceClass> tE_TE = new HashMap<>(size);
		// System.out.print(EFFtE_List);
		for (tE tE : EFFtE_List)
			for (toleranceClass te : tE.getMember())
				tEmember.put(te.getteValue(), te);
		for (tE tE : EFFtE_List)
			for (toleranceClass te : tE.getTE())
				if (!tEmember.containsKey(te.getteValue()))
					tE_TE.put(te.getteValue(), te);
		teList.add(tEmember);
		teList.add(tE_TE);
		return teList;
	}

	// 11 约简
	public StaticReduceResult INECReduce(Collection<Sample> U, int[] CName) {
		System.out.println("||静态约简开始");
		List<Integer> Reduce = new ArrayList<>(CName.length);
		// StringBuilder ReduceString=new StringBuilder();
		IntArrayKey ReduceKey = new IntArrayKey();
		tEListCollection tEList = new tEListCollection();
		teCollection Initial_te = new teCollection();
		List<Integer> remainC = Arrays.stream(CName).boxed().collect(Collectors.toList());
		LinkedHashMap<String, Long> times = new LinkedHashMap<>(10);
		LinkedHashMap<Integer, Integer> posattr = new LinkedHashMap<>(CName.length);
		LinkedList<TNECSizeCount> TNECsize = new LinkedList<>();

		long start = System.currentTimeMillis();
		Initial_te = this.generateInitialEquivalenceClasses_te(U);
		long end = System.currentTimeMillis();
		System.out.println("||生成te表(无朋友)：" + (end - start) + "ms," + (double) (end - start) / 1000 + "s");
		times.put("crate_telist(noTE)", end - start);

		start = System.currentTimeMillis();
		Initial_te = this.addTE_te(Initial_te);
		end = System.currentTimeMillis();
		int CPos = 0;
		for (toleranceClass te : Initial_te.getComplete().values())
			if (te.gettCnst() == 1)
				CPos += 1;
		for (toleranceClass te : Initial_te.getIncomplete().values())
			if (te.gettCnst() == 1)
				CPos += 1;
		System.out.println(
				"||生成完整te表&CPos=" + CPos + ",时间：" + (end - start) + "ms," + (double) (end - start) / 1000 + "s");
		times.put("create_telist", end - start);

		// this.Initial_te=Initial_te;
		// this.outPutInitial_te(Initial_te);
		Significance maxSig = new Significance();
		int max_a = -1;
		tEtempCollection max_tE_temp = new tEtempCollection(U.size());
		tEtempCollection tE_temp;
		int maxj = -1;

		start = System.currentTimeMillis();
		for (int i = 0; i < CName.length; i++) {
			int a = CName[i];
			tE_temp = this.generateInitial_tE_single(Initial_te, a);
			tE_temp = this.addTE_tE_single(tE_temp);
			Significance a_sig = this.significance(tE_temp, null, a, 0);
			if (a_sig.getPOS() > maxSig.getPOS()) {
				max_a = a;
				max_tE_temp = tE_temp;
				maxSig = a_sig;
				maxj = i;
			}
			// System.out.println("迭代："+a);
			// this.outPuttE_temp(tE_temp);
		}
		// System.out.println("最优："+max_a);
		// this.outPuttE_temp(max_tE_temp);
		Reduce.add(max_a);
		ReduceKey.addKey(max_a);
		posattr.put(max_a, maxSig.getPOS());
		tEList = this.divideEffectiveList(max_tE_temp, tEList, new int[0], max_a);
		TNECsize.add(this.countTNECSize(tEList));
		TNECsize.add(new TNECSizeCount(U.size(), 0, 0));
		remainC.remove(Integer.valueOf(maxj));
		end = System.currentTimeMillis();
		System.out.println("||最优特征{" + max_a + "}&POS=" + maxSig.getPOS() + "&划分初始tE表,时间:" + (end - start) + "ms,"
				+ (double) (end - start) / 1000 + "s");
		times.put("divide_originaltEList", end - start);

		// start=System.currentTimeMillis();
		maxj = 0;
		// maxSig=new Significance();
		max_a = -1;
		max_tE_temp = new tEtempCollection();
		tE_temp = new tEtempCollection();

		start = System.currentTimeMillis();
		while (tEList.getEffective().size() != 0 && remainC.size() != 0) { // Effective
			int count = maxSig.getPOS();
			maxSig = new Significance();
			// int[] ReduceInt = Reduce.stream().mapToInt(Integer::valueOf).toArray();
			ArrayList<HashMap<IntArrayKey, toleranceClass>> teList = this
					.generateInitial_te_tEMember_bymultitE(tEList.getEffective().get(ReduceKey), Initial_te.size());
			for (int k = 0; k < remainC.size(); k++) {
				// float count=0;
				int a = remainC.get(k);
				tE_temp = this.generateInitial_tE_iteration_multitE(teList, a, ReduceKey.key());
				tE_temp = this.addTE_tE_multi(tE_temp);
//				for (tE tEcount:tEList.getEffective().get(ReduceKey))
//					count+=tEcount.gettCount();				
				// this.outPuttE_temp(tE_temp);
				Significance a_sig = this.significance(tE_temp, ReduceKey.key(), a, count);
				if (a_sig.getPOS() > maxSig.getPOS()) {
					max_a = a;
					max_tE_temp = tE_temp;
					maxSig = a_sig;
					maxj = k;
				}
				// System.out.println("迭代："+a+"POS:"+a_sig.getPOS());
				// this.outPuttE_temp(tE_temp);
			}
			// System.out.println("最优："+max_a+" POS:"+maxSig.getPOS());
			// this.outPuttE_temp(max_tE_temp);
			tEList = this.divideEffectiveList(max_tE_temp, tEList, ReduceKey.key(), max_a);
			TNECsize.add(this.countTNECSize(tEList));
			Reduce.add(max_a);
			ReduceKey.addKey(max_a);
			posattr.put(max_a, maxSig.getPOS());
			remainC.remove(maxj);
			// System.out.println(Reduce);
			System.out.println("||最优特征{" + max_a + "}&POS=" + maxSig.getPOS());
		}
		// this.outPuttE_temp(max_tE_temp);
		end = System.currentTimeMillis();
		// System.out.println(Reduce);
		System.out.println(
				"||迭代&Reduce={" + Reduce + "},时间：" + (end - start) + "ms," + (double) (end - start) / 1000 + "s");
		times.put("iteration", end - start);

//		start=System.currentTimeMillis();
//		System.out.println("||冗余检验开始");
//		for(int i=0;i<Reduce.size();i++) {  //删除冗余属性
//			int a=Reduce.get(i);
//			boolean redundancy=this.redundancy(Initial_te, Reduce, a);
//			if(redundancy) {
//				Reduce.remove(i);
//				//System.out.print("删除属性："+a);
//				System.out.println("||删除特征{"+a+"}");
//				i--;
//				Set<IntArrayKey> keySet=tEList.getIneffective().keySet();
//				//20220803修改
//				List<IntArrayKey> toBRemoved=new LinkedList<>();
//				for (IntArrayKey key:keySet)
//					if(key.contains(a))
//						toBRemoved.add(key);
//				for(IntArrayKey k:toBRemoved)
//					tEList.getIneffective().remove(k);
//			}
//		}
//		end=System.currentTimeMillis();
//		System.out.println("||冗余检验结束："+(end-start)+"ms,"+(double)(end-start)/1000+"s");
//		times.put("redundancy",end-start);
		long alltime = 0;
		for (long i : times.values())
			alltime += i;
		System.out.println("||最终约简Reduce={" + Reduce + "},约简数量=" + Reduce.size());
		System.out.println("||总时间：" + alltime + "ms," + (double) (alltime) / 1000 + "s");

		StaticReduceResult result = new StaticReduceResult(Initial_te, tEList, Reduce, times, posattr, TNECsize);
		return result;
	}

	// Sample增删
	// 13 tE_temp表合并(基于相同B的条件下)
//	public ArrayList<HashMap<String,tE>> combine_tE(ArrayList<HashMap<String,tE>> tE_temp1,ArrayList<HashMap<String,tE>> tE_temp2) {
//			ArrayList<HashMap<String,tE>> tE_temp=new ArrayList<HashMap<String,tE>>();
//			HashMap<String,tE> Complete=new HashMap<>();
//			HashMap<String,tE> Incomplete=new HashMap<>();
//			ArrayList<HashMap<String,tE>> max_tE_temp=new ArrayList<HashMap<String,tE>>();
//			ArrayList<HashMap<String,tE>> min_tE_temp=new ArrayList<HashMap<String,tE>>();
//			int size1=tE_temp1.get(0).size()+tE_temp1.get(1).size();
//			int size2=tE_temp2.get(0).size()+tE_temp2.get(1).size();
//			if(size1>=size2) {
//				max_tE_temp=tE_temp1;
//				min_tE_temp=tE_temp2;
//			}else {
//				max_tE_temp=tE_temp2;
//				min_tE_temp=tE_temp1;
//			}
//			Set<String> IncompleteSet=min_tE_temp.get(1).keySet();
//			Set<String> CompleteSet=min_tE_temp.get(0).keySet();
//			if(min_tE_temp.get(0).size()!=0)
//			for (String key:CompleteSet) {
//				tE tE1=min_tE_temp.get(0).get(key);
//				if(max_tE_temp.get(0).containsKey(key)) {
//					tE tE2=max_tE_temp.get(0).get(key);
//					tE2.addMember(tE1.getMember());
//					tE2.addCount(tE1.getCount());
//					tE2.addNotContaintE(tE1.getTE());
//					tE2.addtCount(tE1.gettCount());
//					if(tE2.getCnst()==tE1.getCnst()&&tE2.getDec().equals(tE1.getDec())) {
//					}else {	
//						tE2.setCnst(0);
//						tE2.setDec("/");
//					}
//					if(tE2.isM_tCnst()||tE1.isM_tCnst()) {
//						tE2.setM_tCnst(true);
//					}else tE2.setM_tCnst(false);
//					if(!tE2.gettDec().equals(tE1.gettDec()))
//						tE2.settDec("/");
//					if (tE2.gettCnst()==tE1.gettCnst()&&tE2.getDec().equals(tE1.gettDec())) {
//					}else {
//						tE2.settCnst(-1);
//						tE2.settDec("/");
//					}
//					if(tE2.isM_tCnst()&&tE2.gettCnst()!=1) 
//						tE2.settCnst(0);
////					Complete.put(key, tE2);
//				}else {//不含key
//					//tE tE2=min_tE_temp.get(0).get(key);
//					max_tE_temp.get(0).put(key, tE1);
//				}
//			}
//			if(min_tE_temp.get(1).size()!=0)
//			for(String key:IncompleteSet) {
//				tE tE1=min_tE_temp.get(1).get(key);
//				if(max_tE_temp.get(1).containsKey(key)) {
//					tE tE2=max_tE_temp.get(1).get(key);
//					tE2.addMember(tE1.getMember());
//					tE2.addCount(tE1.getCount());
//					tE2.addNotContaintE(tE1.getTE());
//					tE2.addtCount(tE1.gettCount());
//					if(tE2.getCnst()==tE1.getCnst()&&tE2.getDec().equals(tE1.getDec())) {
//					}else {					
//						tE2.setCnst(0);
//						tE2.setDec("/");
//					}
//					if(tE2.isM_tCnst()||tE1.isM_tCnst()) {
//						tE2.setM_tCnst(true);
//					}else tE2.setM_tCnst(false);
//					if(!tE2.gettDec().equals(tE1.gettDec()))
//						tE2.settDec("/");
//					if (tE2.gettCnst()==tE1.gettCnst()&&tE2.getDec().equals(tE1.gettDec())) {
//					}else {
//						tE2.settCnst(-1);
//						tE2.settDec("/");
//					}
//					if(tE2.isM_tCnst()&&tE2.gettCnst()!=1) 
//						tE2.settCnst(0);
//				//	Incomplete.put(key, tE2);
//				}else {//不含key
//					//tE tE2=min_tE_temp.get(1).get(key);
//					max_tE_temp.get(0).put(key, tE1);
//				}
////				tE_temp.add(Complete);
////				tE_temp.add(Incomplete);
//			}
//			return max_tE_temp;
//		}

//		//14  增加多个Sample得到新的Reduce
//		public ArrayList<String> INECReduce_addSample(ArrayList<Sample> Uad,ArrayList<HashMap<String,toleranceClass>> Initial_te,ArrayList<LinkedHashMap<String,ArrayList<tE>>> tEList,ArrayList<String> Reduce){
//			ArrayList<HashMap<String,toleranceClass>> add_te=new ArrayList<>();
//			ArrayList<HashMap<String,tE>> add_tE_temp=new ArrayList<HashMap<String,tE>>();
//			ArrayList<HashMap<String,tE>> tE_temp=new ArrayList<HashMap<String,tE>>();
//			ArrayList<HashMap<String,tE>> all_tE_temp=new ArrayList<HashMap<String,tE>>();
//			add_te=this.generateInitialEquivalenceClasses_te(Uad);
//			add_te=this.addTE_te(add_te);
//			add_tE_temp=this.generateInitial_tE_multi(add_te, Reduce);
//			add_tE_temp=this.addTE_tE_multi(add_tE_temp);
//			this.outPuttE_temp(add_tE_temp);
//			tE_temp=this.generateInitial_tE_multi(Initial_te, Reduce);
//			tE_temp=this.addTE_tE_multi(tE_temp);
//			this.outPuttE_temp(tE_temp);
//			all_tE_temp=this.combine_tE(tE_temp, add_tE_temp);
//			this.outPuttE_temp(all_tE_temp);
//			Set<String> IncompleteSet=all_tE_temp.get(1).keySet();
//			Set<String> CompleteSet=all_tE_temp.get(0).keySet();
//			LinkedHashMap<String,ArrayList<tE>> Effective=tEList.get(0);
//			LinkedHashMap<String,ArrayList<tE>> Ineffective=tEList.get(1);
//			ArrayList<tE> EfftE=new ArrayList<>();
//			ArrayList<tE> InefftE=new ArrayList<>();
//			String ReduceString=this.ReduceArrayListtoString(Reduce);
//			int j=0;
//			for (String key:CompleteSet) {
//				tE tE=all_tE_temp.get(0).get(key);
//				if (tE.isM_tCnst()&&tE.gettCnst()==0)
//					EfftE.add(tE);
//				else InefftE.add(tE);
//			}
//			for (String key:IncompleteSet) {
//				tE tE=all_tE_temp.get(1).get(key);
//				if (tE.isM_tCnst()&&tE.gettCnst()==0)
//					EfftE.add(tE);
//				else InefftE.add(tE);
//			}
//			
//			Effective.put(ReduceString, EfftE);
//			Ineffective.put(ReduceString, InefftE);
////			tEList.add(Effective);
////			tEList.add(Ineffective);
//			if(tEList.get(0).size()==0) {
//				return Reduce;
//			}else {
//				Significance maxSig=new Significance();
//				String max_a=null;
//				ArrayList<HashMap<String,tE>> max_tE_temp=new ArrayList<>();
//				//tE max_tE=new tE();		
//				ArrayList<String> remainC=new ArrayList<>();
//				//remainC.addAll(this.getCName());
//				for(String a:this.getCName())
//					if(!Reduce.contains(a))
//						remainC.add(a);
//				System.out.print(remainC);
//				while(tEList.get(0)!=null && remainC.size()!=0) {
//					maxSig=new Significance();
//					for(int k=0;k<remainC.size();k++) {					
//						float count=0;
//						String a=remainC.get(k);
//						ArrayList<HashMap<String,toleranceClass>> teList=this.generateInitial_te_tEMember_bymultitE(tEList.get(0).get(ReduceString));
//						tE_temp=this.generateInitial_tE_iteration_multitE(teList,a,Reduce);
//						tE_temp=this.addTE_tE_multi(tE_temp);
//						for (tE tEcount:tEList.get(0).get(ReduceString))
//							count+=tEcount.gettCount();
//						Significance a_sig=this.significance(tE_temp, Reduce, a, count);
//						System.out.println("确认度："+a_sig.getCertainlyValue()+"不确认度："+a_sig.getUncertainlyValue());
//						//if (a_sig.getCertainlyValue()>maxSig.getCertainlyValue()) {  //暂时用确定性衡量
//						if(a_sig.getUncertainlyValue()<=maxSig.getUncertainlyValue()) {
//							if(a_sig.getUncertainlyValue()==maxSig.getUncertainlyValue()&&a_sig.getCertainlyValue()>=maxSig.getCertainlyValue()) {
//								max_a=a;
//								max_tE_temp=tE_temp;
//								maxSig=a_sig;
//								j=k;
//							}else if(a_sig.getUncertainlyValue()<maxSig.getUncertainlyValue()) {
//								max_a=a;
//								max_tE_temp=tE_temp;
//								maxSig=a_sig;
//								j=k;
//							}			
//						}
//						System.out.println("迭代："+a);
//						this.outPuttE_temp(tE_temp);
//					}
//					System.out.println("最优："+max_a);
//					this.outPuttE_temp(max_tE_temp);
//					tEList=this.divideEffectiveList(max_tE_temp, tEList, Reduce, max_a);
//					Reduce.add(max_a);
//					ReduceString+=max_a+",";
//					remainC.remove(j);
//				}
//				for(int i=0;i<Reduce.size();i++) {  //删除冗余属性
//					String a=Reduce.get(i);
//					boolean redundancy=this.redundancy(Initial_te, Reduce, a);
//					if(redundancy)
//						Reduce.remove(i);
//				}
//			}
//			return Reduce;
//		}

	// 15 增加多个Sample更新te表
	public teListUpdateResult update_add_te(Collection<Sample> Uad, teCollection Initial_te) {
		HashMap<IntArrayKey, toleranceClass> add_te = new HashMap<IntArrayKey, toleranceClass>(Uad.size());
		teCollection update_te = Initial_te;
		// update_te.addnewAll(Initial_te);
		for (Sample x : Uad) {
			// boolean flag=x.isIs_Incomplete();
			HashMap<IntArrayKey, toleranceClass> hash;
			if (!x.isIs_Incomplete()) {// X中不包含*
				hash = update_te.getComplete();
			} else { // x中包含*
				hash = update_te.getIncomplete();
			}
			IntArrayKey hashKey = new IntArrayKey(x.getConditionValues());
			if (hash.containsKey(hashKey)) {
				toleranceClass te = hash.get(hashKey);
				te.getMember().add(x);
				te.setCount(te.getCount() + 1);
				if (te.getDec() != x.getDecisionValues()) {// te的状态改变
					te.setCnst(-1);
					te.setDec(-1);
					te.settCnst(-1);
					for (int i = 0; i < te.getTE().size(); i++) {
						toleranceClass te1 = te.getTE().get(i);
						te1.settDec(-1);
						te1.settCnst(-1);
					}
				}
			} else { // 不存在te.value==x.c
				toleranceClass te = new toleranceClass(hashKey.key(), x, 1, 1, x.getDecisionValues(),
						new LinkedList<toleranceClass>(), x.getDecisionValues(), 1); // 新建，默认tnst=tCnst=1
				hash.put(te.getteValue(), te);
				add_te.put(te.getteValue(), te);
				update_te.addnewFriend(te, true);
				update_te.addnewFriend(te, false);
			}
		}
		teListUpdateResult result = new teListUpdateResult(add_te, update_te);
		// this.outPutInitial_te(result.getUpdate_te());
		return result;
	}

	// 16 从更新后的te表更新tE表（新增）
	public tEListCollection update_add_tE(teListUpdateResult update_teResult, tEListCollection tEList,
			List<Integer> Reduce) {
		tEtempCollection tE_temp = new tEtempCollection(tEList.size()); // *****
		tEListCollection newtEList = new tEListCollection();
		HashMap<IntArrayKey, toleranceClass> addHash = new HashMap<>(update_teResult.getAdd_te());
		IntArrayKey Redkey = new IntArrayKey();
		for (int k = 0; k < Reduce.size(); k++) { // 这一步中取出的是tEList.Ineff中第一个属性值的
			Redkey.addKey(Reduce.get(k));
			ArrayList<tE> value = tEList.getIneffective().get(Redkey); // 报错问题：当在上一轮约简中删除至只剩n个，下一轮这里在n个属性的条件下，没有满足条件得到新的Effective就会继续选取n+1个属性导致tEList中没有n+1个hash的Key因此为null
			boolean flag = false;
			ArrayList<tE> List = value;
			ArrayList<tE> newList = new ArrayList<>();
			for (int i = 0; i < List.size(); i++) { // ******这里list为空，表示ineffective中不存在Redkey的tEList***20220803
				tE tE = List.get(i);
				tE tE2 = new tE();
				toleranceClass te = new toleranceClass();
				flag = false; // 不含*
				if (tE.gettEValue().contains(-1))
					flag = true;
				// System.out.print(attributes+"第一步："+tE.gettEValue());
				// 1 更新tE中member的各值
				for (toleranceClass tetemp : tE.getMember()) {
					// System.out.print(tE.getMember().size());
					if (tetemp.getteValue().contains(-1))
						te = update_teResult.getUpdate_te().getIncomplete().get(tetemp.getteValue());
					else
						te = update_teResult.getUpdate_te().getComplete().get(tetemp.getteValue());
					if (!tE2.isEmpty()) {
						if (te.gettCnst() == 1)
							tE2.setM_tCnst(true);
						tE2.setCount(tE2.getCount() + te.getCount());
						tE2.settCount(tE2.gettCount() + te.getCount());
						tE2.getMember().add(te);
						if (tE2.getDec() == te.getDec() && tE2.getCnst() == 1 && te.getCnst() == 1) {
						} else if (tE2.getCnst() == -1 && te.getCnst() == -1) {
						} else {
							tE2.setCnst(0);
							tE2.setDec(-1);
							tE2.settCnst(-1);
							tE2.settDec(-1);
						}
						if (tE2.isM_tCnst() && tE2.gettCnst() != 1)
							tE2.settCnst(0);
					} else { // tE2==null
						tE2 = new tE(tE.getValue(), te, te.getCount(), te.getCnst(), te.getDec(), te.istetCnst(),
								new LinkedList<toleranceClass>(), te.getCount(), te.getDec(), te.getCnst()); // 新建
					}
				}

				// System.out.print(attributes+"第一步完成");
				// Set<IntArrayKey> add_teSet=addHash.keySet();
				Set<IntArrayKey> removeTest = new HashSet<>();
				// 2 将新增的te添加到tE.member中
				for (IntArrayKey key : addHash.keySet()) {
					toleranceClass te1 = addHash.get(key);
					IntArrayKey attrKey = new IntArrayKey(te1.getBValue(Redkey.key()));
					// Set<Entry<Integer,Integer>> tE2Value=tE2.getValue().entrySet();
//					for(Integer a:tE2.getValue().keySet())
//						attrKey.addKey(te1.getValue()[a]);   //tE2.getValue()中不含","
					if (attrKey.equals(tE2.gettEValue())) {
						if (te1.gettCnst() == 1)
							tE2.setM_tCnst(true);
						tE2.setCount(tE2.getCount() + te1.getCount());
						tE2.settCount(tE2.gettCount() + te1.getCount());
						tE2.getMember().add(te1);
						if (tE2.getDec() == te1.getDec() && tE2.getCnst() == 1 && te1.getCnst() == 1) {
						} else if (tE2.getCnst() == -1 && te1.getCnst() == -1) {
						} else {
							tE2.setCnst(0);
							tE2.setDec(-1);
							tE2.settCnst(-1);
							tE2.settDec(-1);
						}
						if (tE2.isM_tCnst() && tE2.gettCnst() != 1)
							tE2.settCnst(0);
						removeTest.add(key);
					}
				}
				if (!removeTest.isEmpty())
					for (IntArrayKey key : removeTest)
						addHash.remove(key);
				newList.add(tE2);
				if (flag)
					tE_temp.getIncomplete().put(tE2.gettEValue(), tE2);
				else
					tE_temp.getComplete().put(tE2.gettEValue(), tE2);
			}
			newtEList.getIneffective().put(Redkey, newList);
			// tEList.getIneffective().replace(Redkey,newList);
			// System.out.print(attributes+"第二步完成");
			// 3 将剩余的新增te新建为tE
			if (addHash != null) {
				Set<IntArrayKey> add_teSet = addHash.keySet();
				for (IntArrayKey key : add_teSet) {
					toleranceClass te = addHash.get(key);
					ArrayList<Integer> attr = new ArrayList<Integer>();
					IntArrayKey attrkey = new IntArrayKey();
					for (int a : Redkey.key()) {
						attr.add(te.getValue()[a]);
						attrkey.addKey(te.getValue()[a]);
					}
					// 如果已经存在
					if (tE_temp.getComplete().containsKey(attrkey) || tE_temp.getIncomplete().containsKey(attrkey)) {
						tE newtE = new tE();
						if (tE_temp.getIncomplete().containsKey(attrkey))
							newtE = tE_temp.getIncomplete().get(attrkey);
						else
							newtE = tE_temp.getComplete().get(attrkey);
						if (te.gettCnst() == 1)
							newtE.setM_tCnst(true);
						newtE.setCount(newtE.getCount() + te.getCount());
						newtE.settCount(newtE.gettCount() + te.getCount());
						newtE.getMember().add(te);
						if (newtE.getDec() == te.getDec() && newtE.getCnst() == 1 && te.getCnst() == 1) {
						} else if (newtE.getCnst() == -1 && te.getCnst() == -1) {
						} else {
							newtE.setCnst(0);
							newtE.setDec(-1);
							newtE.settCnst(-1);
							newtE.settDec(-1);
						}
						if (newtE.isM_tCnst() && newtE.gettCnst() != 1)
							newtE.settCnst(0);
					} else { // 不存在
						tE tE2 = new tE(attr, te, te.getCount(), te.getCnst(), te.getDec(), te.istetCnst(),
								new LinkedList<toleranceClass>(), te.getCount(), te.getDec(), te.getCnst()); // 新建
						if (this.containsIncomplete(tE2.getValue()))
							tE_temp.getIncomplete().put(tE2.gettEValue(), tE2);
						else
							tE_temp.getComplete().put(tE2.gettEValue(), tE2);
					}
				}
			}
			// System.out.print(attributes+"第三步完成");
			tE_temp = this.addTE_tE_multi(tE_temp);
			// this.outPuttE_temp(tE_temp);
			// tEList.get(1).remove(attributes);
			newtEList.getIneffective().remove(new IntArrayKey(Redkey.key().clone()));
			newtEList = this.divideEffectiveList(tE_temp, newtEList, new IntArrayKey(Redkey.key().clone()).key(), -1);
			if (newtEList.getEffective().size() != 0) {
				return newtEList;
			} else if (k == newtEList.getIneffective().size() - 1) { // 当newtEList.getEffective().size()==0且Ineffective中的属性更新完毕时返回tEList
				return newtEList;
			}
		}

		return newtEList;
	}

	// 17 新增Sample得到新的Reduce
	public StaticReduceResult INECReduce_addSample_te(Collection<Sample> U, Collection<Sample> Uad, int[] CName,
			StaticReduceResult previousResult) {
		System.out.println("||增量约简开始");
		List<Integer> newReduce = new ArrayList<>();
		// newReduce.addAll(Reduce);
		IntArrayKey ReduceKey = new IntArrayKey();
		tEListCollection tEList;
		LinkedHashMap<String, Long> times = new LinkedHashMap<>(10);
		LinkedHashMap<Integer, Integer> posattr = new LinkedHashMap<>(CName.length);
		LinkedList<TNECSizeCount> TNECsize = new LinkedList<>();

		long start = System.currentTimeMillis();
		teListUpdateResult update_teResult = this.update_add_te(Uad, previousResult.getInitial_te());
		long end = System.currentTimeMillis();
		int CPos = 0;
		for (toleranceClass te : update_teResult.getUpdate_te().getComplete().values())
			if (te.gettCnst() == 1)
				CPos += 1;
		for (toleranceClass te : update_teResult.getUpdate_te().getIncomplete().values())
			if (te.gettCnst() == 1)
				CPos += 1;
		System.out
				.println("||更新te表&CPos=" + CPos + ",时间：" + (end - start) + "ms," + (double) (end - start) / 1000 + "s");
		times.put("update_telist", end - start);
		// this.outPutInitial_te(update_teResult.getUpdate_te());

		start = System.currentTimeMillis();
		// 当在上一轮第一个属性被删除 则重新选择第一个属性生成tEList
		if (previousResult.gettEList().getIneffective().size() == 0) {
			tEtempCollection tE_temp = this.generateInitial_tE_single(update_teResult.getUpdate_te(),
					previousResult.getReduce().get(0));
			tE_temp = this.addTE_tE_single(tE_temp);
			tEList = this.divideEffectiveList(tE_temp, previousResult.gettEList(), new int[0],
					previousResult.getReduce().get(0));
		} else {
			tEList = this.update_add_tE(update_teResult, previousResult.gettEList(), previousResult.getReduce()); // 时间太长
		}
		end = System.currentTimeMillis();
		System.out.println("||更新te表：" + (end - start) + "ms," + (double) (end - start) / 1000 + "s");
		times.put("update_telist", end - start);

		start = System.currentTimeMillis();
		// System.out.println(tEList.get(0).keySet().size());
		Set<IntArrayKey> teEffSet = tEList.getEffective().keySet();
		Set<IntArrayKey> teIneffSet = tEList.getIneffective().keySet();
		if (tEList.getEffective().size() != 0) {
			for (IntArrayKey key : teEffSet) {
				newReduce = Arrays.stream(key.key()).boxed().collect(Collectors.toList());
				ReduceKey = new IntArrayKey(key.key().clone());
			}
		} else {
			for (IntArrayKey key : teIneffSet) {
				if (newReduce.size() < key.key().length || newReduce.isEmpty()) {
					newReduce = Arrays.stream(key.key()).boxed().collect(Collectors.toList());
					ReduceKey = new IntArrayKey(key.key().clone());
				}
			}
		}
		TNECsize.add(this.countTNECSize(tEList));
		end = System.currentTimeMillis();
		System.out.println("||更新tEList&初始约简Reduce={" + newReduce + "},时间：" + (end - start) + "ms,"
				+ (double) (end - start) / 1000 + "s");
		times.put("update_tEList", end - start);

		// List<Integer> remainC=Arrays.stream(CName).filter(a
		// ->!ReduceKey.contains(a)).boxed().collect(Collectors.toList());
		List<Integer> remainC = new LinkedList<Integer>();
		for (int a : CName)
			if (!ReduceKey.contains(a))
				remainC.add(a);
		// System.out.println("remainC:"+remainC+" Reduce:"+newReduce.toString());
		Significance maxSig = this.significance(tEList.getEffective().get(ReduceKey), ReduceKey.key(), 0, 0);
		int max_a = -1;
		tEtempCollection max_tE_temp = new tEtempCollection(U.size() + Uad.size());
		tEtempCollection tE_temp;
		int maxj = 0;

		start = System.currentTimeMillis();
		while (tEList.getEffective().size() != 0 && remainC.size() != 0) { // Effective
			int count = maxSig.getPOS();
			maxSig = new Significance();
			// int[] newReduceInt = newReduce.stream().mapToInt(Integer::valueOf).toArray();
			ArrayList<HashMap<IntArrayKey, toleranceClass>> teList = this.generateInitial_te_tEMember_bymultitE(
					tEList.getEffective().get(ReduceKey), update_teResult.size());
			for (int k = 0; k < remainC.size(); k++) {
				// float count=0;
				int a = remainC.get(k);
				tE_temp = this.generateInitial_tE_iteration_multitE(teList, a, ReduceKey.key());
				tE_temp = this.addTE_tE_multi(tE_temp);
//				for (tE tEcount:tEList.getEffective().get(ReduceKey))
//					count+=tEcount.gettCount();				
				// this.outPuttE_temp(tE_temp);
				Significance a_sig = this.significance(tE_temp, ReduceKey.key(), a, count);
				if (a_sig.getPOS() > maxSig.getPOS()) {
					max_a = a;
					max_tE_temp = tE_temp;
					maxSig = a_sig;
					maxj = k;
				}
				// System.out.println("迭代："+a);
				// this.outPuttE_temp(tE_temp);
			}
			// System.out.println("最优："+max_a+" POS:"+maxSig.getPOS());
			// this.outPuttE_temp(max_tE_temp);
			tEList = this.divideEffectiveList(max_tE_temp, tEList, ReduceKey.key(), max_a);
			TNECsize.add(this.countTNECSize(tEList));
			newReduce.add(max_a);
			ReduceKey.addKey(max_a);
			posattr.put(max_a, maxSig.getPOS());
			remainC.remove(maxj);
			System.out.println("||最优特征{" + max_a + "}&POS=" + maxSig.getPOS());
		}
		// System.out.println(newReduce);
		end = System.currentTimeMillis();
		System.out.println(
				"||迭代&Reduce={" + newReduce + "},时间：" + (end - start) + "ms," + (double) (end - start) / 1000 + "s");
		times.put("iteration", end - start);

//		start=System.currentTimeMillis();
//		System.out.println("||冗余检验开始");
//		for(int i=0;i<newReduce.size();i++) {  //删除冗余属性
//			int a=newReduce.get(i);
//			boolean redundancy=this.redundancy(update_teResult.getUpdate_te(), newReduce, a);
//			if(redundancy) {
//				newReduce.remove(i);
//				//System.out.print("删除属性："+a);
//				System.out.println("||删除特征{"+a+"}");
//				i--;
//				Set<IntArrayKey> keySet=tEList.getIneffective().keySet();
//				//20220803修改
//				List<IntArrayKey> toBRemoved=new LinkedList<>();
//				for (IntArrayKey key:keySet)
//					if(key.contains(a))
//						toBRemoved.add(key);
//				for(IntArrayKey k:toBRemoved)
//					tEList.getIneffective().remove(k);
//			}
//		}
//		end=System.currentTimeMillis();
//		System.out.println("||冗余检验结束："+(end-start)+"ms,"+(double)(end-start)/1000+"s");
//		times.put("redundancy",end-start);
		long alltime = 0;
		for (long i : times.values())
			alltime += i;
		System.out.println("||最终约简Reduce={" + newReduce + "},约简数量=" + newReduce.size());
		System.out.println("||总时间：" + alltime + "ms," + (double) (alltime) / 1000 + "s");

		StaticReduceResult result = new StaticReduceResult(update_teResult.getUpdate_te(), tEList, newReduce, times,
				posattr, TNECsize);
		U.addAll(Uad);
		return result;
	}

	// 18 删除多个Sample得到更新后的te表 20220816略
//	public teCollection  update_delete_te(ArrayList<Sample> Ude,teCollection Initial_te){
//		this.delete_te=new HashMap<IntArrayKey,toleranceClass>(Ude.size());
//		teCollection update_te=new teCollection();
//		update_te.addnewAll(Initial_te);
//		int flag=-1;
//		boolean con=false;
//		for(Sample x:Ude) {
//			con=false;  //不包含*
//			IntArrayKey hashkey=new IntArrayKey(x.getConditionValues());
//			toleranceClass te=new toleranceClass();
//			if(!x.isIs_Incomplete())  
//				te=update_te.getComplete().get(hashkey);    //Complete
//			else {
//				te=update_te.getIncomplete().get(hashkey);    //Incomplete
//				con=true;
//			}
//			if(te==null) {
//				System.out.println("未包含x:"+x.getName());
//			}else {
//			flag=x.getDecisionValues();
//			//System.out.print(con);
//			if(te.getCount()==1) {   //删掉之后还要考虑te.TE中的部分
//				for(int k=0;k<te.getTE().size();k++) {
//					toleranceClass te1=te.getTE().get(k);
//					flag=te1.getDec();
//					int n=-1;
//					for(int m=0;m<te1.getTE().size();m++) {
//						toleranceClass te2=te1.getTE().get(m);
//						if(!te2.getteValue().equals(te.getteValue())) {
//							if (flag!=te2.getDec())
//								flag=-1;								
//						}else {
//							n=m;
//							//System.out.print("删除了"+te1.getteValue()+"中的"+te.getteValue());
//						}
//					}
//					te1.getTE().remove(n);
//					if(flag==te1.getDec()) {
//						te1.settDec(te1.getDec());
//						te1.settCnst(1);
//					}else {
//						te1.settDec(-1);
//						te1.settCnst(-1);
//					}
//				}
//				this.delete_te.put(te.getteValue(), te);
//				if(con)
//					update_te.getIncomplete().remove(te.getteValue());
//				else update_te.getComplete().remove(te.getteValue());
//			}else if(te.getCount()!=1 && te.getCnst()==1){
//				for(int i=0;i<te.getMember().size();i++) {
//					Sample xtemp=te.getMember().get(i);
//					if(xtemp.getName()==x.getName()) {
//						te.getMember().remove(i);
//						te.setCount(te.getCount()-1);
//					}
//				}						
//			}else if(te.getCount()!=1 && te.getCnst()!=1) {
//				int n=-1,b=0;
//				for(int i=0;i<te.getMember().size();i++) {
//					Sample xtemp=te.getMember().get(i);
//					if(xtemp.getName()==x.getName()) {
//						n=i;
//					}
//					if(xtemp.getName()!=x.getName())
//						if(b==0) {
//							flag=xtemp.getDecisionValues();b+=1;
//						}
//						else if (flag!=xtemp.getDecisionValues())
//							flag=-1;
//				}
//				if(n!=-1) {
//					te.getMember().remove(n);
//					te.setCount(te.getCount()-1);
//				}			
//				if(flag!=-1) {  //在cnst=-1的条件下flag!=/说明是x导致te.dec变化
////					for(toleranceClass te3:te.getTE()) {
////						if(te3.getDec().equals("/"))
////							break;
////					}
//					te.setCnst(1);
//					te.setDec(te.getMember().get(0).getDecisionValues());
//					//flag=te.getDec();
//					for(int j=0;j<te.getTE().size();j++) {
//						toleranceClass te4=te.getTE().get(j);
//						boolean dec4flag=true;
//						if(te4.getDec()!=flag) {
//							te.settDec(-1);
//							te4.settDec(-1);	
//							te.settCnst(-1);
//							te4.settCnst(-1);
//						}else {   //如果te和te4的dec相同即判断是否由te引起te4.tDec变化
//							for(int z=0;z<te4.getTE().size();z++) {									
//								toleranceClass te5=te4.getTE().get(z);
//								if(!te5.equals(te))
//									if(te4.getDec()!=te5.getDec())
//										dec4flag=false;
//							}
//							if(dec4flag) { //说明是由te改变了te4.tDec
//								te4.settDec(te4.getDec());
//								te4.settCnst(1);
//							}else {  //说明te不是使te4.tDec=/状态的原因
//								te.settDec(flag);
//								te.settCnst(1);
//							}
//						}							
//					}
//				}else {	  //在cnst=-1的条件下flag==/说明不是x导致te变化
//					
//				}
//			}
//			}
//		}
//		this.Initial_te=update_te;
//		return update_te;
//	}

	// 19 从更新后的te表更新tE表（删除）20220816略
//	public tEListCollection update_delete_tE(teCollection update_te,tEListCollection tEList){
//		//ArrayList<HashMap<ArrayList<String>,ArrayList<tE>>> 
//		tEtempCollection tE_temp=new tEtempCollection();//*******
//		tEListCollection newtEList=new tEListCollection();
//		Set<Entry<IntArrayKey,ArrayList<tE>>> IneffectiveSet=tEList.getIneffective().entrySet();
//		//Set<Entry<String,ArrayList<tE>>> EffectiveSet=tEList.getEffective().entrySet();
//		for(Entry<IntArrayKey,ArrayList<tE>> entry:IneffectiveSet) {
//			//System.out.print(attributes);
//			boolean flag=false;
//			//List<Integer> attrList=this.ReduceStringtoList(entry.getKey());
//			ArrayList<tE> List=entry.getValue();
//			ArrayList<tE> newList=new ArrayList<>(List.size());
//			toleranceClass te=new toleranceClass();
//			//String lastAttrName=attrList.get(attrList.size()-1);
//			for(int i=0;i<List.size();i++) {
//				tE tE=List.get(i);
//				tE tE2=new tE();
//				flag=false;  //不含*
//				if(tE.gettEValue().contains(-1))
//					flag=true;
//				//ArrayList<Integer> removeteNum=new ArrayList<>();
//				int is_remove_size=0;
//				for(int j=0;j<tE.getMember().size();j++) {
//					toleranceClass tetemp=tE.getMember().get(j);	
//					boolean is_remove=false;
//					  //还没验证0314	
//					Set<IntArrayKey> keyset=this.delete_te.keySet();
//					for(IntArrayKey key:keyset) {
//						toleranceClass tetemp2=this.delete_te.get(key);
//						if(tetemp2.getteValue().equals(tetemp.getteValue())) {
//							is_remove=true;
//							is_remove_size++;
//						}
//					}
//					if(!is_remove) {  //当tetemp不是要被删除的te时
//						if(tetemp.is_Incomplete()) 
//							te=update_te.getIncomplete().get(tetemp.getteValue());						
//						else 
//							te=update_te.getComplete().get(tetemp.getteValue());
//						if(tE2.isEmpty()) {
//							LinkedList<toleranceClass> member=new LinkedList<toleranceClass>();
//							LinkedList<toleranceClass> TE=new LinkedList<toleranceClass>();
//							member.add(te);
//							tE2=new tE(tE.getValue(),member,te.getCount(),te.getCnst(),te.getDec(),te.istetCnst(),TE,te.getCount(),te.getDec(),te.getCnst());  //新建
//						}else {						
//							if(te.gettCnst()==1)
//								tE2.setM_tCnst(true);
//							tE2.addCount(te.getCount());
//							tE2.settCount(tE2.getCount());
//							tE2.getMember().add(te);
//							if(tE2.getDec()==te.getDec()&&tE2.getCnst()==1&&te.getCnst()==1) {
//							}else if(tE2.getCnst()==-1&&te.getCnst()==-1){
//							}else {
//								tE2.setCnst(0);
//								tE2.setDec(-1);
//								tE2.settCnst(-1);	
//								tE.settDec(-1);	
//							}
//							if(tE2.isM_tCnst()&& tE2.gettCnst()!=1)
//								tE2.settCnst(0);
//						}
//					}	
//				}
//				if(!(tE.getMember().size()==is_remove_size)) {
//					newList.add(tE2);	
//					//System.out.print(tE.getMember()==null);
//					if(flag) 
//						tE_temp.getIncomplete().put(tE2.gettEValue(), tE2);
//					else tE_temp.getComplete().put(tE2.gettEValue(), tE2);			
//				}
//			}
//			tEList.getIneffective().replace(entry.getKey(),newList);	
//			newtEList.getIneffective().put(entry.getKey(),newList);	
//			tE_temp=this.addTE_tE_multi(tE_temp);
//			//this.outPuttE_temp(tE_temp);
//			//tEList.get(1).remove(attributes);
//			newtEList.getIneffective().remove(entry.getKey());
//			//int[] attrListInt = attrList.stream().mapToInt(Integer::valueOf).toArray();
//			newtEList=this.divideEffectiveList(tE_temp, newtEList, entry.getKey().key(), -1);
//			if(newtEList.getEffective()!=null)
//				return newtEList;
//		}			
//		return newtEList;
//	}

	// 20 删除多个Sample得到新的Reduce 20220816略
//	public List<Integer> INECReduce_deleteSample(ArrayList<Sample> Ude,teCollection Initial_te,tEListCollection tEList,List<Integer> Reduce){
//		List<Integer> newReduce=new ArrayList<>(Reduce.size());
//		//newReduce.addAll(Reduce);
//		IntArrayKey ReduceKey=new IntArrayKey();
//		//StringBuilder newReduceString=new StringBuilder();
//		//newReduceString.append(this.ReduceListtoString(Reduce));
//		teCollection update_te=new teCollection();
//		update_te=this.update_delete_te(Ude, Initial_te);
//		//this.outPutInitial_te(update_te);
//		tEList=this.update_delete_tE(update_te, tEList);			
//		Set<IntArrayKey> teEffSet=tEList.getEffective().keySet();
//		Set<IntArrayKey> teIneffSet=tEList.getIneffective().keySet();
//		if(tEList.getEffective().size()!=0) {
//			for(IntArrayKey key:teEffSet) {
//				newReduce=Arrays.stream(key.key()).boxed().collect(Collectors.toList());
//				ReduceKey=key;
//			}
//		}else {
//			for(IntArrayKey key:teIneffSet) {
//				newReduce=Arrays.stream(key.key()).boxed().collect(Collectors.toList());
//				ReduceKey=key;
//			}
//		}
//		List<Integer> remainC=Arrays.stream(this.CName).boxed().collect(Collectors.toList());
////		List<Integer> remainC=new ArrayList<>();
////		for(int a:this.CName)
////			if(!ReduceKey.contains(a))
////				remainC.add(Integer.valueOf(a));
//		//System.out.println(remainC);
//		//start=System.currentTimeMillis();
//		Significance maxSig=new Significance();
//		Significance scdSig=new Significance();
//		int max_a=-1,scd_a=-1;
//		tEtempCollection max_tE_temp;
//		tEtempCollection scd_tE_temp;
//		tEtempCollection tE_temp;	
//		int maxj=0,scdj=0;
//		while(tEList.getEffective().size()!=0 && remainC.size()!=0) {  //Effective
//			maxSig=new Significance();scdSig=new Significance();
//			//int[] newReduceInt = newReduce.stream().mapToInt(Integer::valueOf).toArray();
//			for(int k=0;k<remainC.size();k++) {									
//				float count=0;
//				int a=remainC.get(k);
//				ArrayList<HashMap<IntArrayKey,toleranceClass>> teList=this.generateInitial_te_tEMember_bymultitE(tEList.getEffective().get(ReduceKey));
//				tE_temp=this.generateInitial_tE_iteration_multitE(teList,a,ReduceKey.key());
//				tE_temp=this.addTE_tE_multi(tE_temp);
//				for (tE tEcount:tEList.getEffective().get(ReduceKey))
//					count+=tEcount.gettCount();				
//				//this.outPuttE_temp(tE_temp);
//				Significance a_sig=this.significance(tE_temp, ReduceKey.key(), a, count);
//				//System.out.println("确认度："+a_sig.getCertainlyValue()+"不确认度："+a_sig.getUncertainlyValue());
//				//if (a_sig.getCertainlyValue()>maxSig.getCertainlyValue()) {  //暂时用确定性衡量
//				if(a_sig.getPOS()>maxSig.getPOS()) {
//					max_a=a;
//					max_tE_temp=tE_temp;
//					maxSig=a_sig;
//					maxj=k;		
//				}else {
//					if(a_sig.getUncertainlyValue()<=scdSig.getUncertainlyValue()) {
//						if(a_sig.getUncertainlyValue()==scdSig.getUncertainlyValue()&&a_sig.getCertainlyValue()>=scdSig.getCertainlyValue()) {
//							scd_a=a;
//							scd_tE_temp=tE_temp;
//							scdSig=a_sig;
//							scdj=k;
//						}else if(a_sig.getUncertainlyValue()<scdSig.getUncertainlyValue()) {
//							scd_a=a;
//							scd_tE_temp=tE_temp;
//							scdSig=a_sig;
//							scdj=k;
//						}			
//					}
//				}
//				//System.out.println("迭代："+a);
//				//this.outPuttE_temp(tE_temp);
//			}
//			if(maxSig.getPOS()!=0) {
//				//System.out.println("最优："+max_a);
//				//this.outPuttE_temp(max_tE_temp);
//				tEList=this.divideEffectiveList(max_tE_temp, tEList, ReduceKey.key(), max_a);
//				newReduce.add(max_a);
//				ReduceKey.addKey(max_a);				
//				remainC.remove(Integer.valueOf(maxj));
//			}else {
//				//System.out.println("最优："+scd_a);
//				//this.outPuttE_temp(scd_tE_temp);
//				tEList=this.divideEffectiveList(scd_tE_temp, tEList, ReduceKey.key(), scd_a);
//				newReduce.add(scd_a);
//				ReduceKey.addKey(scd_a);
//				remainC.remove(Integer.valueOf(scdj));
//			}	
//		}
//		//end=System.currentTimeMillis();
//		//System.out.print("第3步："+(end-start)+"ms,"+(double)(end-start)/1000+"s");
//		this.tEList=tEList;
//		for(int i=0;i<newReduce.size();i++) {  //删除冗余属性
//			int a=newReduce.get(i);
//			boolean redundancy=this.redundancy(update_te,newReduce, a);
//			if(redundancy) {
//				newReduce.remove(i);
//				i--;
//				Set<IntArrayKey> keySet=tEList.getIneffective().keySet();
//				//20220803修改
//				List<IntArrayKey> toBRemoved=new LinkedList<>();
//				for (IntArrayKey key:keySet)
//					if(key.contains(a))
//						toBRemoved.add(key);
//				for(IntArrayKey k:toBRemoved)
//					tEList.getIneffective().remove(k);
////				for (IntArrayKey key:keySet)
////					if(key.contains(a))
////						tEList.getIneffective().remove(key);
//			}
//		}
//		this.Reduce=newReduce;
//		//int[] newReduceInt = newReduce.stream().mapToInt(Integer::valueOf).toArray();
//		//this.Ude=new ArrayList<>();
//		return newReduce;
//	}

	// 22 从更新后的te表更新tE表（增删）
//	public tEListCollection update_multi_tE(teCollection update_te,tEListCollection tEList) {
//		tEtempCollection tE_temp=new tEtempCollection();
//		Set<Entry<IntArrayKey,ArrayList<tE>>> IneffectiveSet=tEList.getIneffective().entrySet();
//		//Set<Entry<String,ArrayList<tE>>> EffectiveSet=tEList.getEffective().entrySet();
//		tEListCollection newtEList=new tEListCollection();
//		HashMap<IntArrayKey,toleranceClass> addHash=new HashMap<>();
//		addHash.putAll(this.add_te);
//		for(Entry<IntArrayKey,ArrayList<tE>> entry:IneffectiveSet) {
//			ArrayList<tE> List=tEList.getIneffective().get(entry.getKey());
//			ArrayList<tE> newList=new ArrayList<>();
//			boolean flag=false;
//			for(int i=0;i<List.size();i++) {
//				tE tE=List.get(i);
//				tE tE2=new tE();
//				flag=false;  //不含*
//				toleranceClass te=new toleranceClass();
//				if(tE.gettEValue().contains(-1))
//					flag=true;
//				for(int j=0;j<tE.getMember().size();j++) {
//					toleranceClass tetemp=tE.getMember().get(j);
//					boolean is_remove=false;
//					Set<IntArrayKey> keyset=this.delete_te.keySet();
//					for(IntArrayKey key:keyset) {
//						toleranceClass tetemp2=this.delete_te.get(key);
//						if(tetemp2.getteValue().equals(tetemp.getteValue()))
//							is_remove=true;
//					}
//					if(!is_remove) {
//						if(tetemp.is_Incomplete()) 
//							te=update_te.getIncomplete().get(tetemp.getteValue());						
//						else 
//							te=update_te.getComplete().get(tetemp.getteValue());
//						if(tE2.isEmpty()) {
//							LinkedList<toleranceClass> member=new LinkedList<toleranceClass>();
//							LinkedList<toleranceClass> TE=new LinkedList<toleranceClass>();
//							member.add(te);
//							tE2=new tE(tE.getValue(),member,te.getCount(),te.getCnst(),te.getDec(),te.istetCnst(),TE,te.getCount(),te.getDec(),te.getCnst());  //新建
//						}else {
//							if(te.gettCnst()==1)
//								tE2.setM_tCnst(true);
//							tE2.addCount(te.getCount());
//							tE2.settCount(tE2.getCount());
//							tE2.getMember().add(te);
//							if(tE2.getDec()==te.getDec()&&tE2.getCnst()==1&&te.getCnst()==1) {
//							}else if(tE2.getCnst()==-1&&te.getCnst()==-1){
//							}else {
//								tE2.setCnst(0);
//								tE2.setDec(-1);
//								tE2.settCnst(-1);								
//							}
//							if(tE2.isM_tCnst()&& tE2.gettCnst()!=1)
//								tE2.settCnst(0);
//						}
//					}			
//				}
//				Set<IntArrayKey> add_teSet=addHash.keySet();	
//				Set<IntArrayKey> removeTest=new HashSet<>();	
//				for(IntArrayKey key:add_teSet) {
//					toleranceClass te1=addHash.get(key);						
//					IntArrayKey attr=new IntArrayKey();
//					for(Integer a:tE2.getValue().keySet())
//						attr.addKey(te1.getValue()[a]);   //tE2.getValue()中不含","
//					if(attr.equals(tE2.gettEValue())) {
//						if(te1.gettCnst()==1)
//							tE2.setM_tCnst(true);
//						tE2.addCount(te1.getCount());
//						tE2.settCount(tE2.getCount());
//						tE2.getMember().add(te1);
//						if(tE2.getDec()==te1.getDec()&&tE2.getCnst()==1&&te1.getCnst()==1) {
//						}else if(tE2.getCnst()==-1&&te1.getCnst()==-1){
//						}else {
//							tE2.setCnst(0);
//							tE2.setDec(-1);
//							tE2.settCnst(-1);							
//						}
//						if(tE2.isM_tCnst()&& tE2.gettCnst()!=1)
//							tE2.settCnst(0);	
//						removeTest.add(key);
//					}	
//				}	
//				add_teSet.removeAll(removeTest);
//				newList.add(tE2);			
//				if(flag) 
//					tE_temp.getIncomplete().put(tE2.gettEValue(), tE2);
//				else tE_temp.getComplete().put(tE2.gettEValue(), tE2);
//			}
//			tEList.getIneffective().replace(entry.getKey(),newList);	
//			newtEList.getIneffective().put(entry.getKey(), newList);
//			if(addHash!=null) {
//				Set<IntArrayKey> add_teSet=addHash.keySet();
//				for(IntArrayKey key:add_teSet) {
//					toleranceClass te=addHash.get(key);
//					LinkedList<toleranceClass> member=new LinkedList<toleranceClass>();
//					LinkedList<toleranceClass> TE=new LinkedList<toleranceClass>();
//					member.add(te);
//					HashMap<Integer,Integer> attr=new HashMap<>();
//					for(int a:entry.getKey().key())
//						attr.put(a,te.getValue()[a]);
//					tE tE2=new tE(attr,member,te.getCount(),te.getCnst(),te.getDec(),te.istetCnst(),TE,te.getCount(),te.getDec(),te.getCnst());  //新建
//					if(this.containsIncomplete(tE2.getValue())) 
//						tE_temp.getIncomplete().put(tE2.gettEValue(), tE2);
//					else tE_temp.getComplete().put(tE2.gettEValue(), tE2);
//				}
//			}
//			tE_temp=this.addTE_tE_multi(tE_temp);
//			this.outPuttE_temp(tE_temp);
//			//tEList.get(1).remove(attributes);
//			newtEList.getIneffective().remove(entry.getKey());
//			//int[] attrListInt = attrList.stream().mapToInt(Integer::valueOf).toArray();
//			newtEList=this.divideEffectiveList(tE_temp, newtEList, entry.getKey().key(), -1);
//			if(newtEList.getEffective()!=null) {
//				return newtEList;
//			}
//		}
//		return newtEList;
//	}
//	
//	//23  增加并删除多个Sample
//	public List<Integer> INECReduce_multiSample(ArrayList<Sample> Uad,ArrayList<Sample> Ude,teCollection Initial_te,tEListCollection tEList,List<Integer> Reduce){
//		List<Integer> newReduce=new ArrayList<>();
//		newReduce.addAll(Reduce);
//		//StringBuilder newReduceString=new StringBuilder();
//		IntArrayKey ReduceKey=new IntArrayKey();
//		teCollection update_te=this.update_add_te(Uad, Initial_te);
//		this.outPutInitial_te(update_te);
//		update_te=this.update_delete_te(Ude, update_te);
//		this.outPutInitial_te(update_te);
//		tEList=this.update_multi_tE(update_te, tEList);
//		Set<IntArrayKey> teSet=tEList.getEffective().keySet();
//		if(tEList.getEffective()!=null) {
//			for(IntArrayKey key:teSet) {
//				newReduce=Arrays.stream(key.key()).boxed().collect(Collectors.toList());
//				ReduceKey=key;
//			}
//		}
//		List<Integer> remainC=new ArrayList<>();
//		for(int a:this.CName)
//			if(!ReduceKey.contains(a))
//				remainC.add(Integer.valueOf(a));
//		int j=0;
//		Significance maxSig=new Significance();
//		int max_a=-1; 
//		tEtempCollection max_tE_temp=new tEtempCollection(); 
//		tEtempCollection tE_temp=new tEtempCollection();
//		while(tEList.getEffective().size()!=0 && remainC.size()!=0) {  //Effective
//			maxSig=new Significance();
//			//int[] newReduceInt = newReduce.stream().mapToInt(Integer::valueOf).toArray();
//			for(int k=0;k<remainC.size();k++) {									
//				float count=0;
//				int a=remainC.get(k).intValue();
//				ArrayList<HashMap<IntArrayKey,toleranceClass>> teList=this.generateInitial_te_tEMember_bymultitE(tEList.getEffective().get(ReduceKey));
//				tE_temp=this.generateInitial_tE_iteration_multitE(teList,a,ReduceKey.key());
//				tE_temp=this.addTE_tE_multi(tE_temp);
//				for (tE tEcount:tEList.getEffective().get(ReduceKey))
//					count+=tEcount.gettCount();				
//				//this.outPuttE_temp(tE_temp);
//				Significance a_sig=this.significance(tE_temp, ReduceKey.key(), a, count);
//				//System.out.println("确认度："+a_sig.getCertainlyValue()+"不确认度："+a_sig.getUncertainlyValue());
//				//if (a_sig.getCertainlyValue()>maxSig.getCertainlyValue()) {  //暂时用确定性衡量
//				if(a_sig.getPOS()>maxSig.getPOS()) {
//					max_a=a;
//					max_tE_temp=tE_temp;
//					maxSig=a_sig;
//					j=k;	
//				}
//				//System.out.println("迭代："+a);
//				//this.outPuttE_temp(tE_temp);
//			}
//			//System.out.println("最优："+max_a);
//			//this.outPuttE_temp(max_tE_temp);
//			//System.out.println(Reduce);
//			tEList=this.divideEffectiveList(max_tE_temp, tEList, ReduceKey.key(), max_a);
//			newReduce.add(max_a);
//			ReduceKey.addKey(max_a);
//			remainC.remove(j);		
//		}
//		//end=System.currentTimeMillis();
//		//System.out.print("第3步："+(end-start)+"ms,"+(double)(end-start)/1000+"s");
//		this.tEList=tEList;
//		for(int i=0;i<newReduce.size();i++) {  //删除冗余属性
//			int a=newReduce.get(i);
//			boolean redundancy=this.redundancy(update_te, newReduce, a);
//			if(redundancy)
//				newReduce.remove(i);
//		}
//		this.Reduce=newReduce;
//		this.Uad=new ArrayList<>();
//		this.Ude=new ArrayList<>();
//		return newReduce;
//	}
//		
//	//24 删除多个attrbute得到更新后的te表
//	public teCollection update_delete_attr_te(int[] Cde,teCollection Initial_te,List<Integer> Reduce){
//		teCollection update_te=new teCollection();
//		//update_te.addAll(Initial_te);	
//		this.flag_CdeContainsReduce=false;
//		Set<Entry<IntArrayKey,toleranceClass>> entrySet;
//		List<Integer> remainC=new ArrayList<>();
//		boolean flag1=false;
//		int[] CdeIndex=new int[Cde.length];int num=0;
//		for(int m=0;m<Cde.length;m++) {
//			for(int a=0;a<this.CLength;a++) {
//			if(Cde[m]==CName[a]) {
//				flag1=true;
//				CdeIndex[num]=a;
//				num++;
//			}
//			if(Reduce.contains(Cde[m]))
//				this.flag_CdeContainsReduce=true;
//			}
//			if (!flag1)
//			remainC.add(Integer.valueOf(Cde[m]));
//		}
//		this.CName = remainC.stream().mapToInt(Integer::valueOf).toArray();
//		this.CLength=this.CName.length;
//	//	String remainCString=this.ReduceArrayListtoString(remainC);
//		for(int k=0;k<2;k++) {
//			if (k==0)
//				entrySet=Initial_te.getIncomplete().entrySet();			
//			else entrySet=Initial_te.getComplete().entrySet();
//			for(Entry<IntArrayKey,toleranceClass> entry:entrySet) {
//				toleranceClass te=entry.getValue();
//				int[] valuetemp=new int[this.CLength];
//				num=0;int num2=0;
//				for(int i=0;i<te.getValue().length;i++){
//					if(CdeIndex[num2]!=i) {
//						valuetemp[num]=te.getValue()[i];
//						num++;
//					}else num2++;
//				}		
//				te.setValue(valuetemp);
//				IntArrayKey valuetempKey=te.getteValue();
//				HashMap<IntArrayKey,toleranceClass> hash;
//				if(te.is_Incomplete())   //Incomplete
//					hash=update_te.getIncomplete();
//				else hash=update_te.getComplete();
//				if(hash.containsKey(valuetempKey)) {
//					toleranceClass te2=hash.get(valuetempKey);  //remainCString格式和key可能不一样
//					te2.getMember().addAll(te.getMember());
//					te2.setCount(te2.getCount()+te.getCount());
//					te2.addNotContaintE(te.getTE());
//					if(te2.getCnst()==te.getCnst()&& te2.getDec()==te.getDec()) {			
//					}else {
//						te2.setCnst(-1);
//						te2.setDec(-1);
//						for(toleranceClass te3:te2.getTE()) {
//							te3.settDec(-1);
//							te3.settCnst(-1);
//						}
//					}
//					if(te2.gettCnst()==te.gettCnst()&& te2.gettDec()==te.gettDec()) {							
//					}else {
//						te2.settCnst(-1);
//						te2.settDec(-1);
//					}
//				}else hash.put(te.getteValue(), te);
//			}
//		}		
//		return update_te;
//	}
//		
//	//26  删除多个Attribute
//	public List<Integer> INECReduce_deleteAttribute(int[] Cde,teCollection Initial_te,tEListCollection tEList,List<Integer> Reduce){
//		tEListCollection newtEList=new tEListCollection();
//		List<Integer> newReduce=new ArrayList<>();
//		//StringBuilder newReduceString=new StringBuilder();
//		IntArrayKey ReduceKey=new IntArrayKey();
//		tEtempCollection tE_temp=new tEtempCollection();
//		Significance maxSig=new Significance();
//		int max_a=-1;
//		tEtempCollection  max_tE_temp=new tEtempCollection ();
//		teCollection update_te=this.update_delete_attr_te(this.Cde, Initial_te,Reduce);   //进行这一步时已更新CName
//		update_te=this.addTE_te(update_te);
//		//this.outPutInitial_te(update_te);
//		//tEList=this.update_multi_tE(update_te, tEList);
//		if(!this.flag_CdeContainsReduce) 
//			return Reduce;
//		int minj=Integer.MAX_VALUE;
//		for(int a:Cde) 
//			for(int i=0;i<Reduce.size();i++) 
//				if (a==Reduce.get(i)) {
//					if(i<minj)
//						minj=i;
//					break;
//				}
//		if(minj!=0) {
//			for(int z=0;z<minj;z++) 
//				newReduce.add(Reduce.get(z));	
//			ReduceKey=new IntArrayKey(newReduce.stream().mapToInt(Integer::valueOf).toArray());
//			Set<Entry<IntArrayKey,ArrayList<tE>>> entrySet3=tEList.getIneffective().entrySet();
//			for(Entry<IntArrayKey,ArrayList<tE>> entry3:entrySet3) {						
//				if(!entry3.getKey().equals(ReduceKey)) {
//					newtEList.getIneffective().put(entry3.getKey(),entry3.getValue());
//				}else {
//					ArrayList<tE> list=entry3.getValue();
//					ArrayList<tE> Efftemp=new ArrayList<>();
//					ArrayList<tE> Inefftemp=new ArrayList<>();
//					for(tE tE4:list)
//						if(tE4.gettCnst()==0) 
//							Efftemp.add(tE4);
//						else Inefftemp.add(tE4);
//					newtEList.getIneffective().put(ReduceKey, Inefftemp);
//					newtEList.getEffective().put(ReduceKey, Efftemp);
//					break;
//				}
//			}
//		}else {   //如果为空
//			//int j=0;
//			//System.out.print("重新计算");
//			for(int i=0;i<this.CLength;i++) {
//				int a=this.CName[i];
//				tE_temp=this.generateInitial_tE_single(Initial_te,a,new int[0]);
//				tE_temp=this.addTE_tE_single(tE_temp);
//				Significance a_sig=this.significance(tE_temp, null, a, U.size());
//				System.out.println("确认度："+a_sig.getCertainlyValue()+"不确认度："+a_sig.getUncertainlyValue());
//				//if (a_sig.getCertainlyValue()>maxSig.getCertainlyValue()) {  //暂时用确定性衡量
//				if(a_sig.getPOS()>maxSig.getPOS()) {
//					max_a=a;
//					max_tE_temp=tE_temp;
//					maxSig=a_sig;
//					//j=i;		
//				}
//				System.out.println("迭代："+a);
//				this.outPuttE_temp(tE_temp);
//			}
//			System.out.println("最优："+max_a);
//			this.outPuttE_temp(max_tE_temp);
//			newReduce.add(max_a);
//			ReduceKey.addKey(max_a);
//			tEList=this.divideEffectiveList(max_tE_temp,tEList,new int[0],max_a);
//		}
//		List<Integer> remainC=new ArrayList<>();
//		for(int a:this.CName)
//			if(!ReduceKey.contains(a))
//				remainC.add(Integer.valueOf(a));
//		System.out.println(remainC);
//		int j=0;
//		maxSig=new Significance();
//		max_a=-1; 
//		max_tE_temp=new tEtempCollection(); 
//		tE_temp=new tEtempCollection();
//		while(tEList.getEffective().size()!=0 && remainC.size()!=0) {  //Effective
//			maxSig=new Significance();
//			//int[] newReduceInt = newReduce.stream().mapToInt(Integer::valueOf).toArray();
//			for(int k=0;k<remainC.size();k++) {									
//				float count=0;
//				int a=remainC.get(k).intValue();
//				ArrayList<HashMap<IntArrayKey,toleranceClass>> teList=this.generateInitial_te_tEMember_bymultitE(tEList.getEffective().get(ReduceKey));
//				tE_temp=this.generateInitial_tE_iteration_multitE(teList,a,ReduceKey.key());
//				tE_temp=this.addTE_tE_multi(tE_temp);
//				for (tE tEcount:tEList.getEffective().get(ReduceKey))
//					count+=tEcount.gettCount();				
//				//this.outPuttE_temp(tE_temp);
//				Significance a_sig=this.significance(tE_temp, ReduceKey.key(), a, count);
//				//System.out.println("确认度："+a_sig.getCertainlyValue()+"不确认度："+a_sig.getUncertainlyValue());
//				//if (a_sig.getCertainlyValue()>maxSig.getCertainlyValue()) {  //暂时用确定性衡量
//				if(a_sig.getPOS()>maxSig.getPOS()) {
//					max_a=a;
//					max_tE_temp=tE_temp;
//					maxSig=a_sig;
//					j=k;
//				}
//				//System.out.println("迭代："+a);
//				//this.outPuttE_temp(tE_temp);
//			}
//			//System.out.println("最优："+max_a);
//			//this.outPuttE_temp(max_tE_temp);
//			//System.out.println(Reduce);
//			tEList=this.divideEffectiveList(max_tE_temp, tEList,ReduceKey.key(), max_a);
//			newReduce.add(max_a);
//			ReduceKey.addKey(max_a);
//			remainC.remove(j);		
//		}
//		//end=System.currentTimeMillis();
//		//System.out.print("第3步："+(end-start)+"ms,"+(double)(end-start)/1000+"s");
//		this.tEList=tEList;
//		for(int i=0;i<newReduce.size();i++) {  //删除冗余属性
//			int a=newReduce.get(i);
//			boolean redundancy=this.redundancy(update_te,newReduce, a);
//			if(redundancy)
//				newReduce.remove(i);
//		}
//		this.Reduce=newReduce;
//		this.Cde=null;
//		return newReduce;
//	}

}

package main.java.FSSNC.algorithm;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Random;
import java.util.Set;
import java.util.Map.Entry;

import main.Log4jPrintStream;
import main.basic.model.ProcessingResult;
import main.java.FSSNC.entity.Sample;

public class DataProcessing_FSSNC {
	private String filePath;
	private ArrayList<Sample> U;
	private int USize;
	private int[] CName;
	private ArrayList<String[]> dataArray;
	private List<Integer> Reduce;
	private float σ;
	private int[] numberDataCindex;
	private HashMap<Integer,ArrayList<String[]>> dividedata;
	private LinkedList<ProcessingResult> processingResultList=new LinkedList<>();
	
	static {
		Log4jPrintStream.redirectSystemOut();
	}
	public String getFilePath() {
		return filePath;
	}
	public void setFilePath(String filePath) {
		this.filePath = filePath;
	}
	public ArrayList<Sample> getU() {
		return U;
	}
	public void setU(ArrayList<Sample> u) {
		U = u;
	}
	public int getUSize() {
		return USize;
	}
	public void setUSize(int uSize) {
		USize = uSize;
	}
	public int[] getCName() {
		return CName;
	}
	public void setCName(int[] cName) {
		CName = cName;
	}
	public ArrayList<String[]> getDataArray() {
		return dataArray;
	}
	public void setDataArray(ArrayList<String[]> dataArray) {
		this.dataArray = dataArray;
	}
	public List<Integer> getReduce() {
		return Reduce;
	}
	public void setReduce(List<Integer> reduce) {
		Reduce = reduce;
	}
	public float getΣ() {
		return σ;
	}
	public void setΣ(float σ) {
		this.σ = σ;
	}
	public int[] getNumberDataCindex() {
		return numberDataCindex;
	}
	public void setNumberDataCindex(int[] numberDataCindex) {
		this.numberDataCindex = numberDataCindex;
	}
	public HashMap<Integer, ArrayList<String[]>> getDividedata() {
		return dividedata;
	}
	public void setDividedata(HashMap<Integer, ArrayList<String[]>> dividedata) {
		this.dividedata = dividedata;
	}
	
	public DataProcessing_FSSNC() {
	}
	public DataProcessing_FSSNC(String filePath) {
		this.filePath = filePath;
	}
	public DataProcessing_FSSNC(String filePath,ArrayList<Sample> U,int USize,int[] CName,ArrayList<String[]> dataArray,List<Integer> Reduce,float σ,int[] numberDataCindex,HashMap<Integer,ArrayList<String[]>> dividedata,LinkedList<ProcessingResult> processingResultList) {
		this.filePath=filePath;
		this.U=U;
		this.USize=USize;
		this.CName=CName;
		this.dataArray=dataArray;
		this.Reduce=Reduce;
		this.σ=σ;
		this.numberDataCindex=numberDataCindex;
		this.dividedata=dividedata;
		this.processingResultList=processingResultList;
				
	};
	public LinkedList<ProcessingResult> getProcessingResultList() {
		return processingResultList;
	}
	public void setProcessingResultList(LinkedList<ProcessingResult> processingResultList) {
		this.processingResultList = processingResultList;
	}
	public void addProcessingResult(ProcessingResult result) {
		this.processingResultList.add(result);
	}
	public void addProcessingResult(String algorithm,int k,long time,List<Integer> Reduce,int ReduceSize,int Usize) {
		ProcessingResult result=new ProcessingResult(algorithm,k,time,Reduce,ReduceSize,Usize);
		this.processingResultList.add(result);
	}
	public void addProcessingResult(String algorithm,String datasetName,String missingratio,String algorithmExcCategory,int k,long time,List<Integer> Reduce,int ReduceSize,int Usize,LinkedHashMap<String,Long> splitTimes) {
		ProcessingResult result=new ProcessingResult(algorithm,datasetName,missingratio,algorithmExcCategory,k,time,Reduce,ReduceSize,Usize,splitTimes,null);
		this.processingResultList.add(result);
	}
	
	//输入数据
	public void inputData(String filePath,float σ,int[] numberDataCindex) {
		this.σ=σ;this.numberDataCindex=numberDataCindex;
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
		//this.dataArray=dataArray;
		ArrayList<Sample> U=new ArrayList<Sample>(dataArray.size());
		this.dataArray=dataArray;
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
			Sample x=new Sample(Integer.parseInt(data[0])-1,new float[data.length-1]);
				for(int j=0;j<data.length;j++) {	
					if(j!=data.length-1&&j!=0) {
						x.setAttributeValueOf(j,Float.parseFloat(data[j]));
						if(Float.parseFloat(data[j])==-1)
							x.setIs_Incomplete(true);
					}else if(j==data.length-1) 
						x.setAttributeValueOf(0,Float.parseFloat(data[j]));
					else if(j==0)
						x.setName(Integer.parseInt(data[j]));
				}
			U.add(x);							
		}
		this.U=U;
		this.USize=U.size();
	}
	//随机选取百分之x的数据转化为*
	public void inputExchangeIncomplete(String filePath,double x,int num) {
		File file=new File(filePath);
		//this.filePath=filePath;
		ArrayList<String[]> dataArray=new ArrayList<String[]>();
		//ArrayList<int[]> dataArrayInt=new ArrayList<int[]>();
		int row=0,column=0;  //行列
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
		row=dataArray.size()-1;  //行，减第一行
		column=dataArray.get(0).length-2;   //列，减name和D
		Random random = new Random();
		Set<Integer> set = new LinkedHashSet<Integer>();//LinkedHashSet是有顺序不重复集合
		double size=row*column*x;
//		String str = String.valueOf(row*column*x);//浮点变量a转换为字符串str
//	    int idx = str.lastIndexOf(".");//查找小数点的位置
//	    String strNum = str.substring(0,idx);//截取从字符串开始到小数点位置的字符串，就是整数部分
//	    int size = Integer.valueOf(strNum);//把整数部分通过Integer.valueof方法转换为数字
		//System.out.print(column);
		for(int m=0;m<num;m++) {
			while(set.size()<size) {
				Integer number=random.nextInt(row*column);
				set.add(number);  //重复就不会添加
			}
			for(Integer number:set) {
				int num1=number/column;  //得到第几行  行的前面要+1
				int num2=number%column;  //得到第几列  列的前面要+1
				dataArray.get(num1+1)[num2+1]="-1";		//Incomplete		
			}
//			for(int i=0;i<dataArray.size();i++) {
//				//int[] dataline=new int[dataArray.get(i).length];
//				String[] dataString=new String[dataArray.get(i).length];
//				for(int j=0;j<dataArray.get(i).length;j++) {
//					dataString[j]=dataArray.get(i)[j];
//				}
//				dataArray.add(dataString);
//			}
			//this.dataArray=dataArray;
			File outFile,outPath;
			String str1=filePath.substring(0,filePath.lastIndexOf("\\"));
			String str2=filePath.substring(filePath.lastIndexOf("\\"),filePath.lastIndexOf("."));
			String str3=filePath.substring(filePath.lastIndexOf("."));
			String dirPath=str1;
			String outFilePath=str1+str2+str3;		
			try{
				outPath = new File(dirPath);
				outFile = new File(outFilePath);	
				if (!outPath.exists()) {
					outPath.mkdirs();
				}
				if(!outFile.exists()) {
		            outFile.createNewFile();
		        }
				BufferedWriter out=new BufferedWriter(new FileWriter(outFile));
				String[] tempArray;
				for(int i=0;i<dataArray.size();i++) {
					tempArray=dataArray.get(i);
					String str=new String();
					for(int j=0;j<tempArray.length;j++) {
						str+=tempArray[j]+",";
					}
					str+=System.getProperty("line.separator");
					//System.out.print(str);
					out.write(str);
				}
				out.close();
			}catch(IOException e){
				e.getStackTrace();
			}
			System.out.println("文件"+str2+"_number_"+num+"转换完成"+x*100+"%变为*");
		}
	}
	//将数据划分成10次随机选择的10part数据进行增量  (仅数据下标)  这里数据下标从0开始 无第一行
	public HashMap<Integer,HashMap<Integer,ArrayList<Integer>>> divideDatato10_random(ArrayList<String[]> dataArray) {
		HashMap<Integer,HashMap<Integer,ArrayList<Integer>>> all10partdata=new HashMap<>(10);
		for(int z=0;z<10;z++) {
			// 行，减第一行
			int finalsize = 0;
			int datasize=dataArray.size()-1;  //减第一行
			List<Integer> alldataindex=new ArrayList<>(datasize);
			for (int i = 0; i < dataArray.size()-1; i++) { // 不要第一行
				alldataindex.add(i);
			}
			HashMap<Integer, ArrayList<Integer>> dataDivide = new HashMap<>(10);
			Random random = new Random();
			int size = (dataArray.size()-1) / 10;
			for (int i = 0; i < 10; i++) {
				random = new Random();			
				ArrayList<Integer> datatemp = new ArrayList<>(size);
				if (i != 9) {
					int k = 0;
					while (k < size) {
						int a = random.nextInt(alldataindex.size());// 从0到n，但不会选到n
						datatemp.add(alldataindex.get(a));
						alldataindex.remove(a);
						k++;
					}
				} else {
					datatemp.addAll(alldataindex);
				}
				dataDivide.put(i, datatemp);
				finalsize += datatemp.size();
			}
			all10partdata.put(z, dataDivide);
			System.out.println("完成第"+z+"份划分10份,共" + finalsize);
		}
		System.out.println("数据划分完成,下面输出结果文件");
		this.outDivide10DataFile_randomdivide(all10partdata);
		return all10partdata;
	}
	//输出随机划分10次后的划分结果文件
	public void outDivide10DataFile_randomdivide(HashMap<Integer,HashMap<Integer,ArrayList<Integer>>> all10partdata) {
		//this.dataArray=dataArray;
		File outFile,outPath;
		String str1=filePath.substring(0,filePath.lastIndexOf("\\"));
		String str2=filePath.substring(filePath.lastIndexOf("\\"),filePath.lastIndexOf("."));
		String str3=filePath.substring(filePath.lastIndexOf("."));
		String dirPath=str1;		
		try{
			String outFilePath=str1+str2+"_randomDivide"+str3;	
			outPath = new File(dirPath);
			outFile = new File(outFilePath);	
			if (!outPath.exists()) {
				outPath.mkdirs();
			}			
			if(!outFile.exists()) {
	            outFile.createNewFile();
	        }
			BufferedWriter out=new BufferedWriter(new FileWriter(outFile));
			for(Entry<Integer,HashMap<Integer,ArrayList<Integer>>> onepartdata:all10partdata.entrySet()) {	
				HashMap<Integer,ArrayList<Integer>> data=onepartdata.getValue();
				for(Entry<Integer,ArrayList<Integer>> partdata:data.entrySet()) {
					ArrayList<Integer> tempArray=partdata.getValue();
					String str=new String();
					str+=onepartdata.getKey()+","+partdata.getKey()+",";
					for(int j=0;j<tempArray.size();j++) {
						str+=tempArray.get(j)+",";
					}
					str+=System.getProperty("line.separator");
					//System.out.print(str);
					out.write(str);
				}
			}	
			out.close();
		}catch(IOException e){
			e.getStackTrace();
		}
		System.out.println("文件"+str2+"_randomDivide 划分完成");
	}
	//输入随机划分10次后的结果文件划分数据   按照每一part，将第10份数据作为test数据，不训练，只训练前9份数据
	public void inputDivide10DataFile_randomdivide (String filePath,int k){  
		//输入：alldata路径 alldata划分结果 第几次
		HashMap<Integer,HashMap<Integer,ArrayList<Integer>>> all10partdata=new HashMap<>(10);
		File outFile,outPath;
		String str1=filePath.substring(0,filePath.lastIndexOf("\\"));
		String str2=filePath.substring(filePath.lastIndexOf("\\"),filePath.lastIndexOf("."));
		String str3=filePath.substring(filePath.lastIndexOf("."));
		//String dirPath=str1;	
		this.filePath=filePath;
		HashMap<Integer,ArrayList<String[]>> dividedata=new HashMap<>(10);
		try{
			String inputFilePath=str1+str2+"_randomDivide"+str3;		
			File file=new File(inputFilePath);//index
			File datafile=new File(filePath); //alldata
			ArrayList<String[]> dataindexArray=new ArrayList<>();
			ArrayList<String[]> dataArray=new ArrayList<String[]>();		
			BufferedReader in=new BufferedReader(new FileReader(file));
			BufferedReader datain=new BufferedReader(new FileReader(datafile));	
				String str;
				String[] tempArray;
				//读入index划分结果列表 10*10=100行
				while((str=in.readLine())!=null){
					tempArray=str.split(",");
					dataindexArray.add(tempArray);
				}
				//读入所有数据
				while((str=datain.readLine())!=null){
					tempArray=str.split(",");
					dataArray.add(tempArray);
				}
				//构成第k次运行的数据划分
				for(int i=0;i<10;i++) {
					int num=k*10;			
					String[] list=dataindexArray.get(num+i);
					ArrayList<String[]> onepartdata=new ArrayList<>(list.length-2);					
					for(int z=2;z<list.length;z++) {  //数据为“ 第k次 第i部分 [indexlist]”
						onepartdata.add(dataArray.get(Integer.parseInt(list[z])+1));
					}
					dividedata.put(i, onepartdata);
				}				
				in.close();		
		}catch(IOException e){
			e.getStackTrace();
		}	
		this.dividedata=dividedata;		
	}
	//输入划分后的10份数据
	public void inputDivide10DataFile (String filePath){
		File outFile,outPath;
		String str1=filePath.substring(0,filePath.lastIndexOf("\\"));
		String str2=filePath.substring(filePath.lastIndexOf("\\"),filePath.lastIndexOf("."));
		String str3=filePath.substring(filePath.lastIndexOf("."));
		//String dirPath=str1;	
		this.filePath=filePath;
		HashMap<Integer,ArrayList<String[]>> dividedata=new HashMap<>(10);
		try{
			for(int i=0;i<10;i++) {
				String inputFilePath=str1+str2+"_"+i+str3;		
				File file=new File(inputFilePath);
				ArrayList<String[]> dataArray=new ArrayList<String[]>();
				BufferedReader in=new BufferedReader(new FileReader(file));
				String str;
				String[] tempArray;
				while((str=in.readLine())!=null){
					tempArray=str.split(",");
					dataArray.add(tempArray);
				}
				dividedata.put(i, dataArray);
				in.close();
			}			
		}catch(IOException e){
			e.getStackTrace();
		}
		this.dividedata=dividedata;				
	}
	//通过划分的数据集input
	public void inputData_divideInitial(int num) {  //num为将几份数据作为原始数据
		this.U=new ArrayList<Sample>();
		ArrayList<String[]> dataArray=new ArrayList<>();
		for(int m=0;m<num;m++)
			dataArray.addAll(this.dividedata.get(m));//前num份数据组成初始数据	
		for(int i=0;i<dataArray.size();i++) {
			String[] data=dataArray.get(i);
			Sample x=new Sample(Integer.valueOf(data[0]),new float[data.length-1]);				
			for(int j=0;j<data.length;j++) {					
				if(j!=data.length-1&&j!=0) { 
					x.setAttributeValueOf(j,Float.parseFloat(data[j]));
					if(Float.parseFloat(data[j])==-1)
						x.setIs_Incomplete(true);
				}else if(j==data.length-1) 
					x.setAttributeValueOf(0,Float.parseFloat(data[j]));							
			}	
			this.U.add(x);
		}
	}
	//输入划分后的10份数据   按照第k次，将第k份数据作为第10份数据（test数据，不训练），只训练前9份数据
	public void inputDivide10DataFile (String filePath,int k){  
		File outFile,outPath;
		String str1=filePath.substring(0,filePath.lastIndexOf("\\"));
		String str2=filePath.substring(filePath.lastIndexOf("\\"),filePath.lastIndexOf("."));
		String str3=filePath.substring(filePath.lastIndexOf("."));
		//String dirPath=str1;	
		this.filePath=filePath;
		HashMap<Integer,ArrayList<String[]>> dividedata=new HashMap<>(10);
		try{
			for(int i=0;i<10;i++) {
				String inputFilePath=str1+str2+"_"+i+str3;		
				File file=new File(inputFilePath);
				ArrayList<String[]> dataArray=new ArrayList<String[]>();
				BufferedReader in=new BufferedReader(new FileReader(file));
				String str;
				String[] tempArray;
				while((str=in.readLine())!=null){
					tempArray=str.split(",");
					dataArray.add(tempArray);
				}
				dividedata.put(i, dataArray);
				in.close();
			}			
		}catch(IOException e){
			e.getStackTrace();
		}
		if(k!=0) {
			ArrayList<String[]> tempArray=dividedata.get(10);
			dividedata.replace(10, dividedata.get(k-1));
			dividedata.replace(k-1, tempArray);
		}		
		this.dividedata=dividedata;				
	}
	//通过划分的数据集input
	public void inputData_divideAdd(int num) {   //num是添加第几部分
		//this.newU=new ArrayList<Sample>();
		ArrayList<String[]> dataArray=new ArrayList<>();
		dataArray.addAll(this.dividedata.get(num));
		for(int i=0;i<dataArray.size();i++) {
			String[] data=dataArray.get(i);
			Sample x=new Sample(Integer.valueOf(data[0]),new float[data.length-1]);			
			for(int j=0;j<data.length;j++) {					
				if(j!=data.length-1&&j!=0) {
					x.setAttributeValueOf(j,Float.parseFloat(data[j]));
					if(Float.parseFloat(data[j])==-1)
						x.setIs_Incomplete(true);
				}else if(j==data.length-1) 
					x.setAttributeValueOf(0,Float.parseFloat(data[j]));
			}
			this.U.add(x);
		}
		//this.U.addAll(newU);
		//this.CLength=dataArray.get(0).length-2;
	}
	public void inputData_divideAddPart(int num) {   //num是添加前几部分
		//this.newU=new ArrayList<Sample>();
		ArrayList<String[]> dataArray=new ArrayList<>();
		for(int z=1;z<=num;z++)  //从第10部分开始添加
			dataArray.addAll(this.dividedata.get(z));
		for(int i=0;i<dataArray.size();i++) {
			String[] data=dataArray.get(i);
			Sample x=new Sample(Integer.valueOf(data[0]),new float[data.length-1]);			
			for(int j=0;j<data.length;j++) {					
				if(j!=data.length-1&&j!=0) {
					x.setAttributeValueOf(j,Float.parseFloat(data[j]));
					if(Float.parseFloat(data[j])==-1)
						x.setIs_Incomplete(true);
				}else if(j==data.length-1) 
					x.setAttributeValueOf(0,Float.parseFloat(data[j]));
			}
			this.U.add(x);
		}
		//this.U.addAll(newU);
		//this.CLength=dataArray.get(0).length-2;
	}
	//输出算法计算结果：算法,数据集,算法运行类型,第k次,程序运行时间,约简集,约简数量,USize
	public void outPutProcessingResult() {
		File outFile,outPath;
		String str1=filePath.substring(0,filePath.lastIndexOf("\\"));
		String str4=filePath.substring(0,str1.lastIndexOf("\\"));
		String str5=filePath.substring(0,str4.lastIndexOf("\\"));
		String dirnamepath=str5+"\\ProcessingResult";
		String str2=filePath.substring(filePath.lastIndexOf("\\"),filePath.lastIndexOf("."));
		String str3=filePath.substring(filePath.lastIndexOf("."));
		//String dirPath=str1;
		String outFilePath=dirnamepath+str2+"_ProcessingResult.csv";	
		try{
			outPath = new File(dirnamepath);
			outFile = new File(outFilePath);	
			if (!outPath.exists()) {
				outPath.mkdirs();
			}
			if(!outFile.exists()) {
	            outFile.createNewFile();
	        }
			ProcessingResult result;
			BufferedWriter out=new BufferedWriter(new FileWriter(outFile,true));
			for(int i=0;i<processingResultList.size();i++) {
				result=processingResultList.get(i);			
				if(i==0) {
					StringBuilder str=new StringBuilder();
					str.append("Time,Algorithm,Dataset,Missingratio,ExecCategory,numbers,Times,Reduct,ReductSize,USize");
					str.append(System.getProperty("line.separator"));
					out.write(str.toString());
				}
				out.write(result.toString());
			}
			out.close();
		}catch(IOException e){
			e.getStackTrace();
		}
		System.out.println("算法"+processingResultList.get(0).getAlgorithm()+"约简结果输出");
	}
	//输出算法计算结果：算法各部分程序运行时间
	public void outPutProcessingofTimesResult(LinkedHashMap<String,Long> times) {
		File outFile,outPath;
		String str1=filePath.substring(0,filePath.lastIndexOf("\\"));
		String str4=filePath.substring(0,str1.lastIndexOf("\\"));
		String str5=filePath.substring(0,str4.lastIndexOf("\\"));
		String dirnamepath=str5+"\\ProcessingResult";
		String str2=filePath.substring(filePath.lastIndexOf("\\"),filePath.lastIndexOf("."));
		String str3=filePath.substring(filePath.lastIndexOf("."));
		//String dirPath=str1;
		String outFilePath=dirnamepath+str2+"_ProcessingResult_splitTimes.csv";	
		//String outFilePath=filePath+"\\ProcessingResult_splitTimes.csv";		
		try{
			outPath = new File(dirnamepath);
			outFile = new File(outFilePath);	
			if (!outPath.exists()) {
				outPath.mkdirs();
			}
			if(!outFile.exists()) {
	            outFile.createNewFile();
	        }
			ProcessingResult result;
			BufferedWriter out=new BufferedWriter(new FileWriter(outFile,true));
			//for(int i=0;i<times.size();i++) {
				result=processingResultList.getLast();			
				if(processingResultList.size()==1||processingResultList.size()==2) {
					StringBuilder str=new StringBuilder();
					str.append("Time,Algorithm,Dataset,Missingratio,ExecCategory,numbers,");
					for(String splitTimeName:times.keySet()) {
						str.append(splitTimeName+",");
					}				
					str.append(System.getProperty("line.separator"));
					out.write(str.toString());
				}
				out.write(result.splitTimestoString());
			//}
			out.close();
		}catch(IOException e){
			e.getStackTrace();
		}
		System.out.println("算法"+processingResultList.get(0).getAlgorithm()+"分段时间结果输出");
	}
	//输出得到Reduce划分后的文件  按总数据划分
	public void outReduceFile(ProcessingResult result,int k,String ExecType) {//第k次约简
		ArrayList<String[]> data=new ArrayList<>();
		data.addAll(this.dataArray);
		ArrayList<String> Reducedata=new ArrayList<>();
		ArrayList<Integer> num=new ArrayList<>();
		num.addAll(result.ReduceSort());
		//num.add(data.get(0).length-1);  //加上D
		StringBuilder strx=new StringBuilder();
		for(int i=0;i<data.size();i++) {
			strx=new StringBuilder();			
			for(int s:num) 
				if(Float.parseFloat(data.get(i)[s+1])==-1)
					strx.append("100000,");
				else strx.append(data.get(i)[s+1]+",");			
			strx.append(data.get(i)[data.get(i).length-1]);
			strx.append(System.getProperty("line.separator"));
			Reducedata.add(strx.toString());
		}
		File outFile,outPath;
		String str1=filePath.substring(0,filePath.lastIndexOf("\\"));
		String strReduce="\\allDataReduce";
		String str2=filePath.substring(filePath.lastIndexOf("\\"),filePath.lastIndexOf("."));
		String str3=filePath.substring(filePath.lastIndexOf("."));
		String dirPath=str1+strReduce;
		String outFilePath=str1+strReduce+str2+"_"+result.getAlgorithm()+"_"+k+"_"+ExecType+"Reduce"+str3;		
		try{
			outPath = new File(dirPath);
			outFile = new File(outFilePath);
			if (!outPath.exists()) {
				outPath.mkdirs();
			}
			if(!outFile.exists()) {
	            outFile.createNewFile();
	        }
			BufferedWriter out=new BufferedWriter(new FileWriter(outFile));
			for(String str:Reducedata) {
				out.write(str);
			}
			out.close();
		}catch(IOException e){
			e.getStackTrace();
		}
		System.out.println("文件"+str2+"_"+result.getAlgorithm()+"_Reduce完成");
	}
	//对约简结果排序
		public List<Integer> ReduceSortOutPut(List<Integer> Reduce) {
			List<Integer> newReduce=new ArrayList<Integer>(Reduce);
			Collections.sort(newReduce);
			//System.out.print(newReduce);
			return newReduce;
		}
	

}

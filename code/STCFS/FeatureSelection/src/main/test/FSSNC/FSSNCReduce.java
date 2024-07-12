package main.test.FSSNC;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Formatter;
import java.util.List;
import java.util.stream.Collectors;

import main.Log4jPrintStream;
import main.java.FSSNC.algorithm.DataProcessing_FSSNC;
import main.java.FSSNC.algorithm.FSSNC;
import main.java.FSSNC.entity.IntArrayKey;
import main.java.FSSNC.entity.Sample;
import main.java.FSSNC.entity.StaticReduceResult;
import main.java.IFSICE.algorithm.IFSICE;
import main.test.DataProcessing.DataProcessing;

public class FSSNCReduce {
	static {Log4jPrintStream.redirectSystemOut();}
	//参数设置 args={文件名,"算法运行类别","运行次数",结果输出目录,参数sigma,number类型属性下标集合(int[])}，其中算法运行类别包括：StaticReduce静态约简、IncrementalReduce增量约简
	public static void main(String[] args) {
		//数据处理
		//String filePathnew="C:\\Users\\凌Y\\Desktop\\数据挖掘学习\\测试数据\\测试数据_INEC\\hepatitis.csv";//wine_km_1,horse-colic_km,spambase_km_1;audiology_standardized  //运行一个文件
		//String filePathnew="C:\\Users\\凌Y\\Desktop\\数据挖掘学习\\测试数据\\测试数据_INEC\\chess\\chess.csv"; //运行一个文件夹
		String filePathnew=args[7];  //和其他不一样！！！！
		String dataset=args[0].substring(args[0].lastIndexOf("\\"),args[0].lastIndexOf("."));
		DataProcessing_FSSNC method=new DataProcessing_FSSNC(filePathnew);
		//DataProcessing data=new DataProcessing(filePathnew);
		//data.inputData();
		method.inputData(filePathnew, 0, null);
		long start = System.currentTimeMillis();
		long end = System.currentTimeMillis();
		String missingratio=args[6];
		String times;
				
		//参数σ
		//int[] numberDataCindex= {0,1,2,3,4,5,6,7,8,9,10,11,12,13};//number类型属性下标  wine
		//int[] numberDataCindex= {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26};
		//int[] numberDataCindex= {2,3,4,5,15,18,19,21,24};//number类型属性下标  horse-colic_number
		//int[] numberDataCindex= {};
		int[] numberDataCindex=new int[method.getCName().length];  //所有条件属性都为numberDataCindex
		int N=method.getCName().length-1;
		while(N>=0) {
			numberDataCindex[N]=N;
			N--;
		}
//		String[] str=args[5].split(",");
//		 int[] intArr = new int[str.length];
//         for (int i = 0; i < str.length;i++ )
//         {
//             intArr[i] =Integer.parseInt(str[i]);
//         }
//		int[] numberDataCindex=intArr;
		
//		//静态约简
//		if(args[1].equals("StaticReduce")) {
//			System.out.println("||FSSNC静态约简程序开始，运行次数："+Integer.parseInt(args[2]));
//			for(int i=0;i<Integer.parseInt(args[2]);i++) {
//				System.out.println("||当前运行次数："+(i+1));
//				FSSNC method2=new FSSNC(filePathnew);
//				method2.inputData(filePathnew,Float.parseFloat(args[4]),numberDataCindex);
//				//method.inputExchangeIncomplete(filePathnew, 0.05, 1);
//				data.inputData();
//				start = System.currentTimeMillis();
//				StaticReduceResult previousResult=method2.FSSNCReduce(method.U,method.σ,numberDataCindex);
//				end = System.currentTimeMillis();
//				times=new Formatter().format("%.2f", ((double)(end-start)/1000)).toString();
//				data.addProcessingResult("FSSNC",dataset,missingratio,"StaticReduce",i,end-start,previousResult.reduceClone(),previousResult.getReduce().size(),data.getU().size(),previousResult.getTimes());
//				System.out.println("||程序运行时间："+(end-start)+"ms,即"+times+"s");
//				System.out.println("||约简Reduce:"+previousResult.getReduce().toString()+",约简数量:"+previousResult.getReduce().size());
//				data.outPutProcessingResult();
//				data.outPutProcessingofTimesResult(previousResult.getTimes());
//				data.outReduceFile(data.getProcessingResultList().getLast(), i);
//			}
//			
//		}
		if(args[1].equals("IncrementalReduce")) {
			System.out.println("||FSSNC静态约简程序开始，运行次数："+Integer.parseInt(args[2]));
			for(int k=0;k<Integer.parseInt(args[2]);k++) {
				System.out.println("||当前运行次数："+(k+1));
				//method=new DataProcessing(filePathnew);
				//data.inputData();
				//data.inputDivide10DataFile_randomdivide(filePathnew,k);
				method=new DataProcessing_FSSNC();
				method.inputData(filePathnew,Float.parseFloat(args[4]),numberDataCindex);
				method.inputDivide10DataFile_randomdivide(filePathnew,k);
				FSSNC data=new FSSNC();
				int num=9;  //num 加的次数		
				for(int i=0;i<=num;i++) {
					if(i!=0) {
//						method=new DataProcessing_FSSNC(method.getFilePath(),method.getU(),method.getUSize(),method.getCName(),method.getDataArray(),method.getReduce(),method.getΣ(),method.getNumberDataCindex(),method.getDividedata(),method.getProcessingResultList());
//						method.inputData_divideAddPart(i);
						method.inputData_divideAdd(i);
					}else method.inputData_divideInitial(1);//将几份数据作为原始数据
//					ArrayList<Sample> testAllU=new ArrayList<Sample>(data.getU().size()+data.getNewU().size());
//					testAllU.addAll(data.getU());testAllU.addAll(data.getNewU());
					System.out.println("---------U+newU的第"+i+"次实际约简结果-----------");
					start = System.currentTimeMillis();
					StaticReduceResult result=data.FSSNCReduce(method.getU(),method.getΣ(),method.getCName(),numberDataCindex);
					end = System.currentTimeMillis();
					times=new Formatter().format("%.2f", ((double)(end-start)/1000)).toString();			
					System.out.println("||程序运行时间："+(end-start)+"ms,即"+times+"s");
					System.out.println("||约简Reduce："+result.getReduce()+",约简数量："+result.getReduce().size());						
					method.addProcessingResult("FSSNC",dataset,missingratio,"StaticReduce",i,end-start,result.reduceClone(),result.getReduce().size(),method.getU().size(),result.getTimes());	
					method.outPutProcessingofTimesResult(result.getTimes());				
				}
				method.outPutProcessingResult();
				method.outReduceFile(method.getProcessingResultList().getLast(), k,"Static");
			}	
		}
		
		//增量中的静态约简
		if(args[1].equals("StaticReduce")) {  //原Incremental
			System.out.println("||FSSNC增量中的静态约简程序开始，运行次数："+Integer.parseInt(args[2]));
			for(int k=0;k<Integer.parseInt(args[2]);k++) {
				System.out.println("||当前运行次数："+(k+1));
				DataProcessing_FSSNC method2=new DataProcessing_FSSNC(filePathnew);
				FSSNC data2=new FSSNC();
				//method.inputData(filePathnew,(float)0.3,numberDataCindex);
				method.inputData(filePathnew,Float.parseFloat(args[4]),numberDataCindex);
				//method.inputExchangeIncomplete(filePathnew, 0.05, 1);
				//method2.inputData();
				method2.inputDivide10DataFile_randomdivide(filePathnew,k);
				method2.inputData_divideInitial(1);   //将几份数据作为原始数据
				//初始约简	
				start = System.currentTimeMillis();
				StaticReduceResult previousResult2=data2.FSSNCReduce(method.getU(),method.getΣ(),method.getCName(),numberDataCindex);
				end = System.currentTimeMillis();
				times=new Formatter().format("%.2f", ((double)(end-start)/1000)).toString();		
				System.out.println("||程序运行时间："+(end-start)+"ms,即"+times+"s");
				System.out.println("||约简Reduce:"+previousResult2.getReduce().toString()+",约简数量:"+previousResult2.getReduce().size());
				method2.addProcessingResult("FSSNC",dataset,missingratio,"IncrementalReduce",0,end-start,previousResult2.reduceClone(),previousResult2.getReduce().size(),method2.getU().size(),previousResult2.getTimes());		
				method2.outPutProcessingofTimesResult(previousResult2.getTimes());
				//List<Integer> Reduceclone=new ArrayList<>(Reduce.size());for(int a:Reduce) Reduceclone.add(a);
		
				int num=9;  //num<8  加的次数		
				for(int i=0;i<num;i++) {
					method.inputData_divideAdd(i+1);
					System.out.println("---------U的第"+i+"次约简结果-----------");
					start = System.currentTimeMillis();
					previousResult2=data2.FSSNCReduce(method.getU(),method.getΣ(),method.getCName(),numberDataCindex);
					end = System.currentTimeMillis();
					times=new Formatter().format("%.2f", ((double)(end-start)/1000)).toString();					
					System.out.println("||程序运行时间："+(end-start)+"ms,即"+times+"s");
					System.out.println("||约简Reduce:"+previousResult2.getReduce().toString()+",约简数量:"+previousResult2.getReduce().size()+",usize:"+method.getU().size());	
					method2.addProcessingResult("FSSNC",dataset,missingratio,"IncrementalReduce",i+1,end-start,previousResult2.reduceClone(),previousResult2.getReduce().size(),method2.getU().size(),previousResult2.getTimes());
					method2.outPutProcessingofTimesResult(previousResult2.getTimes());
				}
				//data2.outPutProcessingResult();
				method2.outPutProcessingResult();				
				method2.outReduceFile(method2.getProcessingResultList().getLast(), k,"Incremental");
			}		
		}
		
		//测试数据
//		FSSNC method=new FSSNC();
//		float[][] data1= {{1,1,1,1,1},
//				       {2,2,-1,2,1},
//				       {2,-1,-1,2,2},
//				       {1,1,-1,1,2},
//				       {3,-1,-1,1,2},
//				       {1,2,1,1,-1},
//				       {1,1,1,1,1},
//				       {1,2,2,2,1},
//				       {3,2,2,2,1},
//				       {1,1,-1,1,2},				       
//				       {1,1,1,-1,1},
//				       {3,-1,-1,2,2}
//				       };
//		ArrayList<Sample> u=new ArrayList<Sample>(data1.length);
//		int i=1;
//		for(float[]datalist:data1) {
//			//List<Integer> empty=Arrays.stream(datalist).filter(a->a==-1).boxed().collect(Collectors.toList());
//			Sample x=new Sample(i++,datalist);
//			u.add(x);
//		}		
//		//data.inputData();
//		//data.setU(u);
//		method.U=u;
//		method.CName=new IntArrayKey(4).key();
//		method.numberDataCindex=new int[]{};
//		method.FSSNCReduce(u, (float)0.3, method.numberDataCindex);
//		System.out.println("初始约简："+method.Reduce);
	}
}

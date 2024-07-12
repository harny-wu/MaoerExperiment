package main.test.IFSICE;

import java.util.ArrayList;
import java.util.Formatter;

import main.Log4jPrintStream;
import main.basic.model.Sample;
import main.java.IFSICE.algorithm.IFSICE;
import main.java.IFSICE.entity.StaticReduceResult;
import main.test.DataProcessing.DataProcessing;

public class IFSICEReduce {
	// 参数设置
	static {
		Log4jPrintStream.redirectSystemOut();
	}

	// args={文件名,"算法运行类别","运行次数",结果输出目录}，其中算法运行类别包括：StaticReduce静态约简、IncrementalReduce增量约简
	public static void main(String[] args) {
		// 数据处理
		// String
		// filePathnew="C:\\Users\\凌Y\\Desktop\\数据挖掘学习\\测试数据\\测试数据_INEC\\hepatitis.csv";//wine_km_1,horse-colic_km,spambase_km_1;audiology_standardized
		// //运行一个文件
		// String
		// filePathnew="C:\\Users\\凌Y\\Desktop\\数据挖掘学习\\测试数据\\测试数据_INEC\\chess\\chess.csv";
		// //运行一个文件夹
		String filePathnew = args[0];
		String dataset = args[0].substring(args[0].lastIndexOf("\\"), args[0].lastIndexOf("."));
		DataProcessing data = new DataProcessing(filePathnew);
		String missingratio = args[6];
		long start = System.currentTimeMillis();
		long end = System.currentTimeMillis();
		String times;
		// data.inputData();
		// data.inputDivide10DataFile(filePathnew);

		// 静态约简
		if(args[1].equals("StaticReduce")) {
			System.out.println("||IFSICE静态约简程序开始，运行次数："+Integer.parseInt(args[2]));
			for(int k=0;k<Integer.parseInt(args[2]);k++) {
				System.out.println("||当前运行次数："+(k+1));
				data=new DataProcessing(filePathnew);
				data.inputData();
				data.inputDivide10DataFile_randomdivide(filePathnew,k);
				IFSICE method=new IFSICE();
				int num=9;  //num 加的次数		
				for(int i=0;i<=num;i++) {
					if(i!=0)
						data.inputData_divideAdd(i);
					else data.inputData_divideInitial(1);//将几份数据作为原始数据
					ArrayList<Sample> testAllU=new ArrayList<Sample>(data.getU().size()+data.getNewU().size());
					testAllU.addAll(data.getU());testAllU.addAll(data.getNewU());
					System.out.println("---------U+newU的第"+i+"次实际约简结果-----------");
					start = System.currentTimeMillis();
					StaticReduceResult result=method.staticReduce_IFSICE((ArrayList<Sample>)data.getU(), data.getCName());
					end = System.currentTimeMillis();
					times=new Formatter().format("%.2f", ((double)(end-start)/1000)).toString();			
					System.out.println("||程序运行时间："+(end-start)+"ms,即"+times+"s");
					System.out.println("||约简Reduce："+result.getOldReduce()+",约简数量："+result.getOldReduce().size());						
					data.getU().addAll(data.getNewU());
					data.addProcessingResult("IFSICE",dataset,missingratio,"StaticReduce",i,end-start,result.reduceClone(),result.getOldReduce().size(),data.getU().size(),result.getTimes());	
					data.outPutProcessingofTimesResult(result.getTimes());				
				}
				data.outPutProcessingResult();
				data.outReduceFile(data.getProcessingResultList().getLast(), k,"Static");
			}	
		}
		// 增量约简
		if (args[1].equals("IncrementalReduce")) {
			System.out.println("||IFSICE动态约简程序开始，运行次数：" + Integer.parseInt(args[2]));
			for (int k = 0; k < Integer.parseInt(args[2]); k++) {
				System.out.println("||当前运行次数：" + (k + 1));
				DataProcessing data2 = new DataProcessing(filePathnew);
				data2.inputData();
				data2.inputDivide10DataFile_randomdivide(filePathnew, k);
				// data2.divideDatato10_add(data2.getDataArray());
				data2.inputData_divideInitial(1); // 将几份数据作为原始数据
				IFSICE method2 = new IFSICE();
				IFSICE method3 = new IFSICE();
				start = System.currentTimeMillis();
				StaticReduceResult previousResult2 = method2.staticReduce_IFSICE((ArrayList<Sample>) data2.getU(),
						data2.getCName());
				end = System.currentTimeMillis();
				times = new Formatter().format("%.2f", ((double) (end - start) / 1000)).toString();
				System.out.println("||程序运行时间：" + (end - start) + "ms,即" + times + "s");
				System.out.println("||约简Reduce：" + previousResult2.getOldReduce() + ",约简数量："
						+ previousResult2.getOldReduce().size());
				data2.addProcessingResult("IFSICE", dataset, missingratio, "IncrementalReduce", 0, end - start,
						previousResult2.reduceClone(), previousResult2.getOldReduce().size(), data2.getU().size(),
						previousResult2.getTimes());
				data2.outPutProcessingofTimesResult(previousResult2.getTimes());
				int num = 9; // num<8 加的次数
				for (int i = 0; i < num; i++) {
					data2.inputData_divideAdd(i + 1);
//					ArrayList<Sample> testAllU=new ArrayList<Sample>(data2.getU().size()+data2.getNewU().size());
//					testAllU.addAll(data2.getU());testAllU.addAll(data2.getNewU());
//					//method2.U=testAllU;method2.CName=method.CName;method2.USize=method.U.size();
//					System.out.println("---------U+newU的第"+i+"次实际约简结果-----------");
//					start = System.currentTimeMillis();
//					StaticReduceResult previousResult3=method3.staticReduce_IFSICE(testAllU, data2.getCName());
//					end = System.currentTimeMillis();
//					times=new Formatter().format("%.2f", ((double)(end-start)/1000)).toString();
//					System.out.println("程序运行时间："+(end-start)+"ms,即"+times+"s");
//					System.out.println("实际约简："+previousResult3.getOldReduce()+"约简数量："+previousResult3.getOldReduce().size()+" usize:"+testAllU.size());

					System.out.println("---------U+newU的第" + i + "次增量约简结果-----------");
					start = System.currentTimeMillis();
					previousResult2 = method2.IFSICEReduce_Incremental((ArrayList<Sample>) data2.getU(),
							(ArrayList<Sample>) data2.getNewU(), data2.getCName(), previousResult2);
					end = System.currentTimeMillis();
					times = new Formatter().format("%.2f", ((double) (end - start) / 1000)).toString();
//					System.out.println("||程序运行时间：" + (end - start) + "ms,即" + times + "s");
//					System.out.println("||约简Reduce：" + previousResult2.getOldReduce() + ",约简数量："
//							+ previousResult2.getOldReduce().size() + ",usize:" + data2.getU().size());
//					data2.addProcessingResult("IFSICE", dataset, missingratio, "IncrementalReduce", i + 1, end - start,
//							previousResult2.reduceClone(), previousResult2.getOldReduce().size(), data2.getU().size(),
//							previousResult2.getTimes());
//					data2.outPutProcessingofTimesResult(previousResult2.getTimes());
					
					if(previousResult2.haveException==1) {  //得到结果后中断
						System.out.println("||程序运行时间："+(end-start)+"ms,即"+times+"s");
						System.out.println("||约简Reduce："+previousResult2.getOldReduce()+",约简数量："+previousResult2.getOldReduce().size()+",usize:"+(data2.getU().size()+data2.getNewU().size()));
						data2.addProcessingResult("IFSICE",dataset,missingratio,"IncrementalReduce",i+1,end-start,previousResult2.reduceClone(),previousResult2.getOldReduce().size(),(data2.getU().size()+data2.getNewU().size()),previousResult2.getTimes());		
						data2.outPutProcessingofTimesResult(previousResult2.getTimes());
						System.out.println("||Java堆溢出，该轮结束");
						break;
					}else if(previousResult2.haveException==2){  //没得到结果中断
						data2.outPutProcessingofTimesResult(previousResult2.getTimes());
						System.out.println("||Java堆溢出，该轮结束");
						break;
					}else if(previousResult2.haveException==0) {   //正常运行
						System.out.println("||程序运行时间："+(end-start)+"ms,即"+times+"s");
						System.out.println("||约简Reduce："+previousResult2.getOldReduce()+",约简数量："+previousResult2.getOldReduce().size()+",usize:"+data2.getU().size());
						data2.addProcessingResult("IFSICE",dataset,missingratio,"IncrementalReduce",i+1,end-start,previousResult2.reduceClone(),previousResult2.getOldReduce().size(),data2.getU().size(),previousResult2.getTimes());		
						data2.outPutProcessingofTimesResult(previousResult2.getTimes());
					}
				}
				// data2.outPutProcessingResult();
				data2.outPutProcessingResult();
				// data2.outReduceFile(data2.getProcessingResultList().getLast(), k);
				data2.outReduceFile(data2.getProcessingResultList().getLast(), k,"Incremental");
			}

		}

		// 测试数据
//		data.setCName(new IntArrayKey(4).key());
//		IFSICE method=new IFSICE();
//		int[][] data1= {{1,1,1,1,1},
//				       {2,2,-1,2,1},
//				       {2,-1,-1,2,2},
//				       {1,1,-1,1,2},
//				       {3,-1,-1,1,2},
//				       {1,2,1,1,-1}};
//		ArrayList<Sample> u=new ArrayList<Sample>(data1.length);
//		int i=1;
//		for(int[]datalist:data1) {
//			Sample x=new Sample(i++,datalist,true);
//			u.add(x);
//		}		
//		data.setU(u);
//		StaticReduceResult previousResult=method.staticReduce_IFSICE((ArrayList<Sample>)data.getU(),data.getCName());
//		System.out.println("初始约简："+previousResult.getOldReduce());
//		System.out.println("--------------------增量约简------------------------");
//		//增量		
//		int[][] data2= {{1,1,1,1,1},
//			       {1,2,2,2,1},
//			       {3,2,2,2,1},
//	               {1,1,-1,1,2},
//	               {1,1,1,-1,1},
//                 {3,-1,-1,2,2}};
//		u=new ArrayList<Sample>(data2.length);
//		int j=data.getU().size()+1;
//		for(int[]datalist:data2) {
//			Sample x=new Sample(j++,datalist,true);
//			u.add(x);
//		}		
//		data.setNewU(u);
//		method.IFSICEReduce_Incremental((ArrayList<Sample>)data.getU(), (ArrayList<Sample>)data.getNewU(),data.getCName(),previousResult);
//		System.out.println("增量约简："+previousResult.getOldReduce());
	}
}

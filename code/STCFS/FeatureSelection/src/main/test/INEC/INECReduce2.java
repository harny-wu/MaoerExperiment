package main.test.INEC;

import java.util.ArrayList;
import java.util.Formatter;

import main.Log4jPrintStream;
import main.basic.model.Sample;
import main.java.INEC.algorithm.INEC2;
import main.java.INEC.entity.equivalenceClass.StaticReduceResult;
import main.test.DataProcessing.DataProcessing;

//约简
public class INECReduce2 {
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
		DataProcessing data = new DataProcessing(filePathnew);
		String dataset = args[0].substring(args[0].lastIndexOf("\\"), args[0].lastIndexOf("."));
//		data.inputData();
//		data.divideDatato10_add(data.getDataArray());
//		data.outDivide10DataFile();
		// data.inputDivide10DataFile(filePathnew);
		String missingratio = args[6];
		long start = System.currentTimeMillis();
		long end = System.currentTimeMillis();
		String times;

		// 静态约简 ***************静态约简的结果设置和输出还没写
		if(args[1].equals("StaticReduce")) {
			System.out.println("||INEC2静态约简程序开始，运行次数："+Integer.parseInt(args[2]));
			for(int k=0;k<Integer.parseInt(args[2]);k++) {
				System.out.println("||当前运行次数："+(k+1));
				data=new DataProcessing(filePathnew);
				data.inputData();
				data.inputDivide10DataFile_randomdivide(filePathnew,k);
				INEC2 method=new INEC2();
				int num=9;  //num 加的次数		
				for(int i=0;i<=num;i++) {
					if(i!=0)
						data.inputData_divideAdd(i);
					else data.inputData_divideInitial(1);//将几份数据作为原始数据
					ArrayList<Sample> testAllU=new ArrayList<Sample>(data.getU().size()+data.getNewU().size());
					testAllU.addAll(data.getU());testAllU.addAll(data.getNewU());
					System.out.println("---------U+newU的第"+i+"次实际约简结果-----------");
					start = System.currentTimeMillis();
					StaticReduceResult result=method.INECReduce(testAllU,data.getCName());
					end = System.currentTimeMillis();
					times=new Formatter().format("%.2f", ((double)(end-start)/1000)).toString();			
					System.out.println("||程序运行时间："+(end-start)+"ms,即"+times+"s");
					System.out.println("||约简Reduce："+result.getReduce()+",约简数量："+result.getReduce().size());						
					data.getU().addAll(data.getNewU());
					data.addProcessingResult("INEC2",dataset,missingratio,"StaticReduce",i,end-start,result.reduceClone(),result.getReduce().size(),data.getU().size(),result.getSplitTimes(),result.TNECSize);	
					data.outPutProcessingofTimesResult(result.getSplitTimes());				
				}
				data.outPutProcessingResult_INEC();
				data.outReduceFile(data.getProcessingResultList().getLast(), k,"Static");
			}	
		}

		// add_sample_divide
		if (args[1].equals("IncrementalReduce")) {
			System.out.println("||INEC2动态约简程序开始，运行次数：" + Integer.parseInt(args[2]));
			for (int k = 0; k < Integer.parseInt(args[2]); k++) {
				System.out.println("||当前运行次数：" + (k + 1));
				DataProcessing data2 = new DataProcessing(filePathnew);
				data2.inputData();
				// data2.divideDatato10_add(data2.getDataArray());
				data2.inputDivide10DataFile_randomdivide(filePathnew, k);
				data2.inputData_divideInitial(1); // 将几份数据作为原始数据
				INEC2 method2 = new INEC2();
				INEC2 method3 = new INEC2();
				start = System.currentTimeMillis();
				StaticReduceResult previousResult2 = method2.INECReduce(data2.getU(), data2.getCName());
				end = System.currentTimeMillis();
				times = new Formatter().format("%.2f", ((double) (end - start) / 1000)).toString();
				System.out.println("||程序运行时间：" + (end - start) + "ms,即" + times + "s");
				System.out.println(
						"||约简Reduce：" + previousResult2.getReduce() + ",约简数量：" + previousResult2.getReduce().size());
				data2.addProcessingResult("INEC2", dataset, missingratio, "IncrementalReduce", 0, end - start,
						previousResult2.reduceClone(), previousResult2.getReduce().size(), data2.getU().size(),
						previousResult2.getSplitTimes(), previousResult2.TNECSize);
				data2.outPutProcessingofTimesResult(previousResult2.getSplitTimes());
				int num = 9; // num<8 加的次数
				for (int i = 0; i < num; i++) {
					data2.inputData_divideAdd(i + 1);
//					ArrayList<Sample> testAllU=new ArrayList<Sample>(data2.getU().size()+data2.getNewU().size());
//					testAllU.addAll(data2.getU());testAllU.addAll(data2.getNewU());
////					method2.U=testAllU;method2.CName=method.CName;method2.USize=method2.U.size();
//					System.out.println("---------U+newU的第"+i+"次实际约简结果-----------");
//					start = System.currentTimeMillis();	
//					StaticReduceResult previousResult3=method3.INECReduce(testAllU, data2.getCName());
//					end = System.currentTimeMillis();
//					times=new Formatter().format("%.2f", ((double)(end-start)/1000)).toString();
//					System.out.println("程序运行时间："+(end-start)+"ms,即"+times+"s");
//					System.out.println("实际约简："+previousResult3.getReduce()+"约简数量："+previousResult3.getReduce().size());
//					data2.getU().addAll(data2.getNewU());

					System.out.println("---------U+newU的第" + i + "次增量约简结果-----------");
					start = System.currentTimeMillis();
					previousResult2 = method2.INECReduce_addSample_te(data2.getU(), data2.getNewU(), data2.getCName(),
							previousResult2);
					end = System.currentTimeMillis();
					times = new Formatter().format("%.2f", ((double) (end - start) / 1000)).toString();
					System.out.println("||程序运行时间：" + (end - start) + "ms,即" + times + "s");
					System.out.println("||约简Reduce：" + previousResult2.getReduce() + ",约简数量："
							+ previousResult2.getReduce().size() + ",usize:" + data2.getU().size());
					data2.addProcessingResult("INEC2", dataset, missingratio, "IncrementalReduce", i + 1, end - start,
							previousResult2.reduceClone(), previousResult2.getReduce().size(), data2.getU().size(),
							previousResult2.getSplitTimes(), previousResult2.TNECSize);
					data2.outPutProcessingofTimesResult(previousResult2.getSplitTimes());

				}
				// data2.outPutProcessingResult();
				data2.outPutProcessingResult_INEC();
				// data2.outReduceFile(data2.getProcessingResultList().getLast(), k);
				data2.outReduceFile(data2.getProcessingResultList().getLast(), k,"Incremental");
			}

		}

		// 测试数据
//		data.setCName(new IntArrayKey(4).key());;
//		int[][] data1= {{1,1,1,1,1},
//				       {2,2,-1,2,1},
//				       {2,-1,-1,2,2},
//				       {1,1,-1,1,2},
//				       {3,-1,-1,1,2},
//				       {1,2,1,1,-1}};
//		Collection<Sample> u=new ArrayList<Sample>(data1.length);
//		int i=1;
//		for(int[]datalist:data1) {
//			List<Integer> empty=Arrays.stream(datalist).filter(a->a==-1).boxed().collect(Collectors.toList());
//			Sample x=new Sample(i++,datalist,empty.size()>0);
//			u.add(x);
//		}		
//		//data.inputData();
//		data.setU(u);
//		INEC method=new INEC();
//		StaticReduceResult previousResult=method.INECReduce(data.getU(), data.getCName());
//		System.out.println("初始约简："+previousResult.getReduce());
//		System.out.println("--------------------增量约简------------------------");
//		//增量		
//		int[][] data2= {{1,1,1,1,1},
//			       {1,2,2,2,1},
//			       {3,2,2,2,1},
//			       {1,1,-1,1,2},
//			       {1,1,1,-1,1},
//                   {3,-1,-1,2,2}
//			       };
//		u=new ArrayList<Sample>(data2.length);
//		int j=data.getU().size()+1;
//		for(int[]datalist:data2) {
//			List<Integer> empty=Arrays.stream(datalist).filter(a->a==-1).boxed().collect(Collectors.toList());
//			Sample x=new Sample(i++,datalist,empty.size()>0);
//			u.add(x);
//		}		
//		data.setNewU(u);
//		previousResult=method.INECReduce_addSample_te(data.getU(), data.getNewU(), data.getCName(), previousResult);
//		System.out.println("增量约简："+previousResult.getReduce());

		// add_sample2
//		String filePath_add_2="C:\\Users\\凌Y\\Desktop\\test4_add.csv";
//		method.inputData_add(filePath_add_2);
//		//method.inputData_divideAdd(2);
//		Reduce=method.INECReduce_addSample_te(method.getUad(), method.getInitial_te(), method.gettEList(), method.getReduce());
//		System.out.print("add_sample约简为:{");
//		for(int a:Reduce)
//			System.out.print(a+"  ");
//		System.out.println("}");

		// delete_sample
//		String filePath_delete="C:\\Users\\凌Y\\Desktop\\test4_delete.txt";
//		method.inputData_delete(filePath_delete);
//		Reduce=method.INECReduce_deleteSample(method.getUde(), method.getInitial_te(), method.gettEList(), method.getReduce());
//		System.out.print("delete_sample约简为:{");
//		for(String a:Reduce)
//			System.out.print(a+"  ");
//		System.out.println("}");

		// delete_sample_divide
//		start = System.currentTimeMillis();		
//		int num2=5;  //num2<8  减的次数		
//		for(int i=0;i<num2;i++) {
//			method.inputData_divideDelete(i);
//			Reduce=method.INECReduce_deleteSample(method.getUde(), method.getInitial_te(), method.gettEList(), method.getReduce());
//			System.out.print("delete_sample"+i+"约简为:{");
//			for(int a:Reduce)
//				System.out.print(a+"  ");
//			System.out.println("}");
//		}
//		end = System.currentTimeMillis();
//		times=new Formatter().format("%.2f", ((double)(end-start)/1000)).toString();
//		System.out.println("程序运行时间："+(end-start)+"ms,即"+times+"s");
//		method.outReduceFile();

		// multi_sample
//		String filePath_multi_add="C:\\Users\\凌Y\\Desktop\\test3_add.txt";
//		String filePath_multi_delete="C:\\Users\\凌Y\\Desktop\\test3_delete.txt";
//		method.inputData_multi(filePath_multi_add,filePath_multi_delete);
//		Reduce=method.INECReduce_multiSample(method.getUad(),method.getUde(), method.getInitial_te(), method.gettEList(), method.getReduce());
//		System.out.print("multi_sample约简为:{");
//		for(String a:Reduce)
//			System.out.print(a+"  ");
//		System.out.println("}");

		// delete_Attribute
//		String filePath_deleteAttribute="C:\\Users\\凌Y\\Desktop\\test4_deleteAttribute.txt";
//		method.inputData_deleteAttribute(filePath_deleteAttribute);
//		Reduce=method.INECReduce_deleteAttribute(method.getCde(),method.getInitial_te(), method.gettEList(), method.getReduce());
//		System.out.print("deleteAttribute约简为:{");
//		for(String a:Reduce)
//			System.out.print(a+"  ");
//		System.out.println("}");
	}
}

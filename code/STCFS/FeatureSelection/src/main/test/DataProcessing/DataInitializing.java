package main.test.DataProcessing;

import main.Log4jPrintStream;
import main.java.FSSNC.algorithm.DataProcessing_FSSNC;
import main.java.FSSNC.algorithm.FSSNC;

public class DataInitializing {
	static {
		Log4jPrintStream.redirectSystemOut();
	}

	public static void main(String[] args) {
		// 数据处理
//		String filePathnew="C:\\Users\\凌Y\\Desktop\\数据挖掘学习\\测试数据\\测试数据_INEC\\40%_MissingValue\\advertisements\\advertisements.csv";//wine_km_1,horse-colic_km,spambase_km_1;audiology_standardized
//		//String filePathnew="C:\\Users\\凌Y\\Desktop\\数据挖掘学习\\测试数据\\测试数据_INEC\\mushroom\\mushroom.csv";
//		DataProcessing data=new DataProcessing(filePathnew);
//		long start = System.currentTimeMillis();
//		long end = System.currentTimeMillis();
//		String times;
//		data.inputData();	
//		data.inputExchangeIncomplete(0.4, 1);//文件，选取0.05变为*，计算1次	
//		data.inputData();	
//		data.divideDatato10_add_other(data.getDataArray());
//		data.divideDatato10_random(data.getDataArray());
//		for(int i=0;i<10;i++)
//			data.inputDivide10DataFile_randomdivide(filePathnew, 0);
//		data.outDivide10DataFile();			
//		//data.inputDivide10DataFile(filePathnew);
////		data.inputExchangeIncomplete(0.05, 1);//文件，选取0.05变为*，计算1次	
////		data.divideDatato10_add(data.getDataArray());//将所有数据划分为10part，其中2part作为初始数据
////		data.divideHalfDatato10(data.getDataArray());//讲一半数据作为初始数据，另一半划分成十份

		// 数据处理 选百分之x的数据转化为*并将其划分为10份输出
//		int[] num = { 5,10,15,20,25,30,35,40};//
//		// String filename = "orlraws10P_MDLP";
//		String[] filelist = {"PIE10P", "Prostate_GE","AR10P", "Dexter", "lung", "optdigits-orig", "orlraws10P_MDLP","madelon","qsar_androgen_receptor", "pd_speech_features", "gisette_MDLP","PhishingWebsites","letter","eeg-eye-state","nomao","bank-marketing"};// "GLI_85", "BASEHOCK", "Isolet", "nci9", "nursery",
//																// "PCMAC", "PIE10P",
//		// "Prostate_GE",
//		// "AR10P", "Dexter", "lung", "optdigits-orig", "orlraws10P_MDLP",
//		// "leukemia","madelon",
//		// "qsar_androgen_receptor", "pd_speech_features", "car", "gisette_MDLP",
//		// "gisette", "orlraws10P","advertisements", "advertisements_MDLP",
//		// "breast-cancer-wisconsin", "horse-colic","mushroom"
//		// "PhishingWebsites","letter"
//		for (String file : filelist) {
//			String filename = file;
//			for (int i = 0; i < num.length; i++) {
//				String filePathnew = "C:\\Users\\Administrator\\Desktop\\dataset\\测试数据_INEC\\" + num[i]
//						+ "%_MissingValue\\" + filename + "\\" + filename + ".csv";
//				DataProcessing data = new DataProcessing(filePathnew);
//				data.inputData();
//				data.inputExchangeIncomplete((double) num[i] / (double) 100, 1);//
//				// 文件，选取0.05变为*，计算1次
//				data.inputData();
////				data.divideDatato10_add_other(data.getDataArray()); //划分一次10份不一样数据
////				data.outDivide10DataFile();
//				data.divideDatato10_random(data.getDataArray()); // 随机划分10次不一样增量数据集
//			}
//		}
		//FSSNC数据
//		int[] num= {5,10,20};
//		String[] filelist = { "hepatitis_missingFill","audiology_missingFill","horse-colic_MDLP_missingFill","breast-cancer-wisconsin_missingFill","advertisements_missingFill","mushroom_missingFill","leukemia","pd_speech_features","tic-tac-toe","madelon","chess","orlraws10P_MDLP","Prostate_GE","AR10P","lung","PIE10P","Dexter","qsar_androgen_receptor","optdigits-orig","gisette_MDLP"};
//		for (String file : filelist) {
//			String filename = file;
//			for (int i = 0; i < num.length; i++) {
//				String filePathnew = "C:\\Users\\Administrator\\Desktop\\dataset\\测试数据_INEC\\" + num[i]
//						+ "%_MissingValue\\" + filename + "_normlized\\" + filename + "_normlized.csv"; //_normlized
//				DataProcessing_FSSNC data = new DataProcessing_FSSNC(filePathnew);
//				data.inputData(filePathnew, i, null);
//				data.inputExchangeIncomplete(filePathnew,((double)num[i]/(double)100),1);//文件，选取0.05变为*，计算1次
//				data.inputData(filePathnew, i, null);
//				data.divideDatato10_random(data.getDataArray());
//				//data.divideDatato10_add_other(data.getDataArray());
//				// data.outDivide10DataFile();
//			}
//		}
		
		// 数据处理 选百分之x的数据获得十次随机划分十份的数据结果输出
		//int[] num = { 5, 10, 15, 20};//
//		String[] filelist = {
//                "0101_0131_all_feature", "0101_0131_all_feature_involved",
//                "0115_0215_all_feature", "0115_0215_all_feature_involved",              
//                "0201_0230_all_feature", "0201_0230_all_feature_involved",
//                "1101_1130_all_feature", "1101_1130_all_feature_involved",
//                "1115_1215_all_feature", "1115_1215_all_feature_involved",
//                "1201_1231_all_feature", "1201_1231_all_feature_involved",
//                "1215_0115_all_feature", "1215_0115_all_feature_involved"};
		String[] filelist = {"51_long_feature_201706_201708"};
		//String[] filelist = {"k_1_8s_sim","k_3_8s_sim","k_1_15s_sim","k_3_15s_sim","k_2_8s_sim_q_1_num","k_2_8s_sim_q_2_num","k_2_8s_sim_q_3_num","k_2_15s_sim_q_1_num","k_2_15s_sim_q_2_num","k_2_15s_sim_q_3_num","all_8_sim","all_15_sim","k_2_8s_sim","k_2_15s_sim"};//"all_8_sim","all_15_sim","k_2_8s_sim","k_2_15s_sim"
		for (String file : filelist) {
			String filename = file;
			//for (int i = 0; i < num.length; i++) {
				//String filePathnew = "/Users/ly/Desktop/工作/大论文/数据/量化方法实验/" + filename + "/" + filename + ".csv";
				String filePathnew = "/Users/daidaiwu/学校/大论文/MaoerExperiment/data/FS/0101-1031/k_2_15s_sim_q_1_num/kmean/(Seq) 0101_0131_all_feature_involved_all_deal(D=kmean3).csv";
//				String filePathnew = "C:\\Users\\Administrator\\Desktop\\dataset\\测试数据_INEC\\" + num[i]
//						+ "%_MissingValue\\" + filename + "\\" + filename + ".csv";
				DataProcessing data = new DataProcessing(filePathnew);
				data.inputData();
//				data.inputExchangeIncomplete((double)num[i]/(double)100,1);//文件，选取0.05变为*，计算1次
//				data.inputData();
				data.divideDatato10_random(data.getDataArray());
				// data.divideDatato10_add_other(data.getDataArray());
				// data.outDivide10DataFile();
			//}
		}

		// 静态约简
//		List<Integer> Reduce=new LinkedList<Integer>();
//		//调用约简程序
//		start = System.currentTimeMillis();
//		
//		end = System.currentTimeMillis();
//		//输出至文档		
//		System.out.println(Reduce.toString());
//		times=new Formatter().format("%.2f", ((double)(end-start)/1000)).toString();
//		System.out.println("程序运行时间："+(end-start)+"ms,即"+times+"s");
//		data.outReduceFile(Reduce);		
//		
//		//增量约简
//		data.inputData_divideInitial(2);   //将几份数据作为原始数据
//		DataProcessing data2=new DataProcessing(filePathnew);
//		data2.inputData();
//		data2.divideDatato10_add(data2.getDataArray());
//		data2.inputData_divideInitial(2);   //将几份数据作为原始数据
//		DIDS method2=new DIDS();
//		DIDS method3=new DIDS();
//		StaticReduceResult previousResult2=method2.staticReduce_DIDS(data2.getU(), data2.getCName().length);
//		System.out.println("初始约简："+previousResult2.getReduce());
//		start = System.currentTimeMillis();		
//		int num=8;  //num<8  加的次数		
//		for(int i=0;i<num;i++) {
//			data2.inputData_divideAdd(i+2);
//			ArrayList<Sample> testAllU=new ArrayList<Sample>(data2.getU().size()+data2.getNewU().size());
//			testAllU.addAll(data2.getU());testAllU.addAll(data2.getNewU());
////			method2.U=testAllU;method2.CName=method.CName;method2.USize=method2.U.size();
//			System.out.println("---------U+newU的第"+i+"次实际约简结果-----------");
////			StaticReduceResult previousResult3=method3.staticReduce_CFSV(testAllU, data2.getCName().length);
//			System.out.println("实际约简结果："+Reduce.toString()+"数量："+Reduce.size());
//			System.out.println("---------U+newU的第"+i+"次增量约简结果-----------");
////			previousResult2=method2.DIDSReduce(data2.getU(), data2.getNewU(),data2.getCName().length, previousResult2);
//			//data2.setUSize(data2.getU().size());
//			System.out.println("增量约简结果："+Reduce.toString()+"数量："+Reduce.size());
//		}
//		
	}
}

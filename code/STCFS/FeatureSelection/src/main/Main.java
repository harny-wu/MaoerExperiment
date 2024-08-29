package main;

import main.test.DIDS.DIDSReduce;
import main.test.FSMV.FSMVReduce;
import main.test.FSSNC.FSSNCReduce;
import main.test.IFSICE.IFSICEReduce;
import main.test.INEC.INECReduce2;
import main.test.INEC.INECReduce2_threepart_simu;
import main.test.INEC.INECReduce2_threepart_turn;

//实验总程序
public class Main {
	// static Logger logger = Logger.getLogger(Main.class);
	static {
		Log4jPrintStream.redirectSystemOut();
	}

	public static void main(String[] args) {
		// 参数设置
		// args={文件名,"算法运行类别","运行次数","结果输出目录"}，其中算法运行类别包括：StaticReduce静态约简、IncrementalReduce增量约简
		// String[] parameter=args;
		// 运行的数据集

		// try {
		// 1 测试一个数据集
		// String[] datasetNames= {"hepatitis"};
		// String Path="C:\\Users\\凌Y\\Desktop\\数据挖掘学习\\测试数据\\测试数据_INEC"; //5%~40% &
		// noadd_MissingValue(FSSNC)
		// 2 整体实验运行 jar版
//		String missingratio = args[0]; // 加百分号
//		String[] datasetNames = new String[args.length - 1];
//		for (int i = 0; i < args.length - 1; i++)
//			datasetNames[i] = args[i + 1];
//		String Path = "C:\\Users\\Administrator\\Desktop\\dataset\\测试数据_INEC\\" + missingratio + "_MissingValue";
		// 3 整体实验运行 eclipse版
//		String[] datasetNames = {
//		                "0101_0131_all_feature", "0101_0131_all_feature_involved",
//		                "0115_0215_all_feature", "0115_0215_all_feature_involved",              
//		                "0201_0230_all_feature", "0201_0230_all_feature_involved",
//		                "1101_1130_all_feature", "1101_1130_all_feature_involved",
//		                "1115_1215_all_feature", "1115_1215_all_feature_involved",
//		                "1201_1231_all_feature", "1201_1231_all_feature_involved",
//		                "1215_0115_all_feature", "1215_0115_all_feature_involved"}; // "GLI_85","BASEHOCK","car","Isolet","leukemia","madelon","nci9","nursery","orlraws10P","PCMAC","qsar_androgen_receptor","gisette",		
		String[] datasetNames ={"FS-(Math3-KMeans++ discreted k=5) 0101_0131_all_feature_FS_divideType_k_2_15s_sim_q_1_num"};
		//String[] datasetNames = {"k_1_8s_sim","k_3_8s_sim","k_1_15s_sim","k_3_15s_sim","k_2_8s_sim_q_1_num","k_2_8s_sim_q_2_num","k_2_8s_sim_q_3_num","k_2_15s_sim_q_1_num","k_2_15s_sim_q_2_num","k_2_15s_sim_q_3_num","all_8_sim","all_15_sim","k_2_8s_sim","k_2_15s_sim"};//"all_8_sim","all_15_sim","k_2_8s_sim","k_2_15s_sim"
		//"breast-cancer-wisconsin","horse-colic","advertisements_MDLP","mushroom","audiology","hepatitis"
		//"hepatitis_missingFill","audiology_missingFill","horse-colic_MDLP_missingFill","breast-cancer-wisconsin_missingFill","advertisements_missingFill","mushroom_missingFill"
		//"leukemia","pd_speech_features","tic-tac-toe","madelon","chess","orlraws10P_MDLP","Prostate_GE","AR10P","lung","PIE10P","Dexter","qsar_androgen_receptor","optdigits-orig","gisette_MDLP"
		//"eeg-eye-state","nomao","bank-marketing","PhishingWebsites","letter"
		//仅FSSNC："hepatitis_missingFill","audiology_missingFill","horse-colic_MDLP_missingFill","breast-cancer-wisconsin_missingFill","leukemia","tic-tac-toe","chess","orlraws10P_MDLP","Prostate_GE","AR10P","lung","PIE10P","pd_speech_features"
		String missingratio = "10%";
		// String Path = "C:\\Users\\Administrator\\Desktop\\dataset\\测试数据_INEC\\" + missingratio + "_MissingValue";
		String Path = "/Users/daidaiwu/学校/大论文/MaoerExperiment/data/0101_0131_all_feature_FS/";
		//String Path = "/Users/ly/Desktop/工作/大论文/数据/量化方法实验/";
		for (int i = 0; i < datasetNames.length; i++) {
			String filePath = Path + "/" + datasetNames[i] +  ".csv";
			String FSSNCfilePath=Path + datasetNames[i]+"_normlized.csv";
			String[] parameter = { filePath, // 文件名
												// 例："C:\\Users\\凌Y\\Desktop\\数据挖掘学习\\测试数据\\测试数据_INEC\\hepatitis\\hepatitis.csv"
					"IncrementalReduce", // 算法运行类别
					"10", // 运行次数
					Path, // 结果输出目录 例"C:\\Users\\凌Y\\Desktop\\数据挖掘学习\\测试数据\\测试数据_INEC"
					"0.3", // 算法FSSNC 参数sigma
					"", // 算法FSSNC number类型属性下标集合(int[]) String
					missingratio,
					FSSNCfilePath
					};
			System.out.println("================程序开始===================");
			System.out.println("||参数设置：");
			System.out.println("||文件名：" + parameter[0]);
			System.out.println("||数据缺失比例：" + parameter[6]);
			System.out.println("||算法运行类别：" + parameter[1]);
			System.out.println("||需要运行次数：" + parameter[2]);
			System.out.println("||结果输出目录：" + parameter[3]);
			System.out.println("||FSSNC算法参数：" + parameter[4] + "number类型属性下标集合" + parameter[5]);
			//System.out.println("================INECReduce开始===================");
			//INECReduce.main(parameter);
			//System.out.println("================INECReduce_noRedundance开始===================");
			// INECReduce_noRedundance.main(parameter);
			System.out.println("================INECReduce2开始===================");
			//INECReduce2.main(parameter);
			System.out.println("================INECReduce2_threepart_simu开始===================");
			INECReduce2_threepart_simu.main(parameter);
			//System.out.println("================INECReduce2_threepart_turn开始===================");
			//INECReduce2_threepart_turn.main(parameter);
			System.out.println("===============IFSICEReduce开始==================");
			//IFSICEReduce.main(parameter);
			System.out.println("================DIDSReduce开始===================");
			//DIDSReduce.main(parameter);
			System.out.println("================FSMVReduce开始===================");
			//FSMVReduce.main(parameter);
			System.out.println("================FSSNCReduce开始==================");
			//FSSNCReduce.main(parameter);
			System.out.println("=================" + datasetNames[i] + "程序运行结束===================");
		}
//		} catch (Exception e) {
//			logger.info(e.getMessage(),e);
//			logger.error(e.getMessage(),e);
//		}
	}
}

package main.test.KGIRA;

import java.util.Formatter;
import java.util.List;

import main.java.KGIRA.algorithm.KGIRA;


public class KGIRAReduce {
	public static void main(String[] args) {
		//数据处理
		String filePathnew="C:\\Users\\凌Y\\Desktop\\数据挖掘学习\\测试数据\\测试数据_INEC\\wine_km_1.csv";
		KGIRA method=new KGIRA();
		method.inputData(filePathnew);
		//method.inputExchangeIncomplete(filePathnew, 0.05, 1);//文件，选取0.05变为*，计算1次	
		method.divideDatato10_add(method.dataArray);//将所有数据划分为10part，其中2part作为初始数据
		//method.divideHalfDatato10(method.dataArray);//讲一半数据作为初始数据，另一半划分成十份
		//初始约简
		long start = System.currentTimeMillis();
		long end = System.currentTimeMillis();
//		String filePath="C:\\Users\\凌Y\\Desktop\\数据挖掘学习\\测试数据\\测试数据_INEC\\wine_1.csv";
//		Method method=new Method();
//		method.inputData(filePath);
		method.inputData_divideInitial(10);   //将几份数据作为原始数据
		start = System.currentTimeMillis();
		List<Integer> Reduce=method.KGIRAReduce(method.U);
		end = System.currentTimeMillis();
		//输出Reduce
		System.out.print("初始约简为:{");
		for(int a:Reduce)
			System.out.print(a+"  ");
		System.out.println("}");
		String times=new Formatter().format("%.2f", ((double)(end-start)/1000)).toString();
		System.out.println("程序运行时间："+(end-start)+"ms,即"+times+"s");
		//method.outReduceFile();
		
		//add_sample_divide
		start = System.currentTimeMillis();		
		int num=8;  //num<8  加的次数		
		for(int i=0;i<num;i++) {
			method.inputData_divideAdd(i+2);
			Reduce=method.KGIRAReduce_addSample(method.U,method.Uad, method.GP_C, method.GP_C, method.Reduce);
			System.out.print("add_sample"+i+"约简为:{");
			for(int a:Reduce)
				System.out.print(a+"  ");
			System.out.println("}");
		}
		end = System.currentTimeMillis();
		times=new Formatter().format("%.2f", ((double)(end-start)/1000)).toString();
		System.out.println("程序运行时间："+(end-start)+"ms,即"+times+"s");
//		method.outReduceFile();
	}
}

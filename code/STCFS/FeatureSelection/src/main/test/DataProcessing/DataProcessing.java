package main.test.DataProcessing;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map.Entry;
import java.util.Random;
import java.util.Set;

import main.Log4jPrintStream;
import main.basic.model.ProcessingResult;
import main.basic.model.Sample;
import main.java.INEC.entity.equivalenceClass.TNECSizeCount;

//数据处理
public class DataProcessing {
	private Collection<Sample> U;
	private String filePath;
	private ArrayList<String[]> dataArray;
	private int[] CName;
	private int[] Cad;
	private int[] Cde;
	// private int USize;
	private HashMap<Integer, ArrayList<String[]>> dividedata;
	private Collection<Sample> newU=new ArrayList<>();
	private Collection<Sample> Ude;
	private int[] numberDataCIndex;// 有number类型数据的C的下标
	private float σ; // 参数
	private LinkedList<ProcessingResult> processingResultList = new LinkedList<>();

	static {
		Log4jPrintStream.redirectSystemOut();
	}

	public DataProcessing(String filePath) {
		this.filePath = filePath;
	}

	public Collection<Sample> getU() {
		return U;
	}

	public void setU(Collection<Sample> u) {
		U = u;
	}

	public String getFilePath() {
		return filePath;
	}

	public void setFilePath(String filePath) {
		this.filePath = filePath;
	}

	public ArrayList<String[]> getDataArray() {
		return dataArray;
	}

	public void setDataArray(ArrayList<String[]> dataArray) {
		this.dataArray = dataArray;
	}

	public int[] getCName() {
		return CName;
	}

	public void setCName(int[] cName) {
		CName = cName;
	}

//	public int getUSize() {
//		return U.size();
//	}
//	public void setUSize(int uSize) {
//		USize = uSize;
//	}
	public HashMap<Integer, ArrayList<String[]>> getDividedata() {
		return dividedata;
	}

	public void setDividedata(HashMap<Integer, ArrayList<String[]>> dividedata) {
		this.dividedata = dividedata;
	}

	public Collection<Sample> getNewU() {
		return newU;
	}

	public void setNewU(Collection<Sample> newU) {
		this.newU = newU;
	}

	public int[] getCad() {
		return Cad;
	}

	public void setCad(int[] cad) {
		Cad = cad;
	}

	public int[] getCde() {
		return Cde;
	}

	public void setCde(int[] cde) {
		Cde = cde;
	}

	public Collection<Sample> getUde() {
		return Ude;
	}

	public void setUde(Collection<Sample> ude) {
		Ude = ude;
	}

	public int[] getNumberDataCIndex() {
		return numberDataCIndex;
	}

	public void setNumberDataCIndex(int[] numberDataCIndex) {
		this.numberDataCIndex = numberDataCIndex;
	}

	public float getΣ() {
		return σ;
	}

	public void setΣ(float σ) {
		this.σ = σ;
	}

	public LinkedList<ProcessingResult> getProcessingResultList() {
		return processingResultList;
	}

	public void setProcessingResultList(LinkedList<ProcessingResult> processingResultList) {
		this.processingResultList = processingResultList;
	}

	public void addProcessingResult(ProcessingResult result) {
		this.processingResultList.add(result);
	}

	public void addProcessingResult(String algorithm, int k, long time, List<Integer> Reduce, int ReduceSize,
			int Usize) {
		ProcessingResult result = new ProcessingResult(algorithm, k, time, Reduce, ReduceSize, Usize);
		this.processingResultList.add(result);
	}

	public void addProcessingResult(String algorithm, String datasetName, String missingratio,
			String algorithmExcCategory, int k, long time, List<Integer> Reduce, int ReduceSize, int Usize,
			LinkedHashMap<String, Long> splitTimes) {
		ProcessingResult result = new ProcessingResult(algorithm, datasetName, missingratio, algorithmExcCategory, k,
				time, Reduce, ReduceSize, Usize, splitTimes, null);
		this.processingResultList.add(result);
	}

	// 仅INEC
	public void addProcessingResult(String algorithm, String datasetName, String missingratio,
			String algorithmExcCategory, int k, long time, List<Integer> Reduce, int ReduceSize, int Usize,
			LinkedHashMap<String, Long> splitTimes, LinkedList<TNECSizeCount> TNEClist) {
		ProcessingResult result = new ProcessingResult(algorithm, datasetName, missingratio, algorithmExcCategory, k,
				time, Reduce, ReduceSize, Usize, splitTimes, null, TNEClist);
		this.processingResultList.add(result);
	}
	public void addProcessingResult(String algorithm, String datasetName, String missingratio,
			String algorithmExcCategory, int k, long time, List<Integer> Reduce, int ReduceSize, int Usize,
			LinkedHashMap<String, Long> splitTimes,Object[] size, LinkedList<TNECSizeCount> TNEClist) {
		ProcessingResult result = new ProcessingResult(algorithm, datasetName, missingratio, algorithmExcCategory, k,
				time, Reduce, ReduceSize, Usize, splitTimes, size, TNEClist);
		this.processingResultList.add(result);
	}

	// 输入数据
	public void inputData() {
		File file = new File(filePath);
		// this.filePath=filePath;
		ArrayList<String[]> dataArray = new ArrayList<String[]>();
		try {
			BufferedReader in = new BufferedReader(new FileReader(file));
			String str;
			String[] tempArray;
			while ((str = in.readLine()) != null) {
				tempArray = str.split(",");
				dataArray.add(tempArray);
			}
			in.close();
		} catch (IOException e) {
			e.getStackTrace();
		}
		this.dataArray = dataArray;
		ArrayList<Sample> U = new ArrayList<Sample>(dataArray.size());
		CName = new int[dataArray.get(0).length - 2];
		int n = 0;
		for (int i = 0; i < dataArray.get(0).length; i++) {
			String[] data = dataArray.get(0);
			if (i != data.length - 1 && i != 0) {
				CName[n] = Integer.valueOf(data[i]);
				n++;
			}
		}
		for (int i = 1; i < dataArray.size(); i++) {
			String[] data = dataArray.get(i);
			Sample x = new Sample(Integer.parseInt(data[0]) - 1, new int[data.length - 1]);
			for (int j = 0; j < data.length; j++) {
				if (j != data.length - 1 && j != 0) {
					x.setAttributeValueOf(j, Integer.parseInt(data[j]));
					if (Integer.parseInt(data[j]) == -1)
						x.setIs_Incomplete(true);
				} else if (j == data.length - 1)
					x.setAttributeValueOf(0, Integer.parseInt(data[j]));
				else if (j == 0)
					x.setName(Integer.parseInt(data[j]));
			}
			U.add(x);
		}
		this.U = U;
		// this.USize=U.size();
	}

	// 将数据拆分成十份
	public void divideDatato10_add(ArrayList<String[]> dataArray) {
		// int size=dataArray.size();
		int row = dataArray.size() - 1; // 行，减第一行
		// int column=dataArray.get(0).length-2; //列，减name和D
		int finalsize = 0;
		ArrayList<String[]> alldata = new ArrayList<>();
		alldata.addAll(dataArray);
		HashMap<Integer, ArrayList<String[]>> dataDivide = new HashMap<>();
		Random random = new Random();
		CName = new int[dataArray.get(0).length - 2];
		// this.CLength=CName.length;
		int k = 0;
		for (int j = 0; j < dataArray.get(0).length - 1; j++)
			if (j != dataArray.get(0).length - 1 && j != 0) {
				CName[k] = Integer.valueOf(dataArray.get(0)[j]);
				k++;
			}
		// dataArray.remove(0);
		for (int i = 0; i < 10; i++) {
			Set<Integer> set = new LinkedHashSet<Integer>();// LinkedHashSet是有顺序不重复集合
			random = new Random();
			String str = String.valueOf(((double) row - i * ((double) row / 10)));// 浮点变量a转换为字符串str
			int idx = str.lastIndexOf(".");// 查找小数点的位置
			String strNum = str.substring(0, idx);// 截取从字符串开始到小数点位置的字符串，就是整数部分
			int nowrow = 0;
			// System.out.print(Integer.valueOf(str.substring(str.lastIndexOf(".")+1)));
			if (Integer.valueOf(str.substring(str.lastIndexOf(".") + 1, str.lastIndexOf(".") + 2)) > 5)
				nowrow = Integer.valueOf(strNum) + 1;
			else
				nowrow = Integer.valueOf(strNum);// 把整数部分通过Integer.valueof方法转换为数字
			ArrayList<String[]> datatemp = new ArrayList<>();
			// System.out.println(nowrow);
			// System.out.println(nowrow);
			if (i != 9) {
				while (set.size() < ((double) row / 10)) {
					Integer number = random.nextInt(nowrow - i);
					set.add(number); // 重复就不会添加
				}
				for (Integer number : set)
					datatemp.add(alldata.get(number + 1));// 得到第几行 行的前面要+1
				// int temp=0,min=Integer.MAX_VALUE;
				for (int n = 0; n < datatemp.size(); n++) {
					for (int m = 0; m < alldata.size(); m++) {
						if (alldata.get(m)[0].equals(datatemp.get(n)[0])) {
							// System.out.println(alldata.get(m)[0]+" "+datatemp.get(n)[0]);
							alldata.remove(m);
						}
					}

				}
			} else {
				datatemp.addAll(alldata);
				datatemp.remove(0); // 删除第一行
			}
			dataDivide.put(i, datatemp);
			finalsize += datatemp.size();
		}
		this.dividedata = dataDivide;
		System.out.println("完成划分10份,共" + finalsize);
	}

	// 将数据拆分成十份——输出
	public void divideDatato10_add_other(ArrayList<String[]> dataArray) {
		// int size=dataArray.size();
		int row = dataArray.size() - 1; // 行，减第一行
		int finalsize = 0;
		LinkedList<String[]> alldata = new LinkedList<String[]>();
		for (int i = 1; i < dataArray.size(); i++) { // 不要第一行
			alldata.add(dataArray.get(i).clone());
		}
		HashMap<Integer, ArrayList<String[]>> dataDivide = new HashMap<>(10);
		Random random = new Random();
		int size = (dataArray.size() - 1) / 10;
		for (int i = 0; i < 10; i++) {
			random = new Random();
			ArrayList<String[]> datatemp = new ArrayList<>(size);
			if (i != 9) {
				int k = 0;
				while (k < size) {
					int a = random.nextInt(alldata.size());// 从0到n，但不会选到n
					datatemp.add(alldata.get(a));
					alldata.remove(a);
					k++;
				}
			} else {
				datatemp.addAll(alldata);
			}
			dataDivide.put(i, datatemp);
			finalsize += datatemp.size();
		}
		this.dividedata = dataDivide;
		System.out.println("完成划分10份,共" + finalsize);
	}

	// 将数据划分成10次随机选择的10part数据进行增量 (仅数据下标) 这里数据下标从0开始 无第一行
	public HashMap<Integer, HashMap<Integer, ArrayList<Integer>>> divideDatato10_random(ArrayList<String[]> dataArray) {
		HashMap<Integer, HashMap<Integer, ArrayList<Integer>>> all10partdata = new HashMap<>(10);
		for (int z = 0; z < 10; z++) {
			// 行，减第一行
			int finalsize = 0;
			int datasize = dataArray.size() - 1; // 减第一行
			List<Integer> alldataindex = new ArrayList<>(datasize);
			for (int i = 0; i < dataArray.size() - 1; i++) { // 不要第一行
				alldataindex.add(i);
			}
			HashMap<Integer, ArrayList<Integer>> dataDivide = new HashMap<>(10);
			Random random = new Random();
			int size = (dataArray.size() - 1) / 10;
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
			System.out.println("完成第" + z + "份划分10份,共" + finalsize);
		}
		System.out.println("数据划分完成,下面输出结果文件");
		this.outDivide10DataFile_randomdivide(all10partdata);
		return all10partdata;
	}

	// 通过划分的数据集input
	public void inputData_divideInitial(int num) { // num为将几份数据作为原始数据
		this.U = new ArrayList<Sample>();
		ArrayList<String[]> dataArray = new ArrayList<>();
		for (int m = 0; m < num; m++)
			dataArray.addAll(this.dividedata.get(m));// 前num份数据组成初始数据
//		CName=new int[dataArray.get(0).length-2];
//		int n=0;
//		for(int i=0;i<dataArray.get(0).length;i++) {
//			String[] data=dataArray.get(0);		
//			if(i!=data.length-1&&i!=0) {
//				CName[n]=Integer.valueOf(data[i]);	
//				n++;
//			}
//		}
		for (int i = 0; i < dataArray.size(); i++) {
			String[] data = dataArray.get(i);
			Sample x = new Sample(Integer.valueOf(data[0]), new int[data.length - 1]);
			for (int j = 0; j < data.length; j++) {
				if (j != data.length - 1 && j != 0) {
					x.setAttributeValueOf(j, Integer.parseInt(data[j]));
					if (Integer.parseInt(data[j]) == -1)
						x.setIs_Incomplete(true);
				} else if (j == data.length - 1)
					x.setAttributeValueOf(0, Integer.parseInt(data[j]));
			}
			this.U.add(x);
		}
		// this.CLength=dataArray.get(0).length-2;
	}

	// 通过划分的数据集input
	public void inputData_divideAdd(int num) { // num是添加第几部分
		this.newU = new ArrayList<Sample>();
		ArrayList<String[]> dataArray = new ArrayList<>();
		dataArray.addAll(this.dividedata.get(num));
		for (int i = 0; i < dataArray.size(); i++) {
			String[] data = dataArray.get(i);
			Sample x = new Sample(Integer.valueOf(data[0]), new int[data.length - 1]);
			for (int j = 0; j < data.length; j++) {
				if (j != data.length - 1 && j != 0) {
					x.setAttributeValueOf(j, Integer.parseInt(data[j]));
					if (Integer.parseInt(data[j]) == -1)
						x.setIs_Incomplete(true);
				} else if (j == data.length - 1)
					x.setAttributeValueOf(0, Integer.parseInt(data[j]));
			}
			this.newU.add(x);
		}
		// this.U.addAll(newU);
		// this.CLength=dataArray.get(0).length-2;
	}

	// 随机选取百分之x的数据转化为*
	public void inputExchangeIncomplete(double x, int num) {
		File file = new File(filePath);
		this.filePath = filePath;
		ArrayList<String[]> dataArray = new ArrayList<String[]>();
		// ArrayList<int[]> dataArrayInt=new ArrayList<int[]>();
		int row = 0, column = 0; // 行列
		try {
			BufferedReader in = new BufferedReader(new FileReader(file));
			String str;
			String[] tempArray;
			while ((str = in.readLine()) != null) {
				tempArray = str.split(",");
				dataArray.add(tempArray);
			}
			in.close();
		} catch (IOException e) {
			e.getStackTrace();
		}
		row = dataArray.size() - 1; // 行，减第一行
		column = dataArray.get(0).length - 2; // 列，减name和D
		Random random = new Random();
		Set<Integer> set = new LinkedHashSet<Integer>();// LinkedHashSet是有顺序不重复集合
		double size = row * column * x;
//		String str = String.valueOf(row*column*x);//浮点变量a转换为字符串str
//	    int idx = str.lastIndexOf(".");//查找小数点的位置
//	    String strNum = str.substring(0,idx);//截取从字符串开始到小数点位置的字符串，就是整数部分
//	    int size = Integer.valueOf(strNum);//把整数部分通过Integer.valueof方法转换为数字
		// System.out.print(column);
		for (int m = 0; m < num; m++) {
			while (set.size() < size) {
				Integer number = random.nextInt(row * column);
				set.add(number); // 重复就不会添加
			}
			for (Integer number : set) {
				int num1 = number / column; // 得到第几行 行的前面要+1
				int num2 = number % column; // 得到第几列 列的前面要+1
				dataArray.get(num1 + 1)[num2 + 1] = "-1"; // Incomplete
			}
//			for(int i=0;i<dataArray.size();i++) {
//				//int[] dataline=new int[dataArray.get(i).length];
//				String[] dataString=new String[dataArray.get(i).length];
//				for(int j=0;j<dataArray.get(i).length;j++) {
//					dataString[j]=dataArray.get(i)[j];
//				}
//				dataArray.add(dataString);
//			}
			this.dataArray = dataArray;
			File outFile, outPath;
			String str1 = filePath.substring(0, filePath.lastIndexOf("\\"));
			String str2 = filePath.substring(filePath.lastIndexOf("\\"), filePath.lastIndexOf("."));
			String str3 = filePath.substring(filePath.lastIndexOf("."));
			String dirPath = str1;
			// String outFilePath=str1+str2+"_"+(x*100)+"%"+str3;
			String outFilePath = filePath;
			try {
				outPath = new File(dirPath);
				outFile = new File(outFilePath);
				if (!outPath.exists()) {
					outPath.mkdirs();
				}
				if (!outFile.exists()) {
					outFile.createNewFile();
				}
				BufferedWriter out = new BufferedWriter(new FileWriter(outFile));
				String[] tempArray;
				for (int i = 0; i < dataArray.size(); i++) {
					tempArray = dataArray.get(i);
					String str = new String();
					for (int j = 0; j < tempArray.length; j++) {
						str += tempArray[j] + ",";
					}
					str += System.getProperty("line.separator");
					// System.out.print(str);
					out.write(str);
				}
				out.close();
			} catch (IOException e) {
				e.getStackTrace();
			}
			System.out.println("文件" + str2 + "_" + (x * 100) + "%转换完成");
		}
	}

	// 输出随机划分10次后的划分结果文件
	public void outDivide10DataFile_randomdivide(HashMap<Integer, HashMap<Integer, ArrayList<Integer>>> all10partdata) {
		// this.dataArray=dataArray;
		File outFile, outPath;
		String str1 = filePath.substring(0, filePath.lastIndexOf("/"));
		String str2 = filePath.substring(filePath.lastIndexOf("/"), filePath.lastIndexOf("."));
		String str3 = filePath.substring(filePath.lastIndexOf("."));
		String dirPath = str1;
		try {
			String outFilePath = str1 + str2 + "_randomDivide" + str3;
			outPath = new File(dirPath);
			outFile = new File(outFilePath);
			if (!outPath.exists()) {
				outPath.mkdirs();
			}
			if (!outFile.exists()) {
				outFile.createNewFile();
			}
			BufferedWriter out = new BufferedWriter(new FileWriter(outFile));
			for (Entry<Integer, HashMap<Integer, ArrayList<Integer>>> onepartdata : all10partdata.entrySet()) {
				HashMap<Integer, ArrayList<Integer>> data = onepartdata.getValue();
				for (Entry<Integer, ArrayList<Integer>> partdata : data.entrySet()) {
					ArrayList<Integer> tempArray = partdata.getValue();
					String str = new String();
					str += onepartdata.getKey() + "," + partdata.getKey() + ",";
					for (int j = 0; j < tempArray.size(); j++) {
						str += tempArray.get(j) + ",";
					}
					str += System.getProperty("line.separator");
					// System.out.print(str);
					out.write(str);
				}
			}
			out.close();
		} catch (IOException e) {
			e.getStackTrace();
		}
		System.out.println("文件" + str2 + "_randomDivide 划分完成");
	}

	// 输出划分后的10份数据的文件
	public void outDivide10DataFile() {
		// this.dataArray=dataArray;
		File outFile, outPath;
		String str1 = filePath.substring(0, filePath.lastIndexOf("/"));
		String str2 = filePath.substring(filePath.lastIndexOf("/"), filePath.lastIndexOf("."));
		String str3 = filePath.substring(filePath.lastIndexOf("."));
		String dirPath = str1;
		try {
			for (int z = 0; z < dividedata.size(); z++) {
				String outFilePath = str1 + str2 + "_" + z + str3;
				outPath = new File(dirPath);
				outFile = new File(outFilePath);
				if (!outPath.exists()) {
					outPath.mkdirs();
				}
				if (!outFile.exists()) {
					outFile.createNewFile();
				}
				BufferedWriter out = new BufferedWriter(new FileWriter(outFile));
				String[] tempArray;
				ArrayList<String[]> data = this.dividedata.get(z);
				for (int i = 0; i < data.size(); i++) {
					tempArray = data.get(i);
					String str = new String();
					for (int j = 0; j < tempArray.length; j++) {
						str += tempArray[j] + ",";
					}
					str += System.getProperty("line.separator");
					// System.out.print(str);
					out.write(str);
				}
				out.close();
			}
		} catch (IOException e) {
			e.getStackTrace();
		}
		System.out.println("文件" + str2 + "划分完成");
	}

	// 输入划分后的10份数据
	public void inputDivide10DataFile(String filePath) {
		File outFile, outPath;
		String str1 = filePath.substring(0, filePath.lastIndexOf("\\"));
		String str2 = filePath.substring(filePath.lastIndexOf("\\"), filePath.lastIndexOf("."));
		String str3 = filePath.substring(filePath.lastIndexOf("."));
		// String dirPath=str1;
		this.filePath = filePath;
		HashMap<Integer, ArrayList<String[]>> dividedata = new HashMap<>(10);
		try {
			for (int i = 0; i < 10; i++) {
				String inputFilePath = str1 + str2 + "_" + i + str3;
				File file = new File(inputFilePath);
				ArrayList<String[]> dataArray = new ArrayList<String[]>();
				BufferedReader in = new BufferedReader(new FileReader(file));
				String str;
				String[] tempArray;
				while ((str = in.readLine()) != null) {
					tempArray = str.split(",");
					dataArray.add(tempArray);
				}
				dividedata.put(i, dataArray);
				// this.dataArray.addAll(dataArray);
				in.close();
			}
		} catch (IOException e) {
			e.getStackTrace();
		}
		this.dividedata = dividedata;
//		CName=new int[dividedata.get(0).get(0).length-2];
//		int n=0;
//		for(int i=0;i<dividedata.get(0).get(0).length-2;i++) {
//			String[] data=dividedata.get(0).get(0);		
//			if(i!=data.length-1&&i!=0) {
//				CName[n]=i;	
//				n++;
//			}
//		}

	}

	// 输入划分后的10份数据 按照第k次，将第k份数据作为第10份数据（test数据，不训练），只训练前9份数据
	public void inputDivide10DataFile(String filePath, int k) {
		File outFile, outPath;
		String str1 = filePath.substring(0, filePath.lastIndexOf("\\"));
		String str2 = filePath.substring(filePath.lastIndexOf("\\"), filePath.lastIndexOf("."));
		String str3 = filePath.substring(filePath.lastIndexOf("."));
		// String dirPath=str1;
		this.filePath = filePath;
		HashMap<Integer, ArrayList<String[]>> dividedata = new HashMap<>(10);
		try {
			for (int i = 0; i < 10; i++) {
				String inputFilePath = str1 + str2 + "_" + i + str3;
				File file = new File(inputFilePath);
				ArrayList<String[]> dataArray = new ArrayList<String[]>();
				BufferedReader in = new BufferedReader(new FileReader(file));
				String str;
				String[] tempArray;
				while ((str = in.readLine()) != null) {
					tempArray = str.split(",");
					dataArray.add(tempArray);
				}
				dividedata.put(i, dataArray);
				in.close();
			}
		} catch (IOException e) {
			e.getStackTrace();
		}
		if (k != 0) {
			ArrayList<String[]> tempArray = dividedata.get(9);
			dividedata.replace(9, dividedata.get(k - 1));
			dividedata.replace(k - 1, tempArray);
		}
		this.dividedata = dividedata;
	}

	// 输入随机划分10次后的结果文件划分数据 按照每一part，将第10份数据作为test数据，不训练，只训练前9份数据
	public void inputDivide10DataFile_randomdivide(String filePath, int k) {
		// 输入：alldata路径 alldata划分结果 第几次
		HashMap<Integer, HashMap<Integer, ArrayList<Integer>>> all10partdata = new HashMap<>(10);
		File outFile, outPath;
		String str1 = filePath.substring(0, filePath.lastIndexOf("/"));
		String str2 = filePath.substring(filePath.lastIndexOf("/"), filePath.lastIndexOf("."));
		String str3 = filePath.substring(filePath.lastIndexOf("."));
		// String dirPath=str1;
		this.filePath = filePath;
		HashMap<Integer, ArrayList<String[]>> dividedata = new HashMap<>(10);
		try {
			String inputFilePath = str1 + str2 + "_randomDivide" + str3;
			File file = new File(inputFilePath);// index
			File datafile = new File(filePath); // alldata
			ArrayList<String[]> dataindexArray = new ArrayList<>();
			ArrayList<String[]> dataArray = new ArrayList<String[]>();
			BufferedReader in = new BufferedReader(new FileReader(file));
			BufferedReader datain = new BufferedReader(new FileReader(datafile));
			String str;
			String[] tempArray;
			// 读入index划分结果列表 10*10=100行
			while ((str = in.readLine()) != null) {
				tempArray = str.split(",");
				dataindexArray.add(tempArray);
			}
			// 读入所有数据
			while ((str = datain.readLine()) != null) {	
				tempArray = str.split(",");
				dataArray.add(tempArray);
			}
			// 构成第k次运行的数据划分
			for (int i = 0; i < 10; i++) {
				int num = k * 10;
				String[] list = dataindexArray.get(num + i);
				ArrayList<String[]> onepartdata = new ArrayList<>(list.length - 2);
				for (int z = 2; z < list.length; z++) { // 数据为“ 第k次 第i部分 [indexlist]”
					onepartdata.add(dataArray.get(Integer.parseInt(list[z]) + 1));
				}
				dividedata.put(i, onepartdata);
			}
			in.close();
		} catch (IOException e) {
			e.getStackTrace();
		}
		this.dividedata = dividedata;
	}

	// 输出得到Reduce划分后的文件
	public void outReduceFile(List<Integer> Reduce) {
		ArrayList<String[]> data = new ArrayList<>();
		data.addAll(this.dataArray);
		ArrayList<String> Reducedata = new ArrayList<>();
		ArrayList<Integer> num = new ArrayList<>();
		num.addAll(Reduce);
		// num.add(data.get(0).length-1); //加上D
		StringBuilder strx = new StringBuilder();
		for (int i = 1; i < data.size(); i++) {
			strx = new StringBuilder();
			for (int s : num)
				if (Integer.valueOf(data.get(i)[s]) == -1)
					strx.append("100000,");
				else
					strx.append(data.get(i)[s] + ",");
			strx.append(data.get(i)[data.get(i).length - 1]);
			strx.append(System.getProperty("line.separator"));
			Reducedata.add(strx.toString());
		}
		File outFile, outPath;
		String str1 = filePath.substring(0, filePath.lastIndexOf("/"));
		String str2 = filePath.substring(filePath.lastIndexOf("/"), filePath.lastIndexOf("."));
		String str3 = filePath.substring(filePath.lastIndexOf("."));
		String dirPath = str1;
		String outFilePath = str1 + str2 + "_Reduce" + str3;
		try {
			outPath = new File(dirPath);
			outFile = new File(outFilePath);
			if (!outPath.exists()) {
				outPath.mkdirs();
			}
			if (!outFile.exists()) {
				outFile.createNewFile();
			}
			BufferedWriter out = new BufferedWriter(new FileWriter(outFile));
			for (String str : Reducedata) {
				out.write(str);
			}
			out.close();
		} catch (IOException e) {
			e.getStackTrace();
		}
		System.out.println("文件" + str2 + "_Reduce完成");
	}

	// 输出得到Reduce划分后的文件 按总数据划分
	public void outReduceFile(ProcessingResult result, int k,String ExecType) {// 第k次约简,运行类型：增量or静态
		ArrayList<String[]> data = new ArrayList<>();
		data.addAll(this.dataArray);
		ArrayList<String> Reducedata = new ArrayList<>();
		ArrayList<Integer> num = new ArrayList<>();
		num.addAll(result.ReduceSort());
		// num.add(data.get(0).length-1); //加上D
		StringBuilder strx = new StringBuilder();
		for (int i = 0; i < data.size(); i++) {
			strx = new StringBuilder();
			for (int s : num)
				if (Integer.valueOf(data.get(i)[s + 1]) == -1)
					strx.append("100000,");
				else
					strx.append(data.get(i)[s + 1] + ",");
			strx.append(data.get(i)[data.get(i).length - 1]);
			strx.append(System.getProperty("line.separator"));
			Reducedata.add(strx.toString());
		}
		File outFile, outPath;
		String str1 = filePath.substring(0, filePath.lastIndexOf("/"));
		String strReduce = "/allDataReduce";
		String str2 = filePath.substring(filePath.lastIndexOf("/"), filePath.lastIndexOf("."));
		String str3 = filePath.substring(filePath.lastIndexOf("."));
		String dirPath = str1 + strReduce;
		String outFilePath = str1 + strReduce + str2 + "_" + result.getAlgorithm() + "_" + k + "_"+ExecType+"Reduce" + str3;
		try {
			outPath = new File(dirPath);
			outFile = new File(outFilePath);
			if (!outPath.exists()) {
				outPath.mkdirs();
			}
			if (!outFile.exists()) {
				outFile.createNewFile();
			}
			BufferedWriter out = new BufferedWriter(new FileWriter(outFile));
			for (String str : Reducedata) {
				out.write(str);
			}
			out.close();
		} catch (IOException e) {
			e.getStackTrace();
		}
		System.out.println("文件" + str2 + "_" + result.getAlgorithm() + "_Reduce完成");
	}

	// 输出得到Reduce划分后的文件 按前9份数据划分为train 第10份数据为test
	public void outReduceFile_testfile(ProcessingResult result, int k) {// 第k次约简
		ArrayList<String[]> data = new ArrayList<>(dataArray.size());
		data.add(this.dataArray.get(0));
		for (int m = 0; m < 9; m++)
			data.addAll(this.dividedata.get(m));// 前num份数据组成初始数据
		ArrayList<String[]> data_test = new ArrayList<>(this.dividedata.get(9).size());// 最后一份数据
		data_test.add(this.dataArray.get(0));
		data_test.addAll(this.dividedata.get(9));
		ArrayList<String> Reducedata_train = new ArrayList<>();
		ArrayList<String> Reducedata_test = new ArrayList<>();
		ArrayList<Integer> num = new ArrayList<>();
		num.addAll(result.ReduceSort());
		// num.add(data.get(0).length-1); //加上D
		StringBuilder strx = new StringBuilder();
		for (int i = 0; i < data.size(); i++) {
			strx = new StringBuilder();
			for (int s : num)
				if (Integer.valueOf(data.get(i)[s + 1]) == -1)
					strx.append("100000,");
				else
					strx.append(data.get(i)[s + 1] + ",");
			strx.append(data.get(i)[data.get(i).length - 1]);
			strx.append(System.getProperty("line.separator"));
			Reducedata_train.add(strx.toString());
		}

		strx = new StringBuilder();
		for (int i = 0; i < data_test.size(); i++) {
			strx = new StringBuilder();
			for (int s : num)
				if (Integer.valueOf(data_test.get(i)[s + 1]) == -1)
					strx.append("100000,");
				else
					strx.append(data_test.get(i)[s + 1] + ",");
			strx.append(data_test.get(i)[data_test.get(i).length - 1]);
			strx.append(System.getProperty("line.separator"));
			Reducedata_test.add(strx.toString());
		}
		File outFile, outPath;
		String str1 = filePath.substring(0, filePath.lastIndexOf("\\"));
		String strReduce = "\\reduce";
		String str2 = filePath.substring(filePath.lastIndexOf("\\"), filePath.lastIndexOf("."));
		String str3 = filePath.substring(filePath.lastIndexOf("."));
		String dirPath = str1 + strReduce;
		String outFilePath_train = str1 + strReduce + str2 + "_" + result.getAlgorithm() + "_" + k + "_Reduce_train"
				+ str3;
		String outFilePath_test = str1 + strReduce + str2 + "_" + result.getAlgorithm() + "_" + k + "_Reduce_test"
				+ str3;
		try {
			// train data
			outPath = new File(dirPath);
			outFile = new File(outFilePath_train);
			if (!outPath.exists()) {
				outPath.mkdirs();
			}
			if (!outFile.exists()) {
				outFile.createNewFile();
			}
			BufferedWriter out = new BufferedWriter(new FileWriter(outFile));
			for (String str : Reducedata_train) {
				out.write(str);
			}
			out.close();
			// test data
			outFile = new File(outFilePath_test);
			if (!outPath.exists()) {
				outPath.mkdirs();
			}
			if (!outFile.exists()) {
				outFile.createNewFile();
			}
			out = new BufferedWriter(new FileWriter(outFile));
			for (String str : Reducedata_test) {
				out.write(str);
			}
			out.close();
		} catch (IOException e) {
			e.getStackTrace();
		}
		System.out.println("文件" + str2 + "_" + result.getAlgorithm() + "_" + k + "_Reduce完成");
	}

	// 将数据一半拆分成十份共11份
	public void divideHalfDatato10(ArrayList<String[]> dataArray) {
		// int size=dataArray.size();
		int row = dataArray.size() - 1; // 行，减第一行
		// int column=dataArray.get(0).length-2; //列，减name和D
		ArrayList<String[]> alldata = new ArrayList<>();
		alldata.addAll(dataArray);
		HashMap<Integer, ArrayList<String[]>> dataDivide = new HashMap<>();
		Random random = new Random();
		CName = new int[dataArray.get(0).length - 2];
		int k = 0;
		for (int j = 0; j < dataArray.get(0).length - 1; j++)
			if (j != dataArray.get(0).length - 1 && j != 0) {
				CName[k] = Integer.valueOf(dataArray.get(0)[j]);
				k++;
			}
		Set<Integer> set = new LinkedHashSet<Integer>();
		ArrayList<String[]> datatemp = new ArrayList<>();
		while (set.size() < ((double) row / 2)) {
			Integer number = random.nextInt(row - 1);
			set.add(number); // 重复就不会添加
		}
		for (Integer number : set)
			datatemp.add(alldata.get(number + 1));// 得到第几行 行的前面要+1
		for (int n = 0; n < datatemp.size(); n++) {
			for (int m = 0; m < alldata.size(); m++) {
				if (alldata.get(m)[0].equals(datatemp.get(n)[0])) {
					// System.out.println(alldata.get(m)[0]+" "+datatemp.get(n)[0]);
					alldata.remove(m);
				}
			}
		}
		dataDivide.put(0, datatemp); // 一半作为初始数据
		for (int i = 0; i < 10; i++) {
			set = new LinkedHashSet<Integer>();// LinkedHashSet是有顺序不重复集合
			random = new Random();
			String str = String.valueOf(((double) row / 2 - i * ((double) row / 20)));// 浮点变量a转换为字符串str
			int idx = str.lastIndexOf(".");// 查找小数点的位置
			String strNum = str.substring(0, idx);// 截取从字符串开始到小数点位置的字符串，就是整数部分
			int nowrow = 0;
			// System.out.print(Integer.valueOf(str.substring(str.lastIndexOf(".")+1)));
			if (Integer.valueOf(str.substring(str.lastIndexOf(".") + 1, str.lastIndexOf(".") + 2)) > 5)
				nowrow = Integer.valueOf(strNum) + 1;
			else
				nowrow = Integer.valueOf(strNum);// 把整数部分通过Integer.valueof方法转换为数字
			datatemp = new ArrayList<>();
			// System.out.println((double)row/2-i*((double)row/20));
			// System.out.println(row);
			if (i != 9) {
				while (set.size() < ((double) row / 20)) {
					Integer number = random.nextInt(nowrow - i);
					set.add(number); // 重复就不会添加
				}
				for (Integer number : set)
					datatemp.add(alldata.get(number + 1));// 得到第几行 行的前面要+1
				for (int n = 0; n < datatemp.size(); n++) {
					for (int m = 0; m < alldata.size(); m++) {
						if (alldata.get(m)[0].equals(datatemp.get(n)[0])) {
							// System.out.println(alldata.get(m)[0]+" "+datatemp.get(n)[0]);
							alldata.remove(m);
						}
					}
				}
				// System.out.println(alldata.size());
			} else {
				datatemp.addAll(alldata);
				datatemp.remove(0); // 删除第一行
			}
			dataDivide.put(i + 1, datatemp);
		}
		this.dividedata = dataDivide;
		System.out.println("完成将一半数据作为初始数据，另一半划分成10份");
	}

	// 将数据拆分成十份
	public void divideDatato10_delete(ArrayList<String[]> dataArray) {
		// int size=dataArray.size();
		int row = dataArray.size() - 1; // 行，减第一行
		// int column=dataArray.get(0).length-2; //列，减name和D
		ArrayList<String[]> alldata = new ArrayList<>();
		alldata.addAll(dataArray);
		HashMap<Integer, ArrayList<String[]>> dataDivide = new HashMap<>();
		Random random = new Random();
//		CName=new int[dataArray.get(0).length-2];
//		this.CLength=CName.length;
//		int k=0;
//		for(int j=0;j<dataArray.get(0).length-1;j++)
//			if(j!=dataArray.get(0).length-1&&j!=0) {
//				CName[k]=Integer.valueOf(dataArray.get(0)[j]);
//				k++;
//			}
		for (int i = 0; i < 10; i++) {
			Set<Integer> set = new LinkedHashSet<Integer>();// LinkedHashSet是有顺序不重复集合
			random = new Random();
			String str = String.valueOf(((double) row - i * ((double) row / 10)));// 浮点变量a转换为字符串str
			int idx = str.lastIndexOf(".");// 查找小数点的位置
			String strNum = str.substring(0, idx);// 截取从字符串开始到小数点位置的字符串，就是整数部分
			int nowrow = 0;
			// System.out.print(Integer.valueOf(str.substring(str.lastIndexOf(".")+1)));
			if (Integer.valueOf(str.substring(str.lastIndexOf(".") + 1, str.lastIndexOf(".") + 2)) > 5)
				nowrow = Integer.valueOf(strNum) + 1;
			else
				nowrow = Integer.valueOf(strNum);// 把整数部分通过Integer.valueof方法转换为数字
			ArrayList<String[]> datatemp = new ArrayList<>();
			// System.out.println(nowrow);
			// System.out.println(nowrow);
			if (i != 9) {
				while (set.size() < ((double) row / 10)) {
					Integer number = random.nextInt(nowrow - i);
					set.add(number); // 重复就不会添加
				}
				for (Integer number : set)
					datatemp.add(alldata.get(number + 1));// 得到第几行 行的前面要+1
				// int temp=0,min=Integer.MAX_VALUE;
				for (int n = 0; n < datatemp.size(); n++) {
					for (int m = 0; m < alldata.size(); m++) {
						if (alldata.get(m)[0].equals(datatemp.get(n)[0])) {
							// System.out.println(alldata.get(m)[0]+" "+datatemp.get(n)[0]);
							alldata.remove(m);
						}
					}

				}
				// System.out.println(alldata.size());
			} else {
				datatemp.addAll(alldata);
				datatemp.remove(0); // 删除第一行
			}
			dataDivide.put(i, datatemp);
		}
		this.dividedata = dataDivide;
		System.out.println("完成划分10份");
	}

	// 通过划分的数据集input
	public void inputData_divideDelete(int num) { // num是删除第几部分
		this.Ude = new ArrayList<>();
		ArrayList<String[]> dataArray = new ArrayList<>();
		dataArray.addAll(this.dividedata.get(num));
		for (int i = 0; i < dataArray.size(); i++) {
			String[] data = dataArray.get(i);
			Sample x = new Sample(Integer.valueOf(data[0]), new int[data.length - 1]);
			for (int j = 0; j < data.length; j++) {
				if (j != data.length - 1 && j != 0) {
					x.setAttributeValueOf(j, Integer.parseInt(data[j]));
					if (Integer.parseInt(data[j]) == -1)
						x.setIs_Incomplete(true);
				} else if (j == data.length - 1)
					x.setAttributeValueOf(0, Integer.parseInt(data[j]));
			}
			this.Ude.add(x);

		}
		U.removeAll(Ude);
		// System.out.print(Ude.size());
	}

	// addSample
	public void inputData_add(String filePath) {
		File file = new File(filePath);
		ArrayList<String[]> dataArray = new ArrayList<String[]>();
		try {
			BufferedReader in = new BufferedReader(new FileReader(file));
			String str;
			String[] tempArray;
			while ((str = in.readLine()) != null) {
				tempArray = str.split(",");
				dataArray.add(tempArray);
			}
			in.close();
		} catch (IOException e) {
			e.getStackTrace();
		}
		for (int i = 0; i < dataArray.size(); i++) {
			String[] data = dataArray.get(i);
			Sample x = new Sample(Integer.parseInt(data[0]), new int[data.length - 1]);
			if (i != 0) {
				for (int j = 0; j < data.length; j++) {
					if (j != data.length - 1 && j != 0) {
						x.setAttributeValueOf(j, Integer.parseInt(data[j]));
						if (Integer.parseInt(data[j]) == -1)
							x.setIs_Incomplete(true);
					} else if (j == data.length - 1)
						x.setAttributeValueOf(0, Integer.parseInt(data[j]));
				}
				newU.add(x);
			}
		}
		this.U.addAll(newU);
	}

	// deleteSample
	public void inputData_delete(String filePath) {
		File file = new File(filePath);
		ArrayList<String[]> dataArray = new ArrayList<String[]>();
		try {
			BufferedReader in = new BufferedReader(new FileReader(file));
			String str;
			String[] tempArray;
			while ((str = in.readLine()) != null) {
				tempArray = str.split(",");
				dataArray.add(tempArray);
			}
			in.close();
		} catch (IOException e) {
			e.getStackTrace();
		}
		for (int i = 0; i < dataArray.size(); i++) {
			String[] data = dataArray.get(i);
			Sample x = new Sample(Integer.parseInt(data[0]), new int[data.length - 1]);
			if (i != 0) {
				for (int j = 0; j < data.length; j++) {
					if (j != data.length - 1 && j != 0) {
						x.setAttributeValueOf(j, Integer.parseInt(data[j]));
						if (Integer.parseInt(data[j]) == -1)
							x.setIs_Incomplete(true);
					} else if (j == data.length - 1)
						x.setAttributeValueOf(0, Integer.parseInt(data[j]));
				}
				Ude.add(x);
			}
		}
		U.removeAll(Ude);
	}

	// addSample
	public void inputData_multi(String addfilePath, String deletefilePath) {
		this.inputData_add(addfilePath);
		this.inputData_delete(deletefilePath);
	}

	// addSample
	public void inputData_deleteAttribute(String filePath) {
		File file = new File(filePath);
		ArrayList<String[]> dataArray = new ArrayList<String[]>();
		try {
			BufferedReader in = new BufferedReader(new FileReader(file));
			String str;
			String[] tempArray;
			while ((str = in.readLine()) != null) {
				tempArray = str.split(",");
				dataArray.add(tempArray);
			}
			in.close();
		} catch (IOException e) {
			e.getStackTrace();
		}
		this.Cde = new int[dataArray.get(0).length];
		for (int i = 0; i < dataArray.size(); i++) {
			String[] data = dataArray.get(i);
			for (int j = 0; j < data.length; j++)
				this.Cde[j] = Integer.parseInt(data[j]);
		}
	}

	// 对约简结果排序
	public void ReduceSortOutPut(List<Integer> Reduce) {
		List<Integer> newReduce = new ArrayList<Integer>(Reduce);
		Collections.sort(newReduce);
		// System.out.print(newReduce);
	}

	// 输出算法计算结果：算法,数据集,算法运行类型,第k次,程序运行时间,约简集,约简数量,USize
	public void outPutProcessingResult() {  //type=1：增量，type=2：静态
		File outFile, outPath;
		String str1 = filePath.substring(0, filePath.lastIndexOf("\\"));
		String str4 = filePath.substring(0, str1.lastIndexOf("\\"));
		String str5 = filePath.substring(0, str4.lastIndexOf("\\"));
		String dirnamepath = str5 + "\\ProcessingResult";
		String str2 = filePath.substring(filePath.lastIndexOf("\\"), filePath.lastIndexOf("."));
		String str3 = filePath.substring(filePath.lastIndexOf("."));
		// String dirPath=str1;
		String outFilePath = dirnamepath + str2 + "_ProcessingResult.csv";
		try {
			outPath = new File(dirnamepath);
			outFile = new File(outFilePath);
			if (!outPath.exists()) {
				outPath.mkdirs();
			}
			if (!outFile.exists()) {
				outFile.createNewFile();
			}
			ProcessingResult result;
			BufferedWriter out = new BufferedWriter(new FileWriter(outFile, true));
			for (int i = 0; i < processingResultList.size(); i++) {
				result = processingResultList.get(i);
				if (i == 0) {
					StringBuilder str = new StringBuilder();
					str.append(
							"Time,Algorithm,Dataset,Missingratio,ExecCategory,numbers,Times,Reduct,ReductSize,USize");
					str.append(System.getProperty("line.separator"));
					out.write(str.toString());
				}
				out.write(result.toString());
			}
			out.close();
		} catch (IOException e) {
			e.getStackTrace();
		}
		System.out.println("算法" + processingResultList.get(0).getAlgorithm() + "约简结果输出");
	}

	// 输出算法计算结果：算法,数据集,算法运行类型,第k次,程序运行时间,约简集,约简数量,USize
	public void outPutProcessingResult(String filePath) {
		File outFile, outPath;
		String outFilePath = filePath + "\\ProcessingResult.csv";
		try {
			outPath = new File(filePath);
			outFile = new File(outFilePath);
			if (!outPath.exists()) {
				outPath.mkdirs();
			}
			if (!outFile.exists()) {
				outFile.createNewFile();
			}
			ProcessingResult result;
			BufferedWriter out = new BufferedWriter(new FileWriter(outFile, true));
			for (int i = 0; i < processingResultList.size(); i++) {
				result = processingResultList.get(i);
				if (i == 0) {
					StringBuilder str = new StringBuilder();
					str.append(
							"Time,Algorithm,Dataset,Missingratio,ExecCategory,numbers,Times,Reduct,ReductSize,USize");
					str.append(System.getProperty("line.separator"));
					out.write(str.toString());
				}
				out.write(result.toString());
			}
			out.close();
		} catch (IOException e) {
			e.getStackTrace();
		}
		System.out.println("算法" + processingResultList.get(0).getAlgorithm() + "约简结果输出");
	}

	// 输出算法计算结果：算法,数据集,算法运行类型,第k次,程序运行时间,约简集,约简数量,USize
	public void outPutProcessingResult_INEC() {
		File outFile, outPath;
		String str1 = filePath.substring(0, filePath.lastIndexOf("/"));
		String str4 = filePath.substring(0, str1.lastIndexOf("/"));
		String str5 = filePath.substring(0, str4.lastIndexOf("/"));
		String dirnamepath = str5 + "/ProcessingResult";
		String str2 = filePath.substring(filePath.lastIndexOf("/"), filePath.lastIndexOf("."));
		String str3 = filePath.substring(filePath.lastIndexOf("."));
		// String dirPath=str1;
		String outFilePath = dirnamepath + str2 + "_ProcessingResult.csv";
		// String outFilePath=filePath+"\\ProcessingResult.csv";
		try {
			outPath = new File(dirnamepath);
			outFile = new File(outFilePath);
			if (!outPath.exists()) {
				outPath.mkdirs();
			}
			if (!outFile.exists()) {
				outFile.createNewFile();
			}
			ProcessingResult result;
			BufferedWriter out = new BufferedWriter(new FileWriter(outFile, true));
			for (int i = 0; i < processingResultList.size(); i++) {
				result = processingResultList.get(i);
				if (i == 0) {
					StringBuilder str = new StringBuilder();
					str.append(
							"Time,Algorithm,Dataset,Missingratio,ExecCategory,numbers,Times,Reduct,ReductSize,USize,start_0TNEC,start_1TNEC,start_-1TNEC,end_0TNEC,end_1TNEC,end_-1TNEC,Initial_te_size,TE_size,add_te_size");
					str.append(System.getProperty("line.separator"));
					out.write(str.toString());
				}
				out.write(result.INEC_TNECSizeCounttoString());
			}
			out.close();
		} catch (IOException e) {
			e.getStackTrace();
		}
		System.out.println("算法" + processingResultList.get(0).getAlgorithm() + "约简结果输出");
	}

	// 输出算法计算结果：算法各部分程序运行时间
	public void outPutProcessingofTimesResult(LinkedHashMap<String, Long> times) {
		File outFile, outPath;
		String str1 = filePath.substring(0, filePath.lastIndexOf("\\"));
		String str4 = filePath.substring(0, str1.lastIndexOf("\\"));
		String str5 = filePath.substring(0, str4.lastIndexOf("\\"));
		String dirnamepath = str5 + "\\ProcessingResult";
		String str2 = filePath.substring(filePath.lastIndexOf("\\"), filePath.lastIndexOf("."));
		String str3 = filePath.substring(filePath.lastIndexOf("."));
		// String dirPath=str1;
		String outFilePath = dirnamepath + str2 + "_ProcessingResult_splitTimes.csv";
		// String outFilePath=filePath+"\\ProcessingResult_splitTimes.csv";
		try {
			outPath = new File(dirnamepath);
			outFile = new File(outFilePath);
			if (!outPath.exists()) {
				outPath.mkdirs();
			}
			if (!outFile.exists()) {
				outFile.createNewFile();
			}
			ProcessingResult result;
			BufferedWriter out = new BufferedWriter(new FileWriter(outFile, true));
			// for(int i=0;i<times.size();i++) {
			result = processingResultList.getLast();
			if (processingResultList.size() == 1 || processingResultList.size() == 2) {
				StringBuilder str = new StringBuilder();
				str.append("Time,Algorithm,Dataset,Missingratio,ExecCategory,numbers,");
				//if(!times.isEmpty())
				for (String splitTimeName : times.keySet()) {
					str.append(splitTimeName + ",");
				}
				str.append(System.getProperty("line.separator"));
				out.write(str.toString());
			}
			out.write(result.splitTimestoString());
			// }
			out.close();
		} catch (IOException e) {
			e.getStackTrace();
		}
		System.out.println("算法" + processingResultList.get(0).getAlgorithm() + "分段时间结果输出");
	}

	// 输出算法计算结果：算法迭代过程中POS增加
	public void outPutProcessingofPOSResult(LinkedHashMap<Integer, Integer> posattr) {
		File outFile, outPath;
//		String str1=filePath.substring(0,filePath.lastIndexOf("\\"));
//		String str2=filePath.substring(filePath.lastIndexOf("\\"),filePath.lastIndexOf("."));
//		String str3=filePath.substring(filePath.lastIndexOf("."));
//		String dirPath=str1;
//		String outFilePath=str1+str2+"_ProcessingResult_pos"+str3;	
		String str1 = filePath.substring(0, filePath.lastIndexOf("\\"));
		String str4 = filePath.substring(0, str1.lastIndexOf("\\"));
		String str5 = filePath.substring(0, str4.lastIndexOf("\\"));
		String dirnamepath = str5 + "\\ProcessingResult";
		String str2 = filePath.substring(filePath.lastIndexOf("\\"), filePath.lastIndexOf("."));
		String str3 = filePath.substring(filePath.lastIndexOf("."));
		// String dirPath=str1;
		String outFilePath = dirnamepath + str2 + "_ProcessingResult_pos.csv";

		try {
			outPath = new File(dirnamepath);
			outFile = new File(outFilePath);
			if (!outPath.exists()) {
				outPath.mkdirs();
			}
			if (!outFile.exists()) {
				outFile.createNewFile();
			}
			ProcessingResult result;
			BufferedWriter out = new BufferedWriter(new FileWriter(outFile, true));
			for (int i = 0; i < processingResultList.size(); i++) {
				result = processingResultList.get(i);
				if (i == 0) {
					StringBuilder str = new StringBuilder();
					str.append("Time,Algorithm,numbers,Times,Reduct,ReductSize,USize");
					str.append(System.getProperty("line.separator"));
					out.write(str.toString());
				}
				out.write(result.toString());
			}
			out.close();
		} catch (IOException e) {
			e.getStackTrace();
		}
		System.out.println("算法" + processingResultList.get(0).getAlgorithm() + "约简结果输出");
	}
}

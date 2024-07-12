package main.basic.model;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.Formatter;
import java.util.LinkedHashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map.Entry;

import main.java.INEC.entity.equivalenceClass.TNECSizeCount;

public class ProcessingResult {
	// 输出算法计算结果：算法名称 数据集名称 数据缺失比例 算法运行类别 第k次 程序运行时间 约简集 约简数量 usize
	private String algorithm;
	private String datasetName;
	private String missingratio;
	private String algorithmExcuteCategory;
	private int k;
	private long time;
	private List<Integer> Reduce;
	private int ReduceSize;
	private int Usize;
	private LinkedHashMap<String, Long> splitTimes = new LinkedHashMap<>();
	public Object[] otherResult;
	public LinkedList<TNECSizeCount> TNEClist;
	Date date = new Date();
	DateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
	// System.out.println("当前时间为："+dateFormat.format(date));

	public ProcessingResult(String algorithm, int k, long time, List<Integer> Reduce, int ReduceSize, int Usize) {
		this.algorithm = algorithm;
		this.k = k;
		this.time = time;
		this.Reduce = Reduce;
		this.ReduceSize = ReduceSize;
		this.Usize = Usize;
	}

	public ProcessingResult(String algorithm, int k, long time, List<Integer> Reduce, int ReduceSize, int Usize,
			Object[] otherResult) {
		this.algorithm = algorithm;
		this.k = k;
		this.time = time;
		this.Reduce = Reduce;
		this.ReduceSize = ReduceSize;
		this.Usize = Usize;
		this.otherResult = otherResult;
	}

	public ProcessingResult(String algorithm, String datasetName, String missingratio, String algorithmExcuteCategory,
			int k, long time, List<Integer> Reduce, int ReduceSize, int Usize, LinkedHashMap<String, Long> splitTimes,
			Object[] otherResult) {
		this.algorithm = algorithm;
		this.datasetName = datasetName;
		this.missingratio = missingratio;
		this.algorithmExcuteCategory = algorithmExcuteCategory;
		this.k = k;
		this.time = time;
		this.Reduce = Reduce;
		this.ReduceSize = ReduceSize;
		this.Usize = Usize;
		this.splitTimes = splitTimes;
		this.otherResult = otherResult;
	}

	// 仅INEC
	public ProcessingResult(String algorithm, String datasetName, String missingratio, String algorithmExcuteCategory,
			int k, long time, List<Integer> Reduce, int ReduceSize, int Usize, LinkedHashMap<String, Long> splitTimes,
			Object[] otherResult, LinkedList<TNECSizeCount> TNEClist) {
		this.algorithm = algorithm;
		this.datasetName = datasetName;
		this.missingratio = missingratio;
		this.algorithmExcuteCategory = algorithmExcuteCategory;
		this.k = k;
		this.time = time;
		this.Reduce = Reduce;
		this.ReduceSize = ReduceSize;
		this.Usize = Usize;
		this.splitTimes = splitTimes;
		this.otherResult = otherResult;
		this.TNEClist = TNEClist;
	}

	public String getAlgorithm() {
		return algorithm;
	}

	public void setAlgorithm(String algorithm) {
		this.algorithm = algorithm;
	}

	public int getK() {
		return k;
	}

	public void setK(int k) {
		this.k = k;
	}

	public long getTime() {
		return time;
	}

	public void setTime(long time) {
		this.time = time;
	}

	public List<Integer> getReduce() {
		return Reduce;
	}

	public void setReduce(List<Integer> reduce) {
		Reduce = reduce;
	}

	public int getReduceSize() {
		return ReduceSize;
	}

	public void setReduceSize(int reduceSize) {
		ReduceSize = reduceSize;
	}

	public int getUsize() {
		return Usize;
	}

	public void setUsize(int usize) {
		Usize = usize;
	}

	public String getDatasetName() {
		return datasetName;
	}

	public void setDatasetName(String datasetName) {
		this.datasetName = datasetName;
	}

	public String getMissingratio() {
		return missingratio;
	}

	public void setMissingratio(String missingratio) {
		this.missingratio = missingratio;
	}

	public LinkedHashMap<String, Long> getSplitTimes() {
		return splitTimes;
	}

	public void setSplitTimes(LinkedHashMap<String, Long> splitTimes) {
		this.splitTimes = splitTimes;
	}

	public String getAlgorithmExcuteCategory() {
		return algorithmExcuteCategory;
	}

	public void setAlgorithmExcuteCategory(String algorithmExcuteCategory) {
		this.algorithmExcuteCategory = algorithmExcuteCategory;
	}

	public Object[] getOtherResult() {
		return otherResult;
	}

	public void setOtherResult(Object[] otherResult) {
		this.otherResult = otherResult;
	}

	public String toString() {
		StringBuilder str = new StringBuilder();
		str.append(dateFormat.format(date) + ",");
		str.append(algorithm + ",");
		str.append(datasetName + ",");
		str.append(missingratio + ",");
		str.append(algorithmExcuteCategory + ",");
		str.append(k + ",");
		String times = new Formatter().format("%.2f", ((double) (time) / 1000)).toString();
		str.append(times + ",[");
		for (int i : ReduceSort())
			str.append(i + " ");
		str.append("],");
		str.append(ReduceSize + ",");
		str.append(Usize);
		str.append(System.getProperty("line.separator"));
		return str.toString();
	}

	public String splitTimestoString() {
		StringBuilder str = new StringBuilder();
		str.append(dateFormat.format(date) + ",");
		str.append(algorithm + ",");
		str.append(datasetName + ",");
		str.append(missingratio + ",");
		str.append(algorithmExcuteCategory + ",");
		str.append(k + ",");
		if (splitTimes != null)
			for (Entry<String, Long> key : splitTimes.entrySet()) {
				str.append(new Formatter().format("%.2f", ((double) (key.getValue()) / 1000)).toString() + ",");
			}
		str.append(System.getProperty("line.separator"));
		return str.toString();
	}

	public String INEC_TNECSizeCounttoString() {
		StringBuilder str = new StringBuilder();
		str.append(dateFormat.format(date) + ",");
		str.append(algorithm + ",");
		str.append(datasetName + ",");
		str.append(missingratio + ",");
		str.append(algorithmExcuteCategory + ",");
		str.append(k + ",");
		String times = new Formatter().format("%.2f", ((double) (time) / 1000)).toString();
		str.append(times + ",[");
		for (int i : ReduceSort())
			str.append(i + " ");
		str.append("],");
		str.append(ReduceSize + ",");
		str.append(Usize + ",");
		//三区域划分
		//if(TNEClist.size()>1) {
		str.append(
				TNEClist.get(1).zero_size + "," + TNEClist.get(1).one_size + "," + TNEClist.get(1).minusone_size + ",");
		//}
		str.append(TNEClist.getLast().zero_size + "," + TNEClist.getLast().one_size + ","
				+ TNEClist.getLast().minusone_size);
		//|U/C|/U的大小 + 所有TE的大小
		if( otherResult!=null) {
			str.append(","+otherResult[0]+","+otherResult[1]);
		}
		
		
		str.append(System.getProperty("line.separator"));
		return str.toString();
	}

	// 对约简结果排序
	public List<Integer> ReduceSort() {
		List<Integer> newReduce = new ArrayList<Integer>(this.Reduce);
		Collections.sort(newReduce);
		// System.out.print(newReduce);
		return newReduce;
	}
}

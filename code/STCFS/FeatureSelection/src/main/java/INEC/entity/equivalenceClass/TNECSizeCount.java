package main.java.INEC.entity.equivalenceClass;

//记录 TNEC的size
public class TNECSizeCount {
	public int zero_size = 0;
	public int one_size = 0;
	public int minusone_size = 0;

	public TNECSizeCount() {
	}

	public TNECSizeCount(int zero_size, int one_size, int minusone_size) {
		this.zero_size = zero_size;
		this.one_size = one_size;
		this.minusone_size = minusone_size;
	}
}

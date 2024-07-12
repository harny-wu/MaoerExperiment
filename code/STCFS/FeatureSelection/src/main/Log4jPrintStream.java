package main;

import java.io.OutputStream;
import java.io.PrintStream;

import org.apache.log4j.Logger;

public class Log4jPrintStream extends PrintStream {
	private Logger log = Logger.getLogger("SystemOut");
	private static PrintStream instance = new Log4jPrintStream(System.out);

	private Log4jPrintStream(OutputStream out) {
		super(out);
	}

	public static void redirectSystemOut() {
		System.setOut(instance);
	}

	public void print(boolean b) {
		println(b);
	}

	public void print(char c) {
		println(c);
	}

	public void print(char[] s) {
		println(s);
	}

	public void print(double d) {
		println(d);
	}

	public void print(float f) {
		println(f);
	}

	public void print(int i) {
		println(i);
	}

	public void print(long l) {
		println(l);
	}

	public void print(Object obj) {
		println(obj);
	}

	public void print(String s) {
		println(s);
	}

	public void println(boolean x) {
		log.info(Boolean.valueOf(x));
	}

	public void println(char x) {
		log.info(Character.valueOf(x));
	}

	public void println(char[] x) {
		log.info(x == null ? null : new String(x));
	}

	public void println(double x) {
		log.info(Double.valueOf(x));
	}

	public void println(float x) {
		log.info(Float.valueOf(x));
	}

	public void println(int x) {
		log.info(Integer.valueOf(x));
	}

	public void println(long x) {
		log.info(x);
	}

	public void println(Object x) {
		log.info(x);
	}

	public void println(String x) {
		log.info(x);
	}

}

package main.java.FSMV.entity;

import java.util.Arrays;
/**
 * A wrapped entity for <code>int[]</code> as key in {@link java.util.Map Map}. The
 * following methods are overridden and is of importance:
 * <ul>
 * 	<li>{@link IntArrayKey#equals(Object)}</li>
 * 	<li>{@link IntArrayKey#hashCode()}</li>
 * </ul>
 * <p>
 * When constructing, {@link IntArrayKey#IntArrayKey(int...)} is recommended.
 * <p>
 * Call {@link IntArrayKey#key()} to get the <code>int[]</code>.
 *
 * @author Benjamin_L
 */
//存储在hash中的int[]的key
public class IntArrayKey {
    private int[] key;
    
    public IntArrayKey() {
        this.key =new int[0];
    }
    public IntArrayKey(int...key) {
        this.key = key;
    }
    public IntArrayKey(int size) {
    	this.key=new int[size];
    	for(int i=0;i<size;i++)
    		key[i]=i;
    }
    public int[] key() {
        return key;
    }
    public int size() {
    	return key.length;
    }
    public void addKey(int a) {
    	int[] newkey=new int[key.length+1];
    	for(int i=0;i<key.length;i++)
    		newkey[i]=key[i];
    	newkey[newkey.length-1]=a;
    	this.key=newkey;
    }
    public 	int[] deleteKey(int a) {
    	int[] newkey=new int[key.length-1];
    	int j=0;
    	for(int i=0;i<key.length;i++)
    		if(key[i]!=a) {
    			newkey[j]=key[i];
    			j++;
    		}
    	this.key=newkey;
    	return key;
    }
    public IntArrayKey addkeytoB(int[] B,int a) {
    	int[] newkey=new int[B.length+1];
    	for(int i=0;i<B.length;i++)
    		newkey[i]=B[i];
    	newkey[newkey.length-1]=a;
    	return new IntArrayKey(newkey);
    }
    public boolean contains(int a) {
    	for(int i:key)
    		if (i==a)
    			return true;
    	return false;
    }

    /**
     * Indicates whether the given {@link Object} <code>k</code> is "equal to"
     * <code>this</code> one:
     * <p>
     * <ul>
     * 	<li><code>k</code> is <code>int[]</code> or {@link IntArrayKey}</li>
     * 	<li>{@link Arrays#equals(int[], int[])} returns true</li>
     * </ul>
     *
     * @see Arrays#equals(int[], int[])
     *
     * @return true if equal, false if not.
     */
    @Override
    public boolean equals(Object k) {
        if (k instanceof int[])				return Arrays.equals((int[])k, key);
        else if (k instanceof IntArrayKey)	return Arrays.equals(((IntArrayKey)k).key(), key);
        else 								return false;
    }

    /**
     * The hashcode of current instance. Set based on instance field {@link #key}:
     * <pre>return Arrays.hashCode(key);</pre>
     *
     * @see  Arrays#hashCode(int[])
     */
    @Override
    public int hashCode() {
        return Arrays.hashCode(key);
    }

    public String toString() {
        return Arrays.toString(key);  //[1,2,3,4,5]
    }
}
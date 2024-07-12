package main.java.IFSICE.entity;

import java.util.ArrayList;

public class ToleranceCollectionUpdateResult {
	private ToleranceCollection BTColl_temp;
	private float THDP_B_newtemp=0;
	private ToleranceCollection newpartBTColl_temp;
	private float THDP_B_newpart=0;
	private ArrayList<ToleranceCollection> crosspartBToll;
	private float THDP_B_cross=0;
	private float THDP_new=0;		
	private boolean is_Empty=false;
	
	public ToleranceCollectionUpdateResult(boolean is_Empty) {this.is_Empty=is_Empty;}
	public ToleranceCollectionUpdateResult(ToleranceCollection BTColl_temp,float THDP_B_newtemp,ToleranceCollection newpartBTColl_temp,float THDP_B_newpart,ArrayList<ToleranceCollection> crosspartBToll,float THDP_B_cross,float THDP_new) {
		this.BTColl_temp=BTColl_temp;
		this.THDP_B_newtemp=THDP_B_newtemp;
		this.newpartBTColl_temp=newpartBTColl_temp;
		this.THDP_B_newpart=THDP_B_newpart;
		this.crosspartBToll=crosspartBToll;
		this.THDP_B_cross=THDP_B_cross;
		this.THDP_new=THDP_new;
	}
	public ToleranceCollection getBTColl_temp() {
		return BTColl_temp;
	}
	public void setBTColl_temp(ToleranceCollection bTColl_temp) {
		BTColl_temp = bTColl_temp;
	}
	public float getTHDP_B_newtemp() {
		return THDP_B_newtemp;
	}
	public void setTHDP_B_newtemp(float tHDP_B_newtemp) {
		THDP_B_newtemp = tHDP_B_newtemp;
	}
	public ToleranceCollection getNewpartBTColl_temp() {
		return newpartBTColl_temp;
	}
	public void setNewpartBTColl_temp(ToleranceCollection newpartBTColl_temp) {
		this.newpartBTColl_temp = newpartBTColl_temp;
	}
	public float getTHDP_B_newpart() {
		return THDP_B_newpart;
	}
	public void setTHDP_B_newpart(float tHDP_B_newpart) {
		THDP_B_newpart = tHDP_B_newpart;
	}
	public ArrayList<ToleranceCollection> getCrosspartBToll() {
		return crosspartBToll;
	}
	public void setCrosspartBToll(ArrayList<ToleranceCollection> crosspartBToll) {
		this.crosspartBToll = crosspartBToll;
	}
	public float getTHDP_B_cross() {
		return THDP_B_cross;
	}
	public void setTHDP_B_cross(float tHDP_B_cross) {
		THDP_B_cross = tHDP_B_cross;
	}
	public float getTHDP_new() {
		return THDP_new;
	}
	public void setTHDP_new(float tHDP_new) {
		THDP_new = tHDP_new;
	}
	public boolean is_Empty() {return this.is_Empty;}
	public void setIs_Empty(boolean is_Empty) {
		this.is_Empty = is_Empty;
	}
	
}

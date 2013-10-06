package com.marcopolo.service.dto;

public class PurchaseResponse {
	
	private String  product_id, transaction_id, deviceId;
	private int status = -1; // -1 error, 0 - success, -2 - already purchased
	private int imagesLeft;
	
	public String getProduct_id() {
		return product_id;
	}
	public void setProduct_id(String product_id) {
		this.product_id = product_id;
	}
	public String getTransaction_id() {
		return transaction_id;
	}
	public void setTransaction_id(String transaction_id) {
		this.transaction_id = transaction_id;
	}
	public String getDeviceId() {
		return deviceId;
	}
	public void setDeviceId(String deviceId) {
		this.deviceId = deviceId;
	}
	public int getStatus() {
		return status;
	}
	public void setStatus(int status) {
		this.status = status;
	}
	public int getImagesLeft() {
		return imagesLeft;
	}
	public void setImagesLeft(int imagesLeft) {
		this.imagesLeft = imagesLeft;
	}
	
	
	
}

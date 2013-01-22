package com.marcopolo.service.dto;

public class PostResponse {
	public String serverUniqueId;
	public int freeImagesLeft;
	public int responseCode;
	public String responseText;
	
	public String getServerUniqueId() {
		return serverUniqueId;
	}
	public void setServerUniqueId(String serverUniqueId) {
		this.serverUniqueId = serverUniqueId;
	}
	public int getFreeImagesLeft() {
		return freeImagesLeft;
	}
	public void setFreeImagesLeft(int freeImagesLeft) {
		this.freeImagesLeft = freeImagesLeft;
	}
	public int getResponseCode() {
		return responseCode;
	}
	public void setResponseCode(int responseCode) {
		this.responseCode = responseCode;
	}
	public String getResponseText() {
		return responseText;
	}
	public void setResponseText(String responseText) {
		this.responseText = responseText;
	}

}

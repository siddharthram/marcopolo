package com.marcopolo.service.dto;

public class PostResponse {
	public String serverUniqueRequestId;
	public int imagesLeft;
	public int responseCode;
	public String responseText;
	public String imageUrl;
	
	public int getImagesLeft() {
		return imagesLeft;
	}
	public void setImagesLeft(int imagesLeft) {
		this.imagesLeft = imagesLeft;
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
	public String getServerUniqueRequestId() {
		return serverUniqueRequestId;
	}
	public void setServerUniqueRequestId(String serverUniqueRequestId) {
		this.serverUniqueRequestId = serverUniqueRequestId;
	}
	public String getImageUrl() {
		return imageUrl;
	}
	public void setImageUrl(String imageUrl) {
		this.imageUrl = imageUrl;
	}

}

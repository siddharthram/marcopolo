package com.marcopolo.service.dto;

public class TaskStatus {
	public String taskId, imageUrl, transcriptionData;
	public int responseCode;
	public String responseText;

	public String getTaskId() {
		return taskId;
	}

	public void setTaskId(String taskId) {
		this.taskId = taskId;
	}

	public String getImageUrl() {
		return imageUrl;
	}

	public void setImageUrl(String imageUrl) {
		this.imageUrl = imageUrl;
	}

	public String getTranscriptionData() {
		return transcriptionData;
	}

	public void setTranscriptionData(String transcriptionData) {
		this.transcriptionData = transcriptionData;
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

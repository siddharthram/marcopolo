package com.marcopolo.service.dto;

public class TaskStatus {
	private String serverUniqueRequestId, clientUniqueRequestId, imageUrl, transcriptionData;
	private int status; // -1 error, 0 - submitted, 1 in progress, 2 completed
	private long serverSubmissionTimeStamp, clientSubmitTimeStamp;

	public long getServerSubmissionTimeStamp() {
		return serverSubmissionTimeStamp;
	}

	public void setServerSubmissionTimeStamp(long serverSubmissionTimeStamp) {
		this.serverSubmissionTimeStamp = serverSubmissionTimeStamp;
	}

	public long getClientSubmitTimeStamp() {
		return clientSubmitTimeStamp;
	}

	public void setClientSubmitTimeStamp(long clientSubmitTimeStamp) {
		this.clientSubmitTimeStamp = clientSubmitTimeStamp;
	}

	public String getServerUniqueRequestId() {
		return serverUniqueRequestId;
	}

	public int getStatus() {
		return status;
	}

	public void setStatus(int status) {
		this.status = status;
	}

	public void setServerUniqueRequestId(String serverUniqueRequestId) {
		this.serverUniqueRequestId = serverUniqueRequestId;
	}

	public String getClientUniqueRequestId() {
		return clientUniqueRequestId;
	}

	public void setClientUniqueRequestId(String clientUniqueRequestId) {
		this.clientUniqueRequestId = clientUniqueRequestId;
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

}

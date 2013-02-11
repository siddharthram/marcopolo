package com.marcopolo.service.dto;

public class TaskStatus {
	private String serverUniqueRequestId, clientUniqueRequestId, imageUrl, transcriptionData, userTranscriptionData, rating, ratingComment;
	private int status; // -1 error, 0 - submitted, 1 in progress, 2 completed
	private long serverSubmissionTimeStamp, clientSubmitTimeStamp, trasncriptionTimeStamp, transcriptionId;
	
	
	public long getTranscriptionId() {
		return transcriptionId;
	}

	public void setTranscriptionId(long transcriptionId) {
		this.transcriptionId = transcriptionId;
	}

	public String getUserTranscriptionData() {
		return userTranscriptionData;
	}

	public void setUserTranscriptionData(String userTranscriptionData) {
		this.userTranscriptionData = userTranscriptionData;
	}

	public String getRating() {
		return rating;
	}

	public void setRating(String rating) {
		this.rating = rating;
	}

	public String getRatingComment() {
		return ratingComment;
	}

	public void setRatingComment(String ratingComment) {
		this.ratingComment = ratingComment;
	}

	public long getTrasncriptionTimeStamp() {
		return trasncriptionTimeStamp;
	}

	public void setTrasncriptionTimeStamp(long trasncriptionTimeStamp) {
		this.trasncriptionTimeStamp = trasncriptionTimeStamp;
	}

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

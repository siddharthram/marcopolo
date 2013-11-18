package com.marcopolo.service.dto;

public class TaskStatus {
	private String serverUniqueRequestId, clientUniqueRequestId, imageUrl, transcriptionData, userTranscriptionData, requestedResponseFormat, rating, ratingComment, attachmentUrl;
	private int status; // -1 error, 0 - submitted, 1 in progress, 2 completed
	private long serverSubmissionTimeStamp, clientSubmitTimeStamp, transcriptionTimeStamp, transcriptionId;

	
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

	public long getTranscriptionTimeStamp() {
		return transcriptionTimeStamp;
	}

	public void setTranscriptionTimeStamp(long transcriptionTimeStamp) {
		this.transcriptionTimeStamp = transcriptionTimeStamp;
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

	public String getAttachmentUrl() {
		return attachmentUrl;
	}

	public void setAttachmentUrl(String attachmentUrl) {
		this.attachmentUrl = attachmentUrl;
	}

	public String getRequestedResponseFormat() {
		return requestedResponseFormat;
	}

	public void setRequestedResponseFormat(String requestedResponseFormat) {
		this.requestedResponseFormat = requestedResponseFormat;
	}

}
package com.marcopolo.service.dto;


public class PostRequest {
	private String auth_id, device_id, urgency, fileName, clientRequestId;
	private long serverSubmissionTimeStamp, clientSubmitTimeStamp;

	public String getAuth_id() {
		return auth_id;
	}
	public void setAuth_id(String auth_id) {
		this.auth_id = auth_id;
	}
	public String getDevice_id() {
		return device_id;
	}
	public void setDevice_id(String device_id) {
		this.device_id = device_id;
	}
	public String getUrgency() {
		return urgency;
	}
	public void setUrgency(String urgency) {
		this.urgency = urgency;
	}
	public String getFileName() {
		return fileName;
	}
	public void setFileName(String fileName) {
		this.fileName = fileName;
	}
	public String getClientRequestId() {
		return clientRequestId;
	}
	public void setClientRequestId(String clientRequestId) {
		this.clientRequestId = clientRequestId;
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
	public boolean hasImage() {
		boolean retVal = true;
		if (fileName == null) {
			retVal = false;
		}
		return retVal;
	}
	/**
	 * For now only make auth_id and device_id as mandatory fields
	 * @return
	 */
	public boolean isValid() {
		if (device_id != null && clientRequestId != null && clientSubmitTimeStamp > 0) {
			return true;
		} else {
			return false;
		}
	}

}

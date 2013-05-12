package com.marcopolo.service.dto;



public class PostRequest {
	private String auth_id, deviceId, urgency, fileName, clientRequestId, requestedResponseFormat;
	private long serverSubmissionTimeStamp, clientSubmitTimeStamp;

	public String getAuth_id() {
		return auth_id;
	}
	public void setAuth_id(String auth_id) {
		this.auth_id = auth_id;
	}
	public String getDeviceId() {
		return deviceId;
	}
	public void setDeviceId(String deviceId) {
		this.deviceId = deviceId;
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
	public String getRequestedResponseFormat() {
		return requestedResponseFormat;
	}
	public void setRequestedResponseFormat(String requestedResponseFormat) {
		if (RequestedFormatTypeEnum.isMember(requestedResponseFormat)) {
			this.requestedResponseFormat = requestedResponseFormat;
		} else {
			this.requestedResponseFormat = RequestedFormatTypeEnum.TXT.toString();
		}
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
		if (deviceId != null && clientRequestId != null && clientSubmitTimeStamp > 0) {
			return true;
		} else {
			return false;
		}
	}

}

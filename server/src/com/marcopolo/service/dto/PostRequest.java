package com.marcopolo.service.dto;

import java.util.Date;

public class PostRequest {
	private String auth_id, device_id, urgency, fileName;
	private Date timestamp;
	
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


	public Date getTimestamp() {
		return timestamp;
	}


	public void setTimestamp(Date timestamp) {
		this.timestamp = timestamp;
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
		if (auth_id != null && device_id != null) {
			return true;
		} else {
			return false;
		}
	}

}

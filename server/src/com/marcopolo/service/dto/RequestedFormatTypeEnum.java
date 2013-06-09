package com.marcopolo.service.dto;

public enum RequestedFormatTypeEnum {
	TXT("txt"), PPT("ppt"), PPTX("pptx");

	private String value;

	private RequestedFormatTypeEnum(String value) {
		this.value = value;
	}

	public String requestedFormatType() {
		return value;
	}

	static public boolean isMember(String aType) {
		RequestedFormatTypeEnum[] aRequestedFormatTypes = RequestedFormatTypeEnum
				.values();
		for (RequestedFormatTypeEnum aRequestedFormatType : aRequestedFormatTypes) {
			if (aRequestedFormatType.value.equals(aType)) {
				return true;
			}
		}
		return false;
	}
}

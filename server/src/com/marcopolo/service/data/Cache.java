package com.marcopolo.service.data;

import java.sql.SQLException;
import java.util.ArrayList;

import urbanairship.Devices;

public class Cache {
	private static ArrayList<String> deviceIdsToExclude = new ArrayList<String>();

	public static void loadDeviceExclusionIds() {
		try {
			deviceIdsToExclude = DataAccess.getExcludedDevices();
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}

	public static boolean isExcludedFromNotification(String deviceId) {
		boolean retVal = false;
		// if deviceid is not empty then check if it exists in arraylist
		if (deviceId != null && !deviceId.trim().equals("")) {
			for (String devid : deviceIdsToExclude) {
				if (deviceId.equals(devid)) {
					retVal = true;
					break;
				}
			}
		}
		return retVal;
	}
}

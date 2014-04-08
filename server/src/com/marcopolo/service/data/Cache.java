package com.marcopolo.service.data;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.concurrent.atomic.AtomicLong;

public class Cache {
	private static ArrayList<String> deviceIdsToExclude = null;
	private static ArrayList<String> notificationSMS = null;
	private static ArrayList<String> notificationEmail = null;

	// 2 mins.. lower bar. can not set below this
	private static final long minInterval = 120000l; 
	private static AtomicLong maxOverDueInterval = new AtomicLong(5400000l); // 90 minutes
	
	private static AtomicLong privateWorkerDuration = new AtomicLong(3600000l); // 60 minutes

	public static long getMaxOverDueInterval() {
		return maxOverDueInterval.get();
	}

	public static long getPrivateWorkerDuration() {
		return privateWorkerDuration.get();
	}

	public static long setPrivateWorkerDuration(long privateWorkerDur) {
		if (privateWorkerDur > minInterval) {
			privateWorkerDuration.set(privateWorkerDur);
		}
		return getPrivateWorkerDuration();
	}

	public static long setMaxOverDueInterval(long maxOverDueInt) {
		if (maxOverDueInt > minInterval) {
			maxOverDueInterval.set(maxOverDueInt);
		}
		return getMaxOverDueInterval();
	}

	public static void loadDeviceExclusionIds() {
		try {
			deviceIdsToExclude = DataAccess.getExcludedDevices();
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}
	
	public static void loadNotificationEmails() {
		try {
			notificationEmail = DataAccess.getNotificationEmails();
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}

	public static void loadNotificationSmses() {
		try {
			notificationSMS = DataAccess.getNotificationSmses();
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
	

	public static ArrayList<String> getDeviceIdsToExclude() {
		return deviceIdsToExclude;
	}

	public static ArrayList<String> getNotificationSMS() {
		return notificationSMS;
	}

	public static ArrayList<String> getNotificationEmail() {
		return notificationEmail;
	}

	public static void loadAll() {
		loadDeviceExclusionIds();
		loadNotificationEmails();
		loadNotificationSmses();
		
	}
}
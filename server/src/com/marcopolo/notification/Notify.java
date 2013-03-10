package com.marcopolo.notification;

import java.io.IOException;

import com.twilio.sdk.TwilioRestException;

public class Notify {

	public static void main(String[] args) {

		Notify.notifyTranscribers();
	}

	private static String[] phoneNumbers = new String[] { "16504174483" }; // ,
																			// "16502694868",
																			// "16503195789"};
	public static void notifyTranscribers() {

		for (int i = 0; i < phoneNumbers.length; i++) {
			sendSMS(phoneNumbers[i]);
		}
	}

	public static void sendSMS(String number) {

		try {
			TwilioSMSClient.sendSMS(number);
		} catch (TwilioRestException e) {
			e.printStackTrace();
		}
		
	}
}

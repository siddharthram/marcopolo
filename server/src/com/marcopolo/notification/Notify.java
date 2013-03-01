package com.marcopolo.notification;

import java.io.IOException;

import com.techventus.server.voice.Voice;

public class Notify {
	
	private static String[] phoneNumbers = new String[] {"16504174483", "16502694868", "16503195789"};
	
	private static final String USERNAME = "gvanika.z.mailbx@recursor.net";
	private static final String PASSWORD = "mukrecm9";
	
	public static final String MESSAGE = "new image available to transcribe.";
	
	public static void notifyTranscribers() throws IOException {
		Voice voice = new Voice(USERNAME, PASSWORD);
		for (int i = 0; i < phoneNumbers.length; i++) {
			sendSMS(phoneNumbers[i], voice);
		}
	}
	
	public static void sendSMS(String number, Voice voice) throws IOException {
		voice.sendSMS(number, MESSAGE);
	}
}

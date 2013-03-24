package com.marcopolo.notification;

import java.util.ArrayList;
import java.util.Iterator;

import javax.mail.Message.RecipientType;

import org.codemonkey.simplejavamail.Email;
import org.codemonkey.simplejavamail.Mailer;
import org.codemonkey.simplejavamail.TransportStrategy;

import com.marcopolo.service.data.Cache;
import com.twilio.sdk.TwilioRestException;

public class Notify {

	public static void main(String[] args) {

		Notify.notifyTranscribers();
	}

	public static void notifyTranscribers() {
		sendSMS(Cache.getNotificationSMS());
		sendEmail(Cache.getNotificationEmail());
	}
	
	public static void sendSMS(ArrayList<String> smsAddresses) {
		for (int i = 0; i < smsAddresses.size(); i++) {
			sendSMS(smsAddresses.get(i));
		}
	}

	public static void sendSMS(String number) {

		try {
			TwilioSMSClient.sendSMS(number);
		} catch (TwilioRestException e) {
			e.printStackTrace();
		}
		
	}
	
	public static void sendEmail(ArrayList<String> emails) {
		final Email email = new Email();
		email.setFromAddress("Ximly", "ximly12@gmail.com");
		email.setSubject("New Transcription available.");
		for (Iterator<String> emailIter = emails.iterator(); emailIter.hasNext();) {
			String emailAdd = (String) emailIter.next();
			email.addRecipient("Transcriber", emailAdd, RecipientType.BCC);
		}
		email.setText("A new trascription is available. Please log into http://ximly.herokuapp.com/users/sign_in to start transcribing.");
		new Mailer("smtp.gmail.com", 587, "ximly12@gmail.com", "marcopolo12", TransportStrategy.SMTP_TLS).sendMail(email);
	}
}

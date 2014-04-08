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

//		Notify.notifyTranscribers();
/*		ArrayList<String> emails = new ArrayList<String>();
		emails.add("mukesh_agg@hotmail.com");
		Notify.sendAWSEmail(emails);
*/	}

	public static void notifyTranscribers() {
		sendSMS(Cache.getNotificationSMS());
		sendAWSEmail(Cache.getNotificationEmail());
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

	public static void sendAWSEmail(ArrayList<String> emails) {
		final Email email = new Email();
		email.setFromAddress("Ximly", "ximlynotification@gmail.com");
		email.setSubject("Transcription from Ximly");
		for (Iterator<String> emailIter = emails.iterator(); emailIter.hasNext();) {
			String emailAdd = (String) emailIter.next();
			email.addRecipient("Transcriber", emailAdd, RecipientType.BCC);
		}
		email.setText("A new trascription is available. Please log into http://ximly.herokuapp.com/users/sign_in to start transcribing. You will have " + Cache.getPrivateWorkerDuration()/1000 + " minutes to complete the job after accepting. After that job will be unlocked for other workers.");
		new Mailer("email-smtp.us-east-1.amazonaws.com", 587, "AKIAJ54BVQ2QQYKQCK5Q", "AuEozWpJ6pv/nzsOqPiuWw+xrFlE50tw1JSA5NGRHKbg", TransportStrategy.SMTP_TLS).sendMail(email);
	}

	
	public static void sendGmailEmail(ArrayList<String> emails) {
		final Email email = new Email();
		email.setFromAddress("Ximly", "ximlynotification@gmail.com");
		email.setSubject("Transcription from Ximly");
		for (Iterator<String> emailIter = emails.iterator(); emailIter.hasNext();) {
			String emailAdd = (String) emailIter.next();
			email.addRecipient("Transcriber", emailAdd, RecipientType.BCC);
		}
		email.setText("A new trascription is available. Please log into http://ximly.herokuapp.com/users/sign_in to start transcribing.");
		new Mailer("smtp.gmail.com", 587, "ximlynotification@gmail.com", "n26pCqIzjPIS0oqiJ1xw", TransportStrategy.SMTP_TLS).sendMail(email);
	}
}

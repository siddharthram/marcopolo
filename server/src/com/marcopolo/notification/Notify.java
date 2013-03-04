package com.marcopolo.notification;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.codec.binary.Base64;
import org.apache.http.Consts;
import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.util.EntityUtils;

import sun.misc.BASE64Encoder;

public class Notify {

	public static void main(String[] args) throws IOException {

		Notify.notifyTranscribers();
	}

	private static String[] phoneNumbers = new String[] { "16504174483" }; // ,
																			// "16502694868",
																			// "16503195789"};

	private static final String username = new String(Base64.encodeBase64("AC8a2e738a7d63decc61765870fce4bc8b".getBytes()));
	
	private static final String password = new String(Base64.encodeBase64("13ad6b49f4d1a883590e225c2b4a7481".getBytes()));
	private static final String auth = username + ":" + password;
	private static final String USERNAME = "anisha.i.mailbx@recursor.net";
	private static final String PASSWORD = "mukrecm9";

	public static final String MESSAGE = "new image available to transcribe.";

	public static void notifyTranscribers() throws IOException {

		//Voice voice = new Voice(USERNAME, PASSWORD);
		for (int i = 0; i < phoneNumbers.length; i++) {
			sendSMS(phoneNumbers[i]);
		}
	}

	public static void sendSMS(String number) throws IOException {
		//voice.sendSMS(number, MESSAGE);

		DefaultHttpClient client = new DefaultHttpClient();
		
		HttpPost httppost = new HttpPost("https://api.twilio.com/2010-04-01/Accounts/AC8a2e738a7d63decc61765870fce4bc8b/SMS/Messages.xml");
		httppost.setHeader("Authorization", "Basic " + auth);
		httppost.setHeader("Content-Type", "application/x-www-form-urlencoded"); 
		
		List<NameValuePair> nvps = new ArrayList<NameValuePair>();
		nvps.add(new BasicNameValuePair("From", "+16616674123"));
		nvps.add(new BasicNameValuePair("To", number));
		
		
		httppost.setEntity(new UrlEncodedFormEntity(nvps, Consts.UTF_8));
		HttpResponse response = client.execute(httppost);
		HttpEntity entity = response.getEntity();
		String pageHTML = EntityUtils.toString(entity);
        System.out.println(pageHTML);
		
		
	}
}

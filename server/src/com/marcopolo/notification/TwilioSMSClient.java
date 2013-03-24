package com.marcopolo.notification;
import java.util.HashMap;
import java.util.Map;

import com.twilio.sdk.TwilioRestClient;
import com.twilio.sdk.TwilioRestException;
import com.twilio.sdk.TwilioRestResponse;
import com.twilio.sdk.resource.factory.SmsFactory;
import com.twilio.sdk.resource.instance.Account;

public class TwilioSMSClient {
	private static final String ACCOUNT_SID = "ACf12c09a36402a19385cff7db34daeb32";
	private static final String AUTH_TOKEN = "199e9076f7019e7fd1ac903031e48aeb";
	public static final String MESSAGE = "new image available to transcribe.";

	// Create a rest client
	private static final TwilioRestClient TWILIOCLIENT = new TwilioRestClient(
			ACCOUNT_SID, AUTH_TOKEN);
	// Get the main account (The one we used to authenticate the client)
	private static final Account TWILIOMAINACCOUNT = TWILIOCLIENT.getAccount();
	private static final SmsFactory SMSFACTORY = TWILIOMAINACCOUNT
			.getSmsFactory();

	private static final String FROMNUMBER = "(408) 469-4835";

	public static void sendSMS(String phoneNumber) throws TwilioRestException {

		final Map<String, String> smsParams = new HashMap<String, String>();

		smsParams.put("To", phoneNumber); // Replace with a valid phone number
		smsParams.put("From", FROMNUMBER); // Replace with a valid phone
		smsParams.put("Body", MESSAGE);
		SMSFACTORY.create(smsParams);
		// Make a raw HTTP request to the api... note, this is deprecated style
		final TwilioRestResponse resp = TWILIOCLIENT.request(
				"/2010-04-01/Accounts", "GET", null);
		if (!resp.isError()) {
			System.out.println(resp.getResponseText());
		}

	}
	
	public static void main(String[] args) {
		try {
			sendSMS("6503195789");
		} catch (TwilioRestException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

}
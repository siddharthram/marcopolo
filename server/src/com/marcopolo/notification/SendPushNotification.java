package com.marcopolo.notification;


public class SendPushNotification {


	public static void sendPushNotification(String apnsDeviceId, String serverUniqueRequestId) {

		com.marcopolo.urbanairship.UrbanAirshipClient.sendPush(apnsDeviceId, serverUniqueRequestId)	;
/*		p.setMessage("Your transcription is ready !");
		p.addPayloadValue("serverUniqueRequestId", serverUniqueRequestId);
		client.sendPushNotifications(p);
*/		
	}
	

}

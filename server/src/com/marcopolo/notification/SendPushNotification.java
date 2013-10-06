package com.marcopolo.notification;

import urbanairship.APS;
import urbanairship.Device;
import urbanairship.Push;
import urbanairship.UrbanAirshipClient;

public class SendPushNotification {

	private static UrbanAirshipClient client = new UrbanAirshipClient(
			"atnfkp1eSF6D0JWxACQQKA", "HNycfmlVTZKEpJbPDbkEvQ");

	public static void main(String[] args) {

	}

	public static void sendPushNotification(String apnsDeviceId, String serverUniqueRequestId) {
		Device device = new Device();

		device.setiOSDeviceToken(apnsDeviceId);
		client.register(device);

		Push p = new Push();
		APS aps = new APS();
		p.setAps(aps);
		p.addDeviceToken(apnsDeviceId);
		p.setMessage("Your transcription is ready !");
		p.addPayloadValue("serverUniqueRequestId", serverUniqueRequestId);
		client.sendPushNotifications(p);
		
	}
	

}

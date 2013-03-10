package com.marcopolo.service;

import urbanairship.APS;
import urbanairship.Device;
import urbanairship.Push;
import urbanairship.UrbanAirshipClient;

public class SendNotification {

	private static UrbanAirshipClient client = new UrbanAirshipClient(
			"45KzZ2wDRuikd5c6eSzG2g", "O9Y_D6gVRn2XwdwCf2PeTA");

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
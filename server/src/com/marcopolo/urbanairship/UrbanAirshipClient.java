package com.marcopolo.urbanairship;

import java.io.IOException;

import org.apache.log4j.BasicConfigurator;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.urbanairship.api.client.APIClient;
import com.urbanairship.api.client.APIClientResponse;
import com.urbanairship.api.client.APIPushResponse;
import com.urbanairship.api.client.APIRequestException;
import com.urbanairship.api.push.model.DeviceType;
import com.urbanairship.api.push.model.DeviceTypeData;
import com.urbanairship.api.push.model.PushPayload;
import com.urbanairship.api.push.model.audience.Selectors;
import com.urbanairship.api.push.model.notification.Notification;
import com.urbanairship.api.push.model.notification.Notifications;
import com.urbanairship.api.push.model.notification.ios.IOSBadgeData;
import com.urbanairship.api.push.model.notification.ios.IOSDevicePayload;

/*
 * Copyright 2013 Urban Airship and Contributors
 */
public class UrbanAirshipClient {

    private static final Logger logger = LoggerFactory.getLogger("com.urbanairship.api");
	private static String appKey = "atnfkp1eSF6D0JWxACQQKA";
	private static String appSecret = "U6yjggS4QP6KJGEToF42aQ";

    public static void sendPush(String deviceToken, String serverUniqueRequestId){

        APIClient apiClient = APIClient.newBuilder()
                                       .setKey(appKey)
                                       .setSecret(appSecret)
                                       .build();
        logger.debug(String.format("Setup an APIClient to handle the API call %s", apiClient.toString()));
        logger.debug("Send the message");

        IOSBadgeData badgeData = IOSBadgeData.newBuilder()
                .setValue(1)
                .setType(IOSBadgeData.Type.INCREMENT)
                .build();
        
        IOSDevicePayload iosPayload = IOSDevicePayload.newBuilder()
                .setAlert("Your transcription is ready !")
                .setBadge(badgeData)
                .addExtraEntry("serverUniqueRequestId", serverUniqueRequestId)
                .build();
        
        Notification notification = Notifications.notification(iosPayload);
        
        PushPayload payload = PushPayload.newBuilder()
                                         .setAudience(Selectors.deviceToken(deviceToken))
                                         .setNotification(notification)
                                         .setDeviceTypes(DeviceTypeData.of(DeviceType.IOS))
                                         .build();
        
        try {
            APIClientResponse<APIPushResponse> response = apiClient.push(payload);
            logger.debug("PUSH SUCCEEDED");
            logger.debug(String.format("RESPONSE:%s", response.toString()));
        }
        catch (APIRequestException ex){
            logger.error(String.format("APIRequestException " + ex));
            logger.error("EXCEPTION " + ex.toString());
        }
        catch (IOException e){
            logger.error("IOException in API request " + e.getMessage());
        }

    }

    public static void main(String args[]){
//        BasicConfigurator.configure();
        logger.debug("Starting test push");
        UrbanAirshipClient example = new UrbanAirshipClient();
        example.sendPush("c670c3df1d3a14d5fbbf472c71659fca82f6035cf539c0dc2102d6a22a787215", "dbc79144-794f-4cd0-9e82-ab13ec86b528");
        //example.sendScheduledPush();

    }
}

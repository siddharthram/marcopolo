package com.marcopolo.urbanairship;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.auth.AuthenticationException;
import org.apache.http.auth.UsernamePasswordCredentials;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpPut;
import org.apache.http.impl.auth.BasicScheme;
import org.apache.http.impl.client.DefaultHttpClient;
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
	private static UsernamePasswordCredentials creds = new UsernamePasswordCredentials(appKey, appSecret);

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

    public static void register(String token) throws IOException, AuthenticationException {

    	HttpClient httpclient = new DefaultHttpClient();
    	
    	HttpPut putMethod = new HttpPut("https://go.urbanairship.com/api/device_tokens/" + token);
    	putMethod.addHeader(new BasicScheme().authenticate(creds, putMethod));
    	
        HttpResponse response = httpclient.execute(putMethod);
        System.out.println(response.getStatusLine());
        HttpEntity entity = response.getEntity();
        BufferedReader in = new BufferedReader(new InputStreamReader(entity.getContent()));
        try {
        	  String inputLine;
              while ((inputLine = in.readLine()) != null) {
                     //System.out.println(inputLine);
              }
              in.close();
         } catch (IOException e) {
              e.printStackTrace();
         }
    }
    
    public static void main(String args[]) throws IOException, AuthenticationException{
//        BasicConfigurator.configure();
    	
    	// deviceId=0BC63237-B540-423F-A8EC-017B4ED42873&apnsDeviceId=021b29b39d7a2615aa0560de6f414c18133e45f898e6636d46af115bafc295b0&updateApns=t
        logger.debug("Starting test push");
        register("021b29b39d7a2615aa0560de6f414c18133e45f898e6636d46af115bafc295b0");
        sendPush("021b29b39d7a2615aa0560de6f414c18133e45f898e6636d46af115bafc295b0", "dbc79144-794f-4cd0-9e82-ab13ec86b528");
        //example.sendScheduledPush();

    }
}

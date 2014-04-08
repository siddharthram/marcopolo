package com.marcopolo.service.apple;

import gvjava.org.json.JSONException;
import gvjava.org.json.JSONObject;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.net.HttpURLConnection;
import java.net.URL;

import javax.net.ssl.HttpsURLConnection;


public class ApplePayments
{
    private final static String _sandboxUriStr = "https://sandbox.itunes.apple.com/verifyReceipt";
    private final static String _productionUriStr = "https://buy.itunes.apple.com/verifyReceipt";

    
    public static void main(String[] args) {
    	try {
    		System.out.println(ApplePayments.isReceiptGenuine("ewoJInNpZ25hdHVyZSIgPSAiQWp6cjgwZ3piUUpIU05SczNYaDdQOFdZYkdPb2JqNFZZdnZjVVFJbTdmZHpPRHE5RVdqYVMrTTJqNnlhQzBkRGpMZVZuQ1JvbWJWcFRKNURrZzIwODU1WHgra0pYTmYxdXBuYWMwNVV5UFhVRjdCOGZrSjVjY2M3MUNnR0lsRlJRLy9ZUEdYeTlkTmM2N0ZzYXNkMlhVcEFvRlpUdWNTZTlJcXlybW1LVTZkWUFBQURWekNDQTFNd2dnSTdvQU1DQVFJQ0NHVVVrVTNaV0FTMU1BMEdDU3FHU0liM0RRRUJCUVVBTUg4eEN6QUpCZ05WQkFZVEFsVlRNUk13RVFZRFZRUUtEQXBCY0hCc1pTQkpibU11TVNZd0pBWURWUVFMREIxQmNIQnNaU0JEWlhKMGFXWnBZMkYwYVc5dUlFRjFkR2h2Y21sMGVURXpNREVHQTFVRUF3d3FRWEJ3YkdVZ2FWUjFibVZ6SUZOMGIzSmxJRU5sY25ScFptbGpZWFJwYjI0Z1FYVjBhRzl5YVhSNU1CNFhEVEE1TURZeE5USXlNRFUxTmxvWERURTBNRFl4TkRJeU1EVTFObG93WkRFak1DRUdBMVVFQXd3YVVIVnlZMmhoYzJWU1pXTmxhWEIwUTJWeWRHbG1hV05oZEdVeEd6QVpCZ05WQkFzTUVrRndjR3hsSUdsVWRXNWxjeUJUZEc5eVpURVRNQkVHQTFVRUNnd0tRWEJ3YkdVZ1NXNWpMakVMTUFrR0ExVUVCaE1DVlZNd2daOHdEUVlKS29aSWh2Y05BUUVCQlFBRGdZMEFNSUdKQW9HQkFNclJqRjJjdDRJclNkaVRDaGFJMGc4cHd2L2NtSHM4cC9Sd1YvcnQvOTFYS1ZoTmw0WElCaW1LalFRTmZnSHNEczZ5anUrK0RyS0pFN3VLc3BoTWRkS1lmRkU1ckdYc0FkQkVqQndSSXhleFRldngzSExFRkdBdDFtb0t4NTA5ZGh4dGlJZERnSnYyWWFWczQ5QjB1SnZOZHk2U01xTk5MSHNETHpEUzlvWkhBZ01CQUFHamNqQndNQXdHQTFVZEV3RUIvd1FDTUFBd0h3WURWUjBqQkJnd0ZvQVVOaDNvNHAyQzBnRVl0VEpyRHRkREM1RllRem93RGdZRFZSMFBBUUgvQkFRREFnZUFNQjBHQTFVZERnUVdCQlNwZzRQeUdVakZQaEpYQ0JUTXphTittVjhrOVRBUUJnb3Foa2lHOTJOa0JnVUJCQUlGQURBTkJna3Foa2lHOXcwQkFRVUZBQU9DQVFFQUVhU2JQanRtTjRDL0lCM1FFcEszMlJ4YWNDRFhkVlhBZVZSZVM1RmFaeGMrdDg4cFFQOTNCaUF4dmRXLzNlVFNNR1k1RmJlQVlMM2V0cVA1Z204d3JGb2pYMGlreVZSU3RRKy9BUTBLRWp0cUIwN2tMczlRVWU4Y3pSOFVHZmRNMUV1bVYvVWd2RGQ0TndOWXhMUU1nNFdUUWZna1FRVnk4R1had1ZIZ2JFL1VDNlk3MDUzcEdYQms1MU5QTTN3b3hoZDNnU1JMdlhqK2xvSHNTdGNURXFlOXBCRHBtRzUrc2s0dHcrR0szR01lRU41LytlMVFUOW5wL0tsMW5qK2FCdzdDMHhzeTBiRm5hQWQxY1NTNnhkb3J5L0NVdk02Z3RLc21uT09kcVRlc2JwMGJzOHNuNldxczBDOWRnY3hSSHVPTVoydG04bnBMVW03YXJnT1N6UT09IjsKCSJwdXJjaGFzZS1pbmZvIiA9ICJld29KSW05eWFXZHBibUZzTFhCMWNtTm9ZWE5sTFdSaGRHVXRjSE4wSWlBOUlDSXlNREV6TFRBNUxUSXlJREUyT2pJMU9qQXhJRUZ0WlhKcFkyRXZURzl6WDBGdVoyVnNaWE1pT3dvSkluVnVhWEYxWlMxcFpHVnVkR2xtYVdWeUlpQTlJQ0kwTWpZM05Ua3hZekppT1RZNE5XSXhPVFk0WVRVNVltUmtNalExT0RoaU5UUXdPR1l6Wm1WaElqc0tDU0p2Y21sbmFXNWhiQzEwY21GdWMyRmpkR2x2YmkxcFpDSWdQU0FpTVRBd01EQXdNREE0TnpnM056RXhNeUk3Q2draVluWnljeUlnUFNBaU1DNHdMakUzSWpzS0NTSjBjbUZ1YzJGamRHbHZiaTFwWkNJZ1BTQWlNVEF3TURBd01EQTROemczTnpFeE15STdDZ2tpY1hWaGJuUnBkSGtpSUQwZ0lqRWlPd29KSW05eWFXZHBibUZzTFhCMWNtTm9ZWE5sTFdSaGRHVXRiWE1pSUQwZ0lqRXpOems0T1RJek1ERTBOelFpT3dvSkluVnVhWEYxWlMxMlpXNWtiM0l0YVdSbGJuUnBabWxsY2lJZ1BTQWlOa1kyTXpsRFEwSXRSRUl4TlMwME9FVXdMVGxCUlVFdE5Ea3lSRFJDUkVFek5qQXdJanNLQ1NKd2NtOWtkV04wTFdsa0lpQTlJQ0pqYjIwdWVHbHRiSGt1YzIxaGJHd3VkR1Z6ZENJN0Nna2lhWFJsYlMxcFpDSWdQU0FpTnpFek56QTFPVFEzSWpzS0NTSmlhV1FpSUQwZ0ltTnZiUzVpYjJGeVpHTmhjSFIxY21VdVltOWhjbVJqWVhCMGRYSmxJanNLQ1NKd2RYSmphR0Z6WlMxa1lYUmxMVzF6SWlBOUlDSXhNemM1T0RreU16QXhORGMwSWpzS0NTSndkWEpqYUdGelpTMWtZWFJsSWlBOUlDSXlNREV6TFRBNUxUSXlJREl6T2pJMU9qQXhJRVYwWXk5SFRWUWlPd29KSW5CMWNtTm9ZWE5sTFdSaGRHVXRjSE4wSWlBOUlDSXlNREV6TFRBNUxUSXlJREUyT2pJMU9qQXhJRUZ0WlhKcFkyRXZURzl6WDBGdVoyVnNaWE1pT3dvSkltOXlhV2RwYm1Gc0xYQjFjbU5vWVhObExXUmhkR1VpSUQwZ0lqSXdNVE10TURrdE1qSWdNak02TWpVNk1ERWdSWFJqTDBkTlZDSTdDbjA9IjsKCSJlbnZpcm9ubWVudCIgPSAiU2FuZGJveCI7CgkicG9kIiA9ICIxMDAiOwoJInNpZ25pbmctc3RhdHVzIiA9ICIwIjsKfQ=="));
		} catch (Exception e) {
			// do nothing
			e.printStackTrace();
		}
    	
	}
    
    public static boolean isReceiptGenuine(final String receiptBase64Encoded) throws Exception {
    	boolean isGenuine = false;
    	try {
    		// first check with production server
			String appleResponse = processPayment(receiptBase64Encoded, _productionUriStr);
			JSONObject json = new JSONObject(appleResponse);
			String appleResp = json.getString("status");
            // check if ticket is valid
			if ("0".equals(appleResp)) {
            	isGenuine = true;
            } else if ("21007".equals(appleResp)) {  // check if it is a sandbox ticket
            	appleResponse = processPayment(receiptBase64Encoded, _sandboxUriStr); // check ticket against sandbox
            	json = new JSONObject(appleResponse);
            	if ("0".equals(json.getString("status"))) {
                	isGenuine = true;
            	}
            }
		} catch (Exception e) {
			e.printStackTrace();
			throw e;
		}
    	return isGenuine;
    	
    }
    
    public static String processPayment(final String receiptBase64Encoded, final String serverUrl) throws IOException, JSONException
    {
        final String jsonData = "{\"receipt-data\" : \"" + receiptBase64Encoded + "\"}";
        try
        {
            final URL url = new URL(serverUrl);
            final HttpURLConnection conn = (HttpsURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setDoOutput(true);
            conn.setRequestProperty("Content-Type", "application/json");
            conn.setRequestProperty("Accept", "application/json");

            final OutputStreamWriter wr = new OutputStreamWriter(conn.getOutputStream());
            wr.write(jsonData);
            wr.flush();

            // Get the response
            final BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream()));
            StringBuilder sb = new StringBuilder();
            String line; 
            while (null != (line = reader.readLine()))
            {
                sb.append(line);
            }
            
            wr.close();
            reader.close();
            return sb.toString();
        }
        catch (IOException e)
        {
            throw new IOException("Error when trying to send request to apple", e);
        }
    }
}
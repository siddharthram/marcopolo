package com.marcopolo.service;

import java.io.IOException;
import java.io.PrintWriter;
import java.lang.reflect.Type;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.marcopolo.service.data.DataAccess;
import com.marcopolo.service.dto.TaskStatusRequest;
import com.marcopolo.service.dto.TaskStatusResponse;

/**
 * Servlet implementation class add
 */
public class submit extends AbstractServlet {
	private static final long serialVersionUID = 1L;

	private Log log = LogFactory.getLog(submit.class);
	
	
	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public submit() {
		super();
	}

	
	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doPost(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		TaskStatusResponse taskStatusResponse = new TaskStatusResponse();
		try {
			
			TaskStatusRequest tsr = new TaskStatusRequest();
			String guid = request.getParameter("serverUniqueRequestId");
			String transcript = request.getParameter("output");
			log.debug("Got parameters as serverUniqueRequestId='" + guid + "' and output='" + transcript + "'");
			if (guid != null && !guid.trim().equals("")) {
				String apnsDeviceId = DataAccess.submit(guid, transcript);
				if (apnsDeviceId != null && !apnsDeviceId.equals("")) {
					SendNotification.sendPushNotification(apnsDeviceId, guid);
				} else {
					log.debug("No apns id found so not sending push notification");
				}
			}
		} catch (Exception ex) {
			log.error("Error when submitting", ex);
			throw new ServletException(ex);
		}
		response.setContentType("application/json");
		PrintWriter writer = response.getWriter();
		Gson gson = new Gson();
		Type postRespType = new TypeToken<TaskStatusResponse>() {}.getType();
		writer.println(gson.toJson(taskStatusResponse, postRespType));
		gson = null;
	}


}

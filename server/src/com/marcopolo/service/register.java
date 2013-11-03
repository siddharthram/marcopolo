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
 * Servlet implementation class register (a new device)
 */
public class register extends AbstractServlet {
	private static final long serialVersionUID = 1L;

	private Log log = LogFactory.getLog(register.class);
	
	
	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public register() {
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
			String ximlyDeviceId = request.getParameter("deviceId");
			String phoneDeviceId = request.getParameter("apnsDeviceId");
			String updateApns = request.getParameter("updateApns");
			log.debug("Got parameters for register as deviceId='" + ximlyDeviceId + "' and apnsDeviceId ='" + phoneDeviceId + "'");
			if (ximlyDeviceId != null && !ximlyDeviceId.trim().equals("")) {
				taskStatusResponse = DataAccess.register(ximlyDeviceId, phoneDeviceId, updateApns);
			} else {
				throw new Exception("Required parameters not sent for registration");
			}
		} catch (Exception ex) {
			log.error("Error when registring", ex);
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

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
 * Servlet implementation class register
 */
public class rate extends AbstractServlet {
	private static final long serialVersionUID = 1L;

	private Log log = LogFactory.getLog(rate.class);
	
	
	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public rate() {
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
			String guid = request.getParameter("serverUniqueRequestId");
			String transcriptionId = request.getParameter("transcriptionId");
			String rating = request.getParameter("rating");
			String ratingComment = request.getParameter("ratingComment");
			String userTranscriptionData = request.getParameter("userTranscriptionData");
			
			log.debug("Got parameters for ratings as deviceId='" + ximlyDeviceId + "' and guid ='" + guid + "'");
			if (ximlyDeviceId != null && !ximlyDeviceId.trim().equals("") && transcriptionId != null && !transcriptionId.trim().equals("")) {
				DataAccess.rate(ximlyDeviceId, transcriptionId, guid, rating, ratingComment, userTranscriptionData);
			} else {
				throw new Exception("Required parameters not sent for registration");
			}
		} catch (Exception ex) {
			log.error("Error when saving ratings", ex);
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

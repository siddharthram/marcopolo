package com.marcopolo.service;

import java.io.IOException;
import java.io.PrintWriter;
import java.lang.reflect.Type;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
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


@WebServlet(
	    name = "task", 
	    urlPatterns = {"/task/mine"}
	)
/**
 * Servlet implementation class add
 */
public class task extends HttpServlet {
	private static final long serialVersionUID = 1L;

	private Log log = LogFactory.getLog(task.class);
	
	
	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public task() {
		super();
	}

	public void init() throws ServletException {
		try {
			log.debug("initalizing servlet");			
			// initalize database access layer
			DataAccess.init((Context) new InitialContext().lookup("java:comp/env"));
		} catch (NamingException e) {
			throw new ServletException(e);
		}
	}


	
	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doPost(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		response.setContentType("text/xml");
		TaskStatusResponse taskStatusResponse = new TaskStatusResponse();
		try {
			TaskStatusRequest tsr = new TaskStatusRequest();
			String deviceId = request.getParameter("device_id");
			if (deviceId != null && !deviceId.trim().equals("")) {
				tsr.setDeviceId(deviceId);
				taskStatusResponse  = DataAccess.getStatus(tsr);
			}
		} catch (Exception ex) {
			throw new ServletException(ex);
		}
		response.setContentType("application/json");
		PrintWriter writer = response.getWriter();
		Gson gson = new Gson();
		Type postRespType = new TypeToken<TaskStatusResponse>() {}.getType();
		writer.println(gson.toJson(taskStatusResponse, postRespType));
	}


}

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
 * Servlet implementation class to fetch details of a job by server Guid
 */
public class taskByGuid extends AbstractServlet {
	private static final long serialVersionUID = 1L;

	private Log log = LogFactory.getLog(taskByGuid.class);
	
	
	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public taskByGuid() {
		super();
	}

	
	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doGet(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		response.setContentType("text/xml");
		TaskStatusResponse taskStatusResponse = new TaskStatusResponse();
		try {
			TaskStatusRequest tsr = new TaskStatusRequest();
			String sguId = request.getParameter("serverUniqueRequestId");
			if (sguId != null && !sguId.trim().equals("")) {
				tsr.setTaskId(sguId);
				taskStatusResponse  = DataAccess.getTaskByServerGuid(tsr);
			}
		} catch (Exception ex) {
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

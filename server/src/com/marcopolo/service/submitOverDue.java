package com.marcopolo.service;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Iterator;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.amazonaws.mturk.requester.HIT;
import com.marcopolo.mturk.ExternalQuestion;
import com.marcopolo.service.data.DataAccess;
import com.marcopolo.service.dto.TaskStatus;
import com.marcopolo.service.dto.TaskStatusResponse;



/**
 * Servlet implementation class add
 */
public class submitOverDue extends AbstractServlet {
	private static final long serialVersionUID = 1L;

	private Log log = LogFactory.getLog(submitOverDue.class);
	
	public void init() throws ServletException {
		try {
			super.init();
			String propertiesPath = getServletContext().getRealPath("config");
			ExternalQuestion.init(propertiesPath);
		} catch (Exception e) {
			throw new ServletException(e);
		}
	}

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public submitOverDue() {
		super();
	}

	
	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doGet(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		response.setContentType("text/plain");
		TaskStatusResponse taskStatusResponse = new TaskStatusResponse();
		StringBuilder resp = new StringBuilder();
		try {
			taskStatusResponse  = DataAccess.getOverDueOpenTasks();
			String turkprice = request.getParameter("turkprice");
			ArrayList<TaskStatus> overdueTasks = taskStatusResponse.getTaskStatuses();
			for (Iterator<TaskStatus> taskIter = overdueTasks.iterator(); taskIter
					.hasNext();) {
				TaskStatus taskStatus = (TaskStatus) taskIter.next();
				try {
					HIT hit = ExternalQuestion.submitMturkJob(taskStatus, turkprice);
					// store hit ids in table
					DataAccess.updateHitId(taskStatus.getServerUniqueRequestId(), hit.getHITId());
					resp.append("Created HIT: " + hit.getHITId() + " with price " + hit.getReward().toString());
					resp.append("\nYou may see your HIT with HITTypeId '" + hit.getHITTypeId() + "' here: ");
					resp.append("\n" +  "/mturk/preview?groupId=" + hit.getHITTypeId());
				} catch (Exception e) {
					resp.append("Error when creating hit for task with ServerUniqueRequestId=" + taskStatus.getServerUniqueRequestId());
					resp.append("\nAnd error is " + e.getLocalizedMessage());
				}
				resp.append("\n================================================\n");
			}
			
		} catch (Exception ex) {
			resp.append(ex.getLocalizedMessage());
			//throw new ServletException(ex);
		}
		response.setContentType("application/json");
		PrintWriter writer = response.getWriter();
		writer.println(resp);
	}
}

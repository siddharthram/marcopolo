package com.marcopolo.service;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.marcopolo.service.data.Cache;



/**
 * Servlet implementation class to fetch details of a job by server Guid
 */
public class setMaxOverDueInterval extends AbstractServlet {
	private static final long serialVersionUID = 1L;

	private Log log = LogFactory.getLog(setMaxOverDueInterval.class);
	
	
	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public setMaxOverDueInterval() {
		super();
	}

	
	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doGet(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		response.setContentType("text/xml");
		long overDueIntervalForTurkSubmit = -60000l;
		long overDueIntervalForPendingPrivateWorker = -60000l;
		
		try {
			String interval = request.getParameter("intervalinMin");
			overDueIntervalForTurkSubmit = Integer.parseInt(interval) * 60000l; //convert to millisecs
			// set interval 
			overDueIntervalForTurkSubmit = Cache.setMaxOverDueInterval(overDueIntervalForTurkSubmit); 
		} catch (Exception ex) {
			//throw new ServletException(ex);
		}
		try {
			String interval = request.getParameter("workerPendingUnlockInMin");
			overDueIntervalForPendingPrivateWorker = Integer.parseInt(interval) * 60000l; //convert to millisecs
			// set interval 
			overDueIntervalForPendingPrivateWorker = Cache.setPrivateWorkerDuration(overDueIntervalForPendingPrivateWorker); 
		} catch (Exception ex) {
			//throw new ServletException(ex);
		}

		response.setContentType("application/json");
		PrintWriter writer = response.getWriter();
		writer.println(overDueIntervalForTurkSubmit/60000 + " mins\n");
		writer.println(overDueIntervalForPendingPrivateWorker/60000 + " mins");		
	}


}

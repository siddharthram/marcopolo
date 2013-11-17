package com.marcopolo.service;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.marcopolo.mturk.ExternalQuestion;
import com.marcopolo.mturk.MturkSubmitTask;



/**
 * Servlet implementation class to send tasks over to turk
 */
public class submitOverDue extends AbstractServlet {
	private static final long serialVersionUID = 1L;

	private Log log = LogFactory.getLog(submitOverDue.class);
	
	public void init() throws ServletException {
		try {
			super.init();
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
		String resp = new String();
		try {
			String turkprice = request.getParameter("turkprice");
			MturkSubmitTask mturkTask = new MturkSubmitTask();
			resp = mturkTask.submitAllTasksToTurk(turkprice);
			
		} catch (Exception ex) {
			resp = ex.getLocalizedMessage();
			//throw new ServletException(ex);
		}
		response.setContentType("application/json");
		PrintWriter writer = response.getWriter();
		writer.println(resp);
	}
}

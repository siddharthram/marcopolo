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
	 */
	protected void service(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		long longInterval = -60000l;
		try {
			String interval = request.getParameter("intervalinMin");
			longInterval = Integer.parseInt(interval) * 60000l; //convert to millisecs
			// set interval 
			longInterval = Cache.setMaxOverDueInterval(longInterval); 
			
		} catch (Exception ex) {
			// do nothing
			longInterval = Cache.getMaxOverDueInterval();
		}
		response.setContentType("text/plain");
		PrintWriter writer = response.getWriter();
		writer.println(longInterval/60000 + " mins");
	}


}

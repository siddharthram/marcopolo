package com.marcopolo.service;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.marcopolo.service.data.DataAccess;


/**
 * Servlet implementation class add
 */
public abstract class AbstractServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	private static final long MAX_FILE_SIZE_IN_BYTES = 40000000l; // about 4 MB's

	private Log log = LogFactory.getLog(AbstractServlet.class);
	
	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public AbstractServlet() {
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


}

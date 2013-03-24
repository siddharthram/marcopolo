package com.marcopolo.service;

import java.io.IOException;
import java.io.PrintWriter;
import java.lang.reflect.Type;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.marcopolo.notification.Notify;
import com.marcopolo.service.dto.PostResponse;


/**
 * Servlet implementation class add
 */
@WebServlet(name = "testsmsapi", urlPatterns = { "/MarcoPolo/task/testsmsapi" })
public class testsmsapi extends AbstractServlet {
	private static final long serialVersionUID = 1L;

	private static final long MAX_FILE_SIZE_IN_BYTES = 40000000l; // about 4 MB's

	private Log log = LogFactory.getLog(testsmsapi.class);
	
	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public testsmsapi() {
		super();
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void service(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		response.setContentType("text/xml");
		PostResponse presp = new PostResponse();
		try {
			String ximlyDeviceId = request.getParameter("deviceId");
			if ("ds2asdfasd34232fasdf".equals(ximlyDeviceId)) {
				Notify.notifyTranscribers();
			}
		} catch (Exception ex) {
			presp.setResponseCode(-1);
			presp.setResponseText(ex.getLocalizedMessage());
		}
		response.setContentType("application/json");
		PrintWriter writer = response.getWriter();
		Gson gson = new Gson();
		Type postRespType = new TypeToken<PostResponse>() {}.getType();
		writer.println(gson.toJson(presp, postRespType));
		gson = null;

	}

}

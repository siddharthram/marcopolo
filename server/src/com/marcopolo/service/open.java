package com.marcopolo.service;

import java.io.IOException;
import java.io.PrintWriter;
import java.lang.reflect.Type;
import java.util.Iterator;
import java.util.List;
import java.util.UUID;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.FileItemFactory;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.marcopolo.service.aws.S3StoreImage;
import com.marcopolo.service.data.DataAccess;
import com.marcopolo.service.dto.PostRequest;
import com.marcopolo.service.dto.PostResponse;


@WebServlet(
	    name = "open", 
	    urlPatterns = {"/task/open"}
	)
/**
 * Servlet implementation class add
 */
public class open extends HttpServlet {
	private static final long serialVersionUID = 1L;

	private Log log = LogFactory.getLog(open.class);
	
	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public open() {
		super();
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doPost(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		response.setContentType("text/xml");
/*		try {
			DataAccess.getStatus(taskReq)
		} catch (Exception ex) {
		}
		PrintWriter writer = response.getWriter();
		Gson gson = new Gson();
		Type postRespType = new TypeToken<PostResponse>() {}.getType();
		writer.println(gson.toJson(presp, postRespType));
*/
	}


}

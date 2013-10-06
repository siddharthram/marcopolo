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
import com.marcopolo.service.dto.ProductsResponse;
import com.marcopolo.service.dto.TaskStatusRequest;
import com.marcopolo.service.dto.TaskStatusResponse;



/**
 * Servlet implementation class to list all tasks from a device
 */
public class product extends AbstractServlet {
	private static final long serialVersionUID = 1L;

	private Log log = LogFactory.getLog(product.class);
	
	
	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public product() {
		super();
	}

	
	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doPost(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		response.setContentType("text/xml");
		ProductsResponse productsResponse = new ProductsResponse();
		try {
			String deviceId = request.getParameter("deviceId");
			if (deviceId != null && !deviceId.trim().equals("")) {
				productsResponse  = DataAccess.getProducts();
			}
		} catch (Exception ex) {
			throw new ServletException(ex);
		}
		response.setContentType("application/json");
		PrintWriter writer = response.getWriter();
		Gson gson = new Gson();
		Type postRespType = new TypeToken<ProductsResponse>() {}.getType();
		writer.println(gson.toJson(productsResponse, postRespType));
		gson = null;
	}


}

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
import com.marcopolo.service.apple.ApplePayments;
import com.marcopolo.service.data.DataAccess;
import com.marcopolo.service.dto.ProductsResponse;
import com.marcopolo.service.dto.PurchaseResponse;



/**
 * Servlet implementation class to list all tasks from a device
 */
public class purchase extends AbstractServlet {
	private static final long serialVersionUID = 1L;

	private Log log = LogFactory.getLog(purchase.class);
	
	
	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public purchase() {
		super();
	}

	
	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doPost(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		response.setContentType("text/xml");
		PurchaseResponse purchaseResponse = new PurchaseResponse();
		
		try {
			String deviceId = request.getParameter("deviceId");
			String productId = request.getParameter("product_id");
			String transactionId = request.getParameter("transaction_id");
			String receipt = request.getParameter("receipt_data");
			if (deviceId != null && !deviceId.trim().equals("") &&
					productId != null && !productId.trim().equals("") &&
							transactionId != null && !transactionId.trim().equals("")
					) {
				if (ApplePayments.isReceiptGenuine(receipt)) {
					purchaseResponse = DataAccess.purchase(deviceId, productId, transactionId);
				}
			}
		} catch (Exception ex) {
			throw new ServletException(ex);
		}
		response.setContentType("application/json");
		PrintWriter writer = response.getWriter();
		Gson gson = new Gson();
		

		Type purchaseRespType = new TypeToken<PurchaseResponse>() {}.getType();
		writer.println(gson.toJson(purchaseResponse, purchaseRespType));
		gson = null;
	}


}

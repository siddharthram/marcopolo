package com.marcopolo.service;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.UUID;

import javax.mail.internet.MimeMessage.RecipientType;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.FileItemFactory;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import org.codemonkey.simplejavamail.Email;
import org.codemonkey.simplejavamail.Mailer;
import org.codemonkey.simplejavamail.TransportStrategy;

import com.marcopolo.service.data.DataAccess;
import com.marcopolo.service.dto.PostRequest;
import com.marcopolo.service.dto.PostResponse;

/**
 * Servlet implementation class add
 */
public class add extends HttpServlet {
	private static final long serialVersionUID = 1L;

	private static final long MAX_FILE_SIZE_IN_BYTES = 10000000l;
	private static final String fromName = "Mark Polson";
	private static final String fromEmail = "markpolson50@gmail.com";
	private static final String emailPass = "rem2mb3rm3";
	private static final String toEmail = fromEmail;

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public add() {
		super();
		// TODO Auto-generated constructor stub
	}

	public void init() throws ServletException {
		try {
			// initalize database access layer
			DataAccess.init((Context) new InitialContext().lookup("java:comp/env"));
		} catch (NamingException e) {
			throw new ServletException(e);
		}
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doPost(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		response.setContentType("text/xml");
		int taskResponse = 0;
		String taskResponseText = "Success";
		try {
			handleUploadRequest(request);
			taskResponse = 1;
		} catch (Exception ex) {
			taskResponseText = ex.getMessage();
		}
		PrintWriter writer = response.getWriter();
		writer.println("<xml><Success>" + taskResponse + "</Success><Reason>"
				+ taskResponseText + "</Reason></xml>");

	}

	private void handleUploadRequest(HttpServletRequest request)
			throws Exception {
		boolean isMultipart = ServletFileUpload.isMultipartContent(request);
		PostResponse presp = new PostResponse();
		presp.setServerUniqueId(UUID.randomUUID().toString());
		PostRequest postReq = new PostRequest();
		postReq.setTimestamp(new Date());
		// if request is not multipart, i.e. no file upload then send just
		// response with free trial left
		if (isMultipart) {
			// Create a factory for disk-based file items
			FileItemFactory factory = new DiskFileItemFactory();
			// Create a new file upload handler
			ServletFileUpload upload = new ServletFileUpload(factory);

			// limit the file upload size
			upload.setFileSizeMax(MAX_FILE_SIZE_IN_BYTES);
			boolean isFileUploaded = false;
			List<FileItem> items = upload.parseRequest(request);
			Iterator<FileItem> iter = items.iterator();

			// iterating over parameters sent in request
			while (iter.hasNext()) {
				FileItem item = (FileItem) iter.next();
				if (item.isFormField()) {
					String name = item.getFieldName();
					if ("auth_id".equals(name)) {
						postReq.setAuth_id(item.getString());
					}
					if ("device_id".equals(name)) {
						postReq.setDevice_id(item.getString());
					}
					if ("urgency".equals(name)) {
						postReq.setUrgency(item.getString());
					}
				} else {
					isFileUploaded = true;
					String fileName = item.getName();
					postReq.setFileName(fileName);
					long sizeInBytes = item.getSize();
					byte[] pngData = item.get();
					// email the file
					if (postReq.isValid()) {
						// sendEmail(postReq, pngData, "image/png");

					} else {
						throw new Exception("All parameters not sent.");
					}
				}
			}
			if (!postReq.isValid()) {
				throw new Exception("Parameters not set.");
			}

		} else {
			// upload is not multipart
			throw new Exception("Invalid request. Not multipart.");
		}

	}

	private void sendEmail(PostRequest taskReq, byte[] pngData, String string) {
		final Email email = new Email();

		email.setFromAddress(fromName, fromEmail);
		email.setSubject("New task request");
		email.addRecipient("Task Requested", toEmail, RecipientType.TO);
		/*
		 * email.setText(String .format(
		 * "New task received at %1$tD %1$tH:%1$tM:%1$tS from user id %2$s with description '%3$s' and priority %4$s. Output format requested is %5$s."
		 * , taskReq.getTimestamp() taskReq.getUserId(),
		 * taskReq.getDescription(), taskReq.getPriority(),
		 * taskReq.getOutput_type())
		 * 
		 * );
		 */
		// embed images and include downloadable attachments
		email.addEmbeddedImage(taskReq.getFileName(), pngData, "image/png");

		new Mailer("smtp.gmail.com", 587, fromEmail, emailPass,
				TransportStrategy.SMTP_TLS).sendMail(email);

	}
}

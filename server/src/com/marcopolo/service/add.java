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
	    name = "new", 
	    urlPatterns = {"/task/new"}
	)
/**
 * Servlet implementation class add
 */
public class add extends HttpServlet {
	private static final long serialVersionUID = 1L;

	private static final long MAX_FILE_SIZE_IN_BYTES = 4000000l; // about 4 MB's

	private Log log = LogFactory.getLog(add.class);
	
	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public add() {
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

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doPost(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		response.setContentType("text/xml");
		PostResponse presp = new PostResponse();
		try {
			presp = handleUploadRequest(request);
		} catch (Exception ex) {
			presp.setResponseCode(-1);
			presp.setResponseText(ex.getLocalizedMessage());
		}
		PrintWriter writer = response.getWriter();
		Gson gson = new Gson();
		Type postRespType = new TypeToken<PostResponse>() {}.getType();
		writer.println(gson.toJson(presp, postRespType));

	}

	private PostResponse handleUploadRequest(HttpServletRequest request)
			throws Exception {
		boolean isMultipart = ServletFileUpload.isMultipartContent(request);
		PostResponse presp = new PostResponse();
		presp.setServerUniqueId(UUID.randomUUID().toString());
		PostRequest postReq = new PostRequest();
		postReq.setServerSubmissionTimeStamp(System.currentTimeMillis());
		// if request is not multipart, i.e. no file upload then send just
		// response with free trial left
		if (isMultipart) {
			// Create a factory for disk-based file items
			FileItemFactory factory = new DiskFileItemFactory();
			// Create a new file upload handler
			ServletFileUpload upload = new ServletFileUpload(factory);

			// limit the file upload size
			upload.setFileSizeMax(MAX_FILE_SIZE_IN_BYTES);
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
					if ("client_request_id".equals(name)) {
						postReq.setClientRequestId(item.getString());
					}
					if ("client_submission_timestamp".equals(name)) {
						postReq.setClientSubmitTimeStamp(Long.parseLong(item.getString()));
					}
					if ("urgency".equals(name)) {
						postReq.setUrgency(item.getString());
					}
				} else {
					String fileName = item.getName();
					postReq.setFileName(fileName);
					long sizeInBytes = item.getSize();
					byte[] pngData = item.get();
					// store file on S3
					if (postReq.isValid()) {
						// sendEmail(postReq, pngData, "image/png");
						String imageUrl = S3StoreImage.storeS3File(presp.getServerUniqueId(), pngData);
						presp.setImage_url(imageUrl);
						DataAccess.storeRequestData(postReq, presp);
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
		return presp;
	}

}

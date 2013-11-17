package com.marcopolo.service;

import java.io.IOException;
import java.io.PrintWriter;
import java.lang.reflect.Type;
import java.util.Iterator;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

import javax.servlet.ServletException;
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
import com.marcopolo.mturk.ExternalQuestion;
import com.marcopolo.mturk.JobSubmitScheduledExecuter;
import com.marcopolo.mturk.MturkSubmitTask;
import com.marcopolo.notification.Notify;
import com.marcopolo.service.aws.S3StoreImage;
import com.marcopolo.service.data.Cache;
import com.marcopolo.service.data.DataAccess;
import com.marcopolo.service.dto.PostRequest;
import com.marcopolo.service.dto.PostResponse;


/**
 * Servlet implementation class add a new task
 */
public class add extends AbstractServlet {
	private static final long serialVersionUID = 1L;

	private static final long MAX_FILE_SIZE_IN_BYTES = 40000000l; // about 4 MB's

	private Log log = LogFactory.getLog(add.class);
	
	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public add() {
		super();
	}
	
	public void init() throws ServletException {
		try {
			super.init();
			Cache.loadAll();
			// initialize the scheduler which will submit the job to mturk
			new JobSubmitScheduledExecuter(1).scheduleAtFixedRate(new MturkSubmitTask(), 5, 5, TimeUnit.MINUTES);
			String propertiesPath = getServletContext().getRealPath("config");
			ExternalQuestion.init(propertiesPath);
		} catch (Exception e) {
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
		response.setContentType("application/json");
		PrintWriter writer = response.getWriter();
		Gson gson = new Gson();
		Type postRespType = new TypeToken<PostResponse>() {}.getType();
		writer.println(gson.toJson(presp, postRespType));
		gson = null;

	}

	private PostResponse handleUploadRequest(HttpServletRequest request)
			throws Exception {
		boolean isMultipart = ServletFileUpload.isMultipartContent(request);
		PostResponse presp = new PostResponse();
		presp.setServerUniqueRequestId(UUID.randomUUID().toString());
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
					if ("authId".equals(name)) {
						postReq.setAuth_id(item.getString());
					}
					if ("deviceId".equals(name)) {
						postReq.setDeviceId(item.getString());
					}
					if ("clientUniqueRequestId".equals(name)) {
						postReq.setClientRequestId(item.getString());
					}
					if ("clientSubmitTimeStamp".equals(name)) {
						postReq.setClientSubmitTimeStamp(Long.parseLong(item.getString()));
					}
					if ("urgency".equals(name)) {
						postReq.setUrgency(item.getString());
					}
					if ("requestedResponseFormat".equals(name)) {
						postReq.setRequestedResponseFormat(item.getString());
					}
				} else {
					String fileName = item.getName();
					postReq.setFileName(fileName);
					long sizeInBytes = item.getSize();
					byte[] pngData = item.get();
					// store file on S3
					if (postReq.isValid()) {
						// sendEmail(postReq, pngData, "image/png");
						String imageUrl = S3StoreImage.storeS3pngFile(presp.getServerUniqueRequestId(), pngData);
						presp.setImageUrl(imageUrl);
						DataAccess.storeRequestData(postReq, presp);
						// if device id is in exclusion list then do not send notification
						if (!Cache.isExcludedFromNotification(postReq.getDeviceId())) {
							Notify.notifyTranscribers();
						}
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

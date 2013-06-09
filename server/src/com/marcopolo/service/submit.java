package com.marcopolo.service;

import java.io.IOException;
import java.io.PrintWriter;
import java.lang.reflect.Type;
import java.util.Iterator;
import java.util.List;

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
import com.marcopolo.notification.Notify;
import com.marcopolo.notification.SendPushNotification;
import com.marcopolo.service.aws.S3StoreImage;
import com.marcopolo.service.data.Cache;
import com.marcopolo.service.data.DataAccess;
import com.marcopolo.service.dto.RequestedFormatTypeEnum;
import com.marcopolo.service.dto.TaskStatusRequest;
import com.marcopolo.service.dto.TaskStatusResponse;

/**
 * Servlet implementation class add
 */
public class submit extends AbstractServlet {
	private static final long serialVersionUID = 1L;

	private Log log = LogFactory.getLog(submit.class);
	private static final long MAX_FILE_SIZE_IN_BYTES = 400000000l; // about 40
																	// MB's

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public submit() {
		super();
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doPost(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		TaskStatusResponse taskStatusResponse = new TaskStatusResponse();
		String guid = null;
		String transcript = null;
		String attachmentUrl = null;
		String attachmentFileExtension = "pptx";

		try {
			TaskStatusRequest tsr = new TaskStatusRequest();
			boolean isMultipart = ServletFileUpload.isMultipartContent(request);
			//System.out.println("submit api form type is isMultipart=" + isMultipart);
			if (isMultipart) {
				System.out.println("got multipart request");
				// Create a factory for disk-based file items
				FileItemFactory factory = new DiskFileItemFactory();
				// Create a new file upload handler
				ServletFileUpload upload = new ServletFileUpload(factory);
				
				// limit the file upload size
				upload.setFileSizeMax(MAX_FILE_SIZE_IN_BYTES);
				List<FileItem> items = upload.parseRequest(request);
				Iterator<FileItem> iter = items.iterator();
				while (iter.hasNext()) {
					FileItem item = (FileItem) iter.next();
					if (item.isFormField()) {
						String name = item.getFieldName();
						if ("serverUniqueRequestId".equals(name)) {
							guid = item.getString();
							System.out.println("serverUniqueRequestId=" + guid);
						}
						if ("output".equals(name)) {
							transcript = item.getString();
							System.out.println("output=" + transcript);
						}
						if ("attachmentFileExtension".equals(name)) {
							String fileext = item.getString();
							if (RequestedFormatTypeEnum.isMember(fileext)) {
								attachmentFileExtension = fileext; 
							}
							System.out.println("attachmentFileExtension=" + attachmentFileExtension);
						}
					} else {
						String fileName = item.getName();
						long sizeInBytes = item.getSize();
						System.out.println("filename=" + fileName + " and size=" + sizeInBytes);
						
						byte[] attachmentData = item.get();
						// store file on S3
						if (guid != null && !guid.equals("")) {
							attachmentUrl = S3StoreImage.storeS3AttachmentFile(guid,
									attachmentData, attachmentFileExtension);
							System.out.println("attachmentUrl=" + attachmentUrl);
						}
					}
				}
			} else {
				guid = request.getParameter("serverUniqueRequestId");
				transcript = request.getParameter("output");
			}
			log.debug("Got parameters as serverUniqueRequestId='" + guid
					+ "' and output='" + transcript + "'");

			System.out.println("Got parameters as serverUniqueRequestId='" + guid
					+ "' and output='" + transcript + "'");

			if (guid != null && !guid.trim().equals("")) {
				String apnsDeviceId = DataAccess.submit(guid, transcript, attachmentUrl);
				if (apnsDeviceId != null && !apnsDeviceId.equals("")) {
					SendPushNotification.sendPushNotification(apnsDeviceId,
							guid);
				} else {
					log.debug("No apns id found so not sending push notification");
				}
			}

		} catch (Exception ex) {
			log.error("Error when submitting", ex);
			System.out.println(ex);
			throw new ServletException(ex);
		}
		response.setContentType("application/json");
		PrintWriter writer = response.getWriter();
		Gson gson = new Gson();
		Type postRespType = new TypeToken<TaskStatusResponse>() {
		}.getType();
		writer.println(gson.toJson(taskStatusResponse, postRespType));
		gson = null;
	}

}

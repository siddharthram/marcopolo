package com.marcopolo.service.data;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Iterator;

import javax.naming.Context;
import javax.naming.NamingException;
import javax.servlet.ServletException;
import javax.sql.DataSource;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.marcopolo.service.dto.PostRequest;
import com.marcopolo.service.dto.PostResponse;
import com.marcopolo.service.dto.Product;
import com.marcopolo.service.dto.ProductsResponse;
import com.marcopolo.service.dto.PurchaseResponse;
import com.marcopolo.service.dto.TaskStatus;
import com.marcopolo.service.dto.TaskStatusRequest;
import com.marcopolo.service.dto.TaskStatusResponse;

public class DataAccess {
	private final static String AWS_DATASOURCE_NAME = "jdbc/marcopoloaws";
	private final static int MAX_FREE_TASKS = 5;
	private final static long MAX_OVERDUE_INTERVAL_IN_MILSEC = 10800000l;// 3 hours 
																		// in
																		// millisec
	
//	private final static long MAX_OVERDUE_INTERVAL_IN_MILSEC = 120000l;// 2 mins
																		// in
																		// millisec for testing only
	
	private static DataSource _dataSource;

	private static Log log = LogFactory.getLog(DataAccess.class);

	public void setDataSource(DataSource dataSource) {
		_dataSource = dataSource;
	}

	public DataSource getDataSource() {
		return _dataSource;
	}

	public static void init(Context env) throws ServletException {
		log.debug("Initialzing datasource");

		if (_dataSource == null) {
			try {
				_dataSource = (DataSource) env.lookup(AWS_DATASOURCE_NAME);
				if (_dataSource == null) {
					log.error("Could not find datasource name "
							+ AWS_DATASOURCE_NAME);
					throw new ServletException("'" + AWS_DATASOURCE_NAME
							+ "' datasources can not be found");
				}
				// }
			} catch (NamingException e) {
				log.error("Error initlaizing datasource. The error was ", e);
				throw new ServletException(e);
			}
		}
	}

	private static String freeTaskQuery = "select iddevice, free_tasks_left from device_table where device_id = ?";
	private static String insertDeviceRow = "insert into device_table (device_id, free_tasks_left, is_internal_device) values(?,?, 0)";

	private static String insertTask = "insert into task_table (image_url, server_submit_time, device_table_iddevice, server_unique_guid, client_unique_guid, client_submit_time, status, requestedResponseFormat) values(?, ?, ?, ?, ?, ?, 0, ?)";
	private static String updateCount = "update device_table set free_tasks_left = (free_tasks_left-1) where device_id = ?";

	/**
	 * Gets the request and persists it in db
	 * 
	 * @param preq
	 * @return
	 * @throws SQLException
	 */
	public static void storeRequestData(PostRequest preq, PostResponse presp)
			throws SQLException {
		int freeTasksLeft = MAX_FREE_TASKS; // default to max free
		int iddevice = 0; // our assigned id
		Connection conn = _dataSource.getConnection();
		log.debug("Got request for storing image for device id "
				+ preq.getDeviceId());
		// select free_tasks_left from user_table ut, device_table dt where
		// ut.iduser = dt.user_table_iduser
		try {

			PreparedStatement pstmtQuery = conn.prepareStatement(freeTaskQuery);
			pstmtQuery.setString(1, preq.getDeviceId());
			ResultSet rs = pstmtQuery.executeQuery();
			if (rs.next()) {
				// get id of row and free tasks left
				iddevice = rs.getInt(1);
				freeTasksLeft = rs.getInt(2);
				rs.close();
				pstmtQuery.close();
				log.debug("Found device table row for free tasks for device id "
						+ preq.getDeviceId());
			} else {
				log.debug("No device table rows found for device id "
						+ preq.getDeviceId());
				pstmtQuery.close();
				// insert device row
				PreparedStatement pstmtInsert = conn.prepareStatement(
						insertDeviceRow,
						PreparedStatement.RETURN_GENERATED_KEYS);
				pstmtInsert.setString(1, preq.getDeviceId());
				pstmtInsert.setInt(2, MAX_FREE_TASKS);
				pstmtInsert.executeUpdate();
				// get id of inserted row
				ResultSet rsInsert = pstmtInsert.getGeneratedKeys();
				rsInsert.next();
				iddevice = rsInsert.getInt(1);
				rsInsert.close();
				pstmtInsert.close();
			}

			// check if task can be submitted
			if (freeTasksLeft < 1) {
				// set 'sorry quota exceeded' response
				presp.setResponseCode(-1);
				presp.setResponseText("Quota exceeded");
				log.debug("Max free tasks " + freeTasksLeft + " exceeded for "
						+ preq.getDeviceId());
			} else {

				log.debug("Tasks " + freeTasksLeft + " left for for "
						+ preq.getDeviceId());
				// private static String insertTask =
				// "insert into task_table (image_url, sumbit_time, device_table_iddevice, unique_guid) values(?, ?, ?, ?)";
				PreparedStatement pstmtInsert = conn
						.prepareStatement(insertTask);
				// image_url, server_sumbit_time, device_table_iddevice,
				// server_unique_guid, client_unique_guid, cleint_submit_time

				pstmtInsert.setString(1, presp.getImageUrl());
				pstmtInsert.setLong(2, preq.getServerSubmissionTimeStamp());
				pstmtInsert.setInt(3, iddevice);
				pstmtInsert.setString(4, presp.getServerUniqueRequestId());
				pstmtInsert.setString(5, preq.getClientRequestId());
				pstmtInsert.setLong(6, preq.getClientSubmitTimeStamp());
				pstmtInsert.setString(7, preq.getRequestedResponseFormat());
				pstmtInsert.executeUpdate();
				pstmtInsert.close();
				// reduce the count
				pstmtInsert = conn.prepareStatement(updateCount);
				pstmtInsert.setString(1, preq.getDeviceId());
				pstmtInsert.executeUpdate();
				pstmtInsert.close();
				freeTasksLeft--;

				presp.setResponseCode(0);
				presp.setResponseText("Success");
			}

			presp.setImagesLeft(freeTasksLeft);
		} finally {
			try {
				conn.close();
			} catch (Exception e) {
				log.error("Error closing connection", e);
			}
		}
	}

	private static String taskStatusQuery = "select * from task_table tt "
			+ "join device_table dt on dt.iddevice = tt.device_table_iddevice and dt.device_id = ? "
			+ "left outer join assignment_table at on tt.idtask = at.task_table_idtask ";

	public static TaskStatusResponse getStatus(TaskStatusRequest taskReq)
			throws SQLException {

		TaskStatusResponse taskStatusResponse = new TaskStatusResponse();
		Connection conn = _dataSource.getConnection();
		try {
			log.debug("Got request for status for device id "
					+ taskReq.getDeviceId());
			String statusQuery = taskStatusQuery;
			if (taskReq.getTaskId() != null
					&& !taskReq.getTaskId().trim().equals("")) {
				log.debug("got task id " + taskReq.getTaskId());
				statusQuery += " where tt.server_unique_guid = ? ";
			}
			PreparedStatement pstmtQuery = conn.prepareStatement(statusQuery);

			pstmtQuery.setString(1, taskReq.getDeviceId());

			if (taskReq.getTaskId() != null
					&& !taskReq.getTaskId().trim().equals("")) {
				pstmtQuery.setString(2, taskReq.getTaskId());
			}

			ResultSet rs = pstmtQuery.executeQuery();
			while (rs.next()) {
				TaskStatus ts = new TaskStatus();
				ts.setImageUrl(rs.getString("tt.image_url"));
				ts.setClientUniqueRequestId(rs
						.getString("tt.client_unique_guid"));
				ts.setServerUniqueRequestId(rs.getString("server_unique_guid"));
				ts.setClientSubmitTimeStamp(rs.getLong("client_submit_time"));
				ts.setServerSubmissionTimeStamp(rs
						.getLong("server_submit_time"));
				ts.setUserTranscriptionData(rs.getString("user_transcription"));
				ts.setStatus(rs.getInt("tt.status"));
				ts.setRequestedResponseFormat(rs.getString("tt.requestedResponseFormat"));
				// set the number of tasks
				taskStatusResponse.setImagesLeft(rs.getInt("free_tasks_left"));
				// check if task completed
				if (ts.getStatus() == 2) {
					ts.setTranscriptionId(rs.getLong("idassignment"));
					ts.setTranscriptionTimeStamp(rs.getLong("completion_time"));
					ts.setTranscriptionData(rs.getString("jobresult"));
					ts.setRating(rs.getString("rating"));
					ts.setRatingComment(rs.getString("rating_comment"));
					ts.setAttachmentUrl(rs.getString("attachment_url"));
				}
				taskStatusResponse.addTaskStatus(ts);
			}
			
			if (taskStatusResponse.getTaskStatuses().size() == 0 ) {
				taskStatusResponse.setImagesLeft(getFreeTasks(taskReq.getDeviceId(), conn));
			}
			rs.close();
			pstmtQuery.close();
		} finally {
			try {
				conn.close();
			} catch (Exception e) {
				log.error("Error closing connection", e);
			}
		}
		return taskStatusResponse;
	}

	private static String updateRegisterRow = "update device_table set apns_device_id = ? where device_id = ?";
	private static String addRegisterRow = "insert ignore into device_table (device_id, apns_device_id, free_tasks_left, is_internal_device) values(?,?,?, 0)";

	public static TaskStatusResponse register(String ximlyDeviceId, String apnsDeviceId, String updateApns)
			throws SQLException {

		Connection conn = _dataSource.getConnection();
		TaskStatusResponse resp = new TaskStatusResponse();
		try {
			// take care of null apns id
			if (null == apnsDeviceId) {
				apnsDeviceId = "";
			}
			
			
			// update or erase the value of apns id
			log.debug("Got register request");
			int rows = 0;
			PreparedStatement pstmtQuery = null;
			if ("t".equalsIgnoreCase(updateApns)) {
				pstmtQuery = conn.prepareStatement(updateRegisterRow);
				pstmtQuery.setString(1, apnsDeviceId);
				pstmtQuery.setString(2, ximlyDeviceId);
				rows = pstmtQuery.executeUpdate();
				pstmtQuery.close();
			}

			// if no row was found then insert the row
			if (rows == 0) {
				pstmtQuery = conn.prepareStatement(addRegisterRow);
				pstmtQuery.setString(1, ximlyDeviceId);
				pstmtQuery.setString(2, apnsDeviceId);
				pstmtQuery.setInt(3, MAX_FREE_TASKS);
				pstmtQuery.executeUpdate();
				pstmtQuery.close();
			}
			resp.setImagesLeft(getFreeTasks(ximlyDeviceId, conn));
		} finally {
			try {
				conn.close();
			} catch (Exception e) {
				log.error("Error closing connection", e);
			}
		}
		return resp;

	}

	private static String deleteExistingResponse = "delete from assignment_table where task_table_idtask in (select idtask from task_table where server_unique_guid = ?) ";
	private static String storeResponseQuery = "insert into assignment_table set jobresult = ?, cost = 0, completion_time = ?, attachment_url = ?, task_table_idtask = (select idtask from task_table where server_unique_guid = ?) ";
	private static String getApnsId = "select * from device_table dt, task_table tt "
			+ " where dt.iddevice = tt.device_table_iddevice and tt.server_unique_guid  = ?";

	private static String copyUserTranscription = "update task_table set user_transcription = ?, status = 2 where server_unique_guid = ?";

	public static String submit(String guid, String response, String attachmentUrl)
			throws SQLException {

		Connection conn = _dataSource.getConnection();
		String apnsId = "";
		try {
			log.debug("Got request to submit transcript for guid " + guid);
			// delete existing transcription
			PreparedStatement pstmtQuery = conn
					.prepareStatement(deleteExistingResponse);
			pstmtQuery.setString(1, guid);
			pstmtQuery.executeUpdate();
			pstmtQuery.close();
			// store new transcription
			pstmtQuery = conn.prepareStatement(storeResponseQuery);
			pstmtQuery.setString(1, response);
			pstmtQuery.setLong(2, System.currentTimeMillis());
			pstmtQuery.setString(3, attachmentUrl);
			pstmtQuery.setString(4, guid);
			pstmtQuery.executeUpdate();
			pstmtQuery.close();
			// get apns device id
			pstmtQuery = conn.prepareStatement(getApnsId);
			pstmtQuery.setString(1, guid);
			ResultSet rs = pstmtQuery.executeQuery();
			if (rs.next()) {
				apnsId = rs.getString("apns_device_id");
			}
			pstmtQuery.close();
			// set user transcription
			pstmtQuery = conn.prepareStatement(copyUserTranscription);
			pstmtQuery.setString(1, response);
			pstmtQuery.setString(2, guid);
			pstmtQuery.executeUpdate();
			pstmtQuery.close();

		} finally {
			try {
				conn.close();
			} catch (Exception e) {
				log.error("Error closing connection", e);
			}
		}
		return apnsId;

	}

	// find device ids for which we don't want to send notification
	private static String deviceExclusionQuery = "select device_id from device_table where is_internal_device = 1";

	public static ArrayList<String> getExcludedDevices() throws SQLException {

		ArrayList<String> excludedDeviceIds = new ArrayList<String>();
		Connection conn = _dataSource.getConnection();
		try {
			log.debug("Got excluded device list request");
			PreparedStatement pstmtQuery = conn
					.prepareStatement(deviceExclusionQuery);
			ResultSet rs = pstmtQuery.executeQuery();
			while (rs.next()) {
				excludedDeviceIds.add(rs.getString("device_id"));
			}
			rs.close();
			pstmtQuery.close();
		} finally {
			try {
				conn.close();
			} catch (Exception e) {
				log.error("Error closing connection", e);
			}
		}
		return excludedDeviceIds;

	}

	private static String getTaskByServerGuidQuery = "select * from task_table where server_unique_guid = ? ";

	public static TaskStatusResponse getTaskByServerGuid(
			TaskStatusRequest taskReq) throws SQLException {

		TaskStatusResponse taskStatusResponse = new TaskStatusResponse();
		Connection conn = _dataSource.getConnection();
		try {
			log.debug("Got request for all overdue tasks ");
			PreparedStatement pstmtQuery = conn
					.prepareStatement(getTaskByServerGuidQuery);
			pstmtQuery.setString(1, taskReq.getTaskId());

			ResultSet rs = pstmtQuery.executeQuery();
			while (rs.next()) {
				TaskStatus ts = new TaskStatus();
				ts.setImageUrl(rs.getString("image_url"));
				ts.setStatus(rs.getInt("status"));
				ts.setClientUniqueRequestId(rs.getString("client_unique_guid"));
				ts.setServerUniqueRequestId(rs.getString("server_unique_guid"));
				ts.setClientSubmitTimeStamp(rs.getLong("client_submit_time"));
				ts.setServerSubmissionTimeStamp(rs
						.getLong("server_submit_time"));
				ts.setRequestedResponseFormat(rs.getString("requestedResponseFormat"));
				taskStatusResponse.addTaskStatus(ts);
			}
			rs.close();
			pstmtQuery.close();
		} finally {
			try {
				conn.close();
			} catch (Exception e) {
				log.error("Error closing connection", e);
			}
		}
		return taskStatusResponse;
	}

	/**
	 * Used for submitting overdue tasks to aws
	 * 
	 * @return
	 * @throws SQLException
	 */

	private static String blockOverDueTasks = "update task_table tt join device_table dt on tt.device_table_iddevice = dt.iddevice " + 
											  "set tt.status = ?, tt.assigned_to = 'mturk' where dt.is_internal_device = 0 and tt.status = 0 and tt.server_submit_time < ?";
	private static String getOverDueTaskQuery = "select * from task_table where status = 10";
	private static String lockTaskQuery = "update task_table set status = 1 where status = 10";
	
	public static TaskStatusResponse getOverDueOpenTasks() throws SQLException {

		TaskStatusResponse taskStatusResponse = new TaskStatusResponse();
		Connection conn = _dataSource.getConnection();
		try {
			log.debug("Got request for all overdue tasks ");
			System.out.println("Got request for all overdue tasks ");
			// first blocking all the exteral overdue tasks pending for more than 5 mins
			PreparedStatement pstmtQuery = conn
					.prepareStatement(blockOverDueTasks);
			pstmtQuery.setInt(1, 10); // put a temporary block by setting 10
			pstmtQuery.setLong(2, System.currentTimeMillis()
					- MAX_OVERDUE_INTERVAL_IN_MILSEC);
			pstmtQuery.executeUpdate(); 
			pstmtQuery.close();
			
			// now read the open jobs and submit
			pstmtQuery = conn
					.prepareStatement(getOverDueTaskQuery);

			ResultSet rs = pstmtQuery.executeQuery();
			while (rs.next()) {
				TaskStatus ts = new TaskStatus();
				ts.setImageUrl(rs.getString("image_url"));
				ts.setStatus(rs.getInt("status"));
				ts.setClientUniqueRequestId(rs
						.getString("client_unique_guid"));
				ts.setServerUniqueRequestId(rs.getString("server_unique_guid"));
				ts.setClientSubmitTimeStamp(rs.getLong("client_submit_time"));
				ts.setServerSubmissionTimeStamp(rs
						.getLong("server_submit_time"));
				ts.setRequestedResponseFormat(rs.getString("requestedResponseFormat"));
				taskStatusResponse.addTaskStatus(ts);
			}
			rs.close();
			pstmtQuery.close();
			
			// lock the tasks finally
			pstmtQuery = conn
					.prepareStatement(lockTaskQuery);
			pstmtQuery.executeUpdate(); 
			pstmtQuery.close();
			
		} finally {
			try {
				conn.close();
			} catch (Exception e) {
				log.error("Error closing connection", e);
			}
		}
		return taskStatusResponse;
	}

	

	/**
	 * Used to reopen the tasks which errored out when submitting the job to mturk
	 * @param serverUniqueIds
	 * @throws SQLException
	 */
	private static String reOpenTurkErroredOutTasks = "update task_table set status = 0, assigned_to = '' where server_unique_guid = ?";
	public static void reopenErroredOutTasks(ArrayList<String> serverUniqueIds) throws SQLException {

		Connection conn = _dataSource.getConnection();
		try {
			log.debug("Got request for reopening the erored out jobs");
			System.out.println("Got request for reopening the erored out jobs with ids " + serverUniqueIds.toString());
			PreparedStatement pstmtQuery = conn
					.prepareStatement(reOpenTurkErroredOutTasks);

			// used to batch the requests
			int count = 0;
			int batchSize = 20;
			
			// iterate over all errored out tasks
			for (Iterator<String> erroredTasks = serverUniqueIds.iterator(); erroredTasks.hasNext();) {
				String taskId = (String) erroredTasks.next();
				pstmtQuery.setString(1, taskId); 
				pstmtQuery.addBatch(); // add errored out task to batch
				
				// batch the requests in small manageable chunks 
				if (++count % batchSize == 0) {
					pstmtQuery.executeBatch();
					pstmtQuery.clearBatch(); //not sure if this is necessary
				  }
			}
			// do a final execute to clear out left over tasks
			pstmtQuery.executeBatch();
			pstmtQuery.close();
			
		} finally {
			try {
				conn.close();
			} catch (Exception e) {
				log.error("Error closing connection", e);
			}
		}
	}
	
	
	
	/**
	 * 
	 * Used by transcription website
	 * 
	 * @return
	 * @throws SQLException
	 */
	private static String allOpenTasksQuery = "select * from task_table where status = 0"; // states
																							// -
																							// open-0,
																							// locked-1,
																							// transcribed-2
																							// temporary lock when submitting to turk

	public static TaskStatusResponse getAllOpen() throws SQLException {

		TaskStatusResponse taskStatusResponse = new TaskStatusResponse();
		Connection conn = _dataSource.getConnection();
		try {
			log.debug("Got request for all open tasks ");
			PreparedStatement pstmtQuery = conn
					.prepareStatement(allOpenTasksQuery);

			ResultSet rs = pstmtQuery.executeQuery();
			while (rs.next()) {
				TaskStatus ts = new TaskStatus();
				ts.setImageUrl(rs.getString("image_url"));
				ts.setClientUniqueRequestId(rs.getString("client_unique_guid"));
				ts.setStatus(rs.getInt("status"));
				ts.setServerUniqueRequestId(rs.getString("server_unique_guid"));
				ts.setClientSubmitTimeStamp(rs.getLong("client_submit_time"));
				ts.setServerSubmissionTimeStamp(rs
						.getLong("server_submit_time"));
				ts.setRequestedResponseFormat(rs.getString("requestedResponseFormat"));
				taskStatusResponse.addTaskStatus(ts);
			}
			rs.close();
			pstmtQuery.close();
		} finally {
			try {
				conn.close();
			} catch (Exception e) {
				log.error("Error closing connection", e);
			}
		}
		return taskStatusResponse;
	}

	private static String storeUserTranscription = "update task_table set user_transcription = ? where server_unique_guid = ? ";
	private static String storeRatingAndComment = "update assignment_table set rating = ?, rating_comment = ? where idassignment= ? ";

	public static void rate(String ximlyDeviceId, String idassignment,
			String guid, String rating, String ratingComment,
			String userTranscriptionData) throws SQLException {

		Connection conn = _dataSource.getConnection();
		try {
			log.debug("Got request to store ratings ");

			if (userTranscriptionData != null
					&& !userTranscriptionData.trim().equals("")) {
				PreparedStatement pstmtQuery = conn
						.prepareStatement(storeUserTranscription);
				pstmtQuery.setString(1, userTranscriptionData);
				pstmtQuery.setString(2, guid);
				pstmtQuery.executeUpdate();
				pstmtQuery.close();
			}

			if (rating != null && !rating.trim().equals("")) {
				PreparedStatement pstmtQuery = conn
						.prepareStatement(storeRatingAndComment);
				pstmtQuery.setString(1, rating);
				pstmtQuery.setString(2, ratingComment);
				pstmtQuery.setString(3, idassignment);
				pstmtQuery.executeUpdate();
				pstmtQuery.close();
			}
		} finally {
			try {
				conn.close();
			} catch (Exception e) {
				log.error("Error closing connection", e);
			}
		}
	}

	
	private static String lockTaskByServerGuidQuery = "update task_table set status = 1, assigned_to = ? where server_unique_guid = ? ";
	
	public static void lockTaskByServerGuid(TaskStatusRequest tsr, String emailId) throws SQLException  {
		Connection conn = _dataSource.getConnection();
		try {
			log.debug("Got request to lock task by guid " + tsr.getTaskId());

				PreparedStatement pstmtQuery = conn
						.prepareStatement(lockTaskByServerGuidQuery);
				pstmtQuery.setString(1, emailId);
				pstmtQuery.setString(2, tsr.getTaskId());
				pstmtQuery.executeUpdate();
				pstmtQuery.close();
		} finally {
			try {
				conn.close();
			} catch (Exception e) {
				log.error("Error closing connection", e);
			}
		}
	}
	private static String notificationSMSQuery = "select sms from notification where sms is not null";
	public static ArrayList<String> getNotificationSmses() throws SQLException {
		ArrayList<String> smsIds = new ArrayList<String>();
		Connection conn = _dataSource.getConnection();
		try {
			log.debug("Got notification email list request");
			PreparedStatement pstmtQuery = conn
					.prepareStatement(notificationSMSQuery);
			ResultSet rs = pstmtQuery.executeQuery();
			while (rs.next()) {
				smsIds.add(rs.getString("sms"));
			}
			rs.close();
			pstmtQuery.close();
		} finally {
			try {
				conn.close();
			} catch (Exception e) {
				log.error("Error closing connection", e);
			}
		}
		return smsIds;
	}

	private static String listProductsQuery = "select * from Products_table where active != -1";

	public static ProductsResponse getProducts() throws SQLException {

		ProductsResponse products = new ProductsResponse();
		Connection conn = _dataSource.getConnection();
		try {
			log.debug("Got products list request");
			PreparedStatement pstmtQuery = conn
					.prepareStatement(listProductsQuery);
			ResultSet rs = pstmtQuery.executeQuery();
			while (rs.next()) {
				Product prd = new Product();
				prd.setProductId(rs.getString("idProducts"));
				prd.setAppleProductId(rs.getString("appleProductId"));
				prd.setPrice(rs.getBigDecimal("price"));
				prd.setImagesLeft(rs.getInt("imagesLeft"));
				products.addProduct(prd);
			}
			rs.close();
			pstmtQuery.close();
		} finally {
			try {
				conn.close();
			} catch (Exception e) {
				log.error("Error closing connection", e);
			}
		}
		return products;

	}

	/**
	 * 
	 * Add transcripts after a purchase
	 * @param deviceId
	 * @param productId
	 * @param transactionId
	 * @return object with status and freetasks
	 * @throws SQLException
	 */

	private static String receiptValidation = "select * from purchase_history_table where apple_transaction_id = ?";
	private static String receiptUpdate = "insert into purchase_history_table (deviceId, producs_table_idproducts, apple_transaction_id, purchase_time) values (?, (select idproducts from Products_table where appleproductid = ?), ?, ?)";
	private static String productPurchase = "update device_table set free_tasks_left = (free_tasks_left + (select imagesLeft from Products_table where appleProductId = ?)) where device_id = ?";

	public static PurchaseResponse purchase(String deviceId, String productId, String transactionId) throws SQLException {

		PurchaseResponse presp = new PurchaseResponse();
		presp.setTransaction_id(transactionId);
		presp.setProduct_id(productId);
		presp.setDeviceId(deviceId);
		presp.setStatus(-1);// initialize to error
		
		Connection conn = _dataSource.getConnection();
		try {
			// check if purchase was already made
			PreparedStatement pstmtQuery = conn.prepareStatement(receiptValidation);
			pstmtQuery.setString(1, transactionId);
			ResultSet rs = pstmtQuery.executeQuery();
			if (rs.next()) {
				// there is already a row for that transaction id, so it has already been used
				presp.setStatus(-2); 
			} 
			rs.close();
			pstmtQuery.close();
			
			// proceed only if transaction id is not already present
			if (presp.getStatus() != -2) {
				// if there no previous purchase then update the row			
				log.debug("purchase request for device id " + deviceId + " and product " + productId);
				pstmtQuery = conn
						.prepareStatement(productPurchase);
				pstmtQuery.setString(1, productId);
				pstmtQuery.setString(2, deviceId);
				pstmtQuery.executeUpdate();
				pstmtQuery.close();
				presp.setStatus(0); // successfully updated the purchase
				
				// insert the row for receipt after purchase
				pstmtQuery = conn
						.prepareStatement(receiptUpdate);
				pstmtQuery.setString(1, deviceId);
				pstmtQuery.setString(2, productId);
				pstmtQuery.setString(3, transactionId);
				pstmtQuery.setLong(4, System.currentTimeMillis());
				int rowsInserted = pstmtQuery.executeUpdate();
				pstmtQuery.close();
			} 
			presp.setImagesLeft(getFreeTasks(deviceId, conn));
			
		} finally {
			try {
				conn.close();
			} catch (Exception e) {
				log.error("Error closing connection", e);
			}
		}
		return presp;
	}

	private static int getFreeTasks(String deviceId, Connection conn) throws SQLException {
		PreparedStatement pstmtQuery;
		ResultSet rs;
		int freeImagesLeft = 0;
		// get the list of free tasks
		pstmtQuery = conn.prepareStatement(freeTaskQuery);
		pstmtQuery.setString(1, deviceId);
		rs = pstmtQuery.executeQuery();
		if (rs.next()) {
			freeImagesLeft  = rs.getInt(2);
		} 
		rs.close();
		pstmtQuery.close();
		return freeImagesLeft;
	}

	
	private static String notificationEmailQuery = "select email from notification where email is not null";

	public static ArrayList<String> getNotificationEmails() throws SQLException {

		ArrayList<String> emailIds = new ArrayList<String>();
		Connection conn = _dataSource.getConnection();
		try {
			log.debug("Got notification email list request");
			PreparedStatement pstmtQuery = conn
					.prepareStatement(notificationEmailQuery);
			ResultSet rs = pstmtQuery.executeQuery();
			while (rs.next()) {
				emailIds.add(rs.getString("email"));
			}
			rs.close();
			pstmtQuery.close();
		} finally {
			try {
				conn.close();
			} catch (Exception e) {
				log.error("Error closing connection", e);
			}
		}
		return emailIds;

	}

}
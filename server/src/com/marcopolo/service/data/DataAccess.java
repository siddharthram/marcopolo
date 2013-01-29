package com.marcopolo.service.data;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import javax.naming.Context;
import javax.naming.NamingException;
import javax.servlet.ServletException;
import javax.sql.DataSource;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.marcopolo.service.dto.PostRequest;
import com.marcopolo.service.dto.PostResponse;
import com.marcopolo.service.dto.TaskStatus;
import com.marcopolo.service.dto.TaskStatusRequest;
import com.marcopolo.service.dto.TaskStatusResponse;

public class DataAccess {
	private final static String AWS_DATASOURCE_NAME = "jdbc/marcopoloaws";
	private final static int MAX_FREE_TASKS = 5;
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
					log.error("Could not find datasource name " + AWS_DATASOURCE_NAME);
					throw new ServletException("'" + AWS_DATASOURCE_NAME + "' datasources can not be found");
				}
				// }
			} catch (NamingException e) {
				log.error("Error initlaizing datasource. The error was ", e);
				throw new ServletException(e);
			}
		}
	}

	private static String freeTaskQuery = "select iddevice, free_tasks_left from device_table where device_id = ?";
	private static String insertDeviceRow = "insert into device_table (device_id, free_tasks_left) values(?,?)";

	private static String insertTask = "insert into task_table (image_url, server_submit_time, device_table_iddevice, server_unique_guid, client_unique_guid, client_submit_time) values(?, ?, ?, ?, ?, ?)";
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
			if (freeTasksLeft > MAX_FREE_TASKS) {
				// set 'sorry quota exceeded' response
				presp.setResponseCode(-1);
				presp.setResponseText("Free quota exceeded");
				log.debug("Max free tasks " + freeTasksLeft + " exceeded for "
						+ preq.getDeviceId());
			} else {

				log.debug("Free tasks " + freeTasksLeft + " left for for "
						+ preq.getDeviceId());
				// private static String insertTask =
				// "insert into task_table (image_url, sumbit_time, device_table_iddevice, unique_guid) values(?, ?, ?, ?)";
				PreparedStatement pstmtInsert = conn
						.prepareStatement(insertTask);
				// image_url, server_sumbit_time, device_table_iddevice,
				// server_unique_guid, client_unique_guid, cleint_submit_time

				pstmtInsert.setString(1, presp.getImage_url());
				pstmtInsert.setLong(2, preq.getServerSubmissionTimeStamp());
				pstmtInsert.setInt(3, iddevice);
				pstmtInsert.setString(4, presp.getServerUniqueId());
				pstmtInsert.setString(5, preq.getClientRequestId());
				pstmtInsert.setLong(6, preq.getClientSubmitTimeStamp());
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

			presp.setFreeImagesLeft(freeTasksLeft);
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
				// check if task completed
				if (rs.getString("completion_time") != null
						&& !rs.getString("completion_time").equals("")) {
					ts.setStatus(2); // defualt is 0 which means submitted
					ts.setTranscriptionData(rs.getString("jobresult"));
				}
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

	private static String deleteExistingResponse = "delete from assignment_table where task_table_idtask in (select idtask from task_table where server_unique_guid = ?) ";
	private static String storeResponseQuery = "insert into assignment_table set jobresult = ?, cost = 0, completion_time = NOW(), task_table_idtask = (select idtask from task_table where server_unique_guid = ?) ";

	public static void submit(String guid, String response) throws SQLException {

		Connection conn = _dataSource.getConnection();
		try {
			log.debug("Got request to submit transcript for guid " + guid);
			PreparedStatement pstmtQuery = conn
					.prepareStatement(deleteExistingResponse);
			pstmtQuery.setString(1, guid);
			pstmtQuery.executeUpdate();
			pstmtQuery.close();
			pstmtQuery = conn.prepareStatement(storeResponseQuery);
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

	}

	private static String allOpenTasksQuery = "select * from task_table tt "
			+ "left join device_table dt on dt.iddevice = tt.device_table_iddevice "
			+ "left outer join assignment_table at on tt.idtask = at.task_table_idtask and at.completion_time is null ";

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
				ts.setImageUrl(rs.getString("tt.image_url"));
				ts.setClientUniqueRequestId(rs
						.getString("tt.client_unique_guid"));
				ts.setServerUniqueRequestId(rs.getString("server_unique_guid"));
				ts.setClientSubmitTimeStamp(rs.getLong("client_submit_time"));
				ts.setServerSubmissionTimeStamp(rs
						.getLong("server_submit_time"));
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

}

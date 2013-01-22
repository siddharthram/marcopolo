package com.marcopolo.service.data;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.UUID;

import javax.naming.Context;
import javax.naming.NamingException;
import javax.servlet.ServletException;
import javax.sql.DataSource;

import com.marcopolo.service.dto.PostRequest;
import com.marcopolo.service.dto.PostResponse;
import com.marcopolo.service.dto.TaskStatusRequest;
import com.marcopolo.service.dto.TaskStatusResponse;

public class DataAccess {
	private final static String DATASOURCE_NAME = "jdbc/mydb";
	private final static int MAX_FREE_TASKS = 5;
	private static DataSource _dataSource;

	public void setDataSource(DataSource dataSource) {
		_dataSource = dataSource;
	}

	public DataSource getDataSource() {
		return _dataSource;
	}

	public static void init(Context env) throws ServletException {
		if (_dataSource == null) {
			try {
				_dataSource = (DataSource) env.lookup(DATASOURCE_NAME);

				if (_dataSource == null)
					throw new ServletException("`" + DATASOURCE_NAME
							+ "' is an unknown DataSource");
			} catch (NamingException e) {
				throw new ServletException(e);
			}
		}
	}
	
	private static String freeTaskQuery = "select iddevice, free_tasks_left from device_table where device_id = ?";
	private static String insertDeviceRow = "insert into device_table (device_id, free_tasks_left) values(?,?)";
	private static String insertTask = "insert into task_table (image_url, sumbit_time, device_table_iddevice, unique_guid) values(?, ?, ?, ?)";
	private static String updateCount = "update device_table set free_tasks_left = (free_tasks_left-1) where device_id = ?";

	/**
	 * Gets the request and persists it in db
	 * @param preq
	 * @return
	 * @throws SQLException
	 */
	public static void storeRequestData(PostRequest preq, PostResponse presp) throws SQLException {
		int freeTasksLeft = MAX_FREE_TASKS; // default to max free
		int iddevice = 0; // our assigned id
		Connection conn = _dataSource.getConnection();
		// select free_tasks_left from user_table ut, device_table dt where ut.iduser = dt.user_table_iduser
		PreparedStatement pstmtQuery = conn.prepareStatement(freeTaskQuery);
		pstmtQuery.setString(1, preq.getDevice_id());
		ResultSet rs = pstmtQuery.executeQuery();
		if (rs.next()) {
			// get id of row and free tasks left
			iddevice = rs.getInt(1);
			freeTasksLeft = rs.getInt(2);
			pstmtQuery.close();
		} else {
			pstmtQuery.close();
			// insert device row
			PreparedStatement pstmtInsert = conn.prepareStatement(insertDeviceRow);
			pstmtInsert.setString(1, preq.getDevice_id());
			pstmtInsert.setInt(2, MAX_FREE_TASKS);
			pstmtInsert.executeUpdate();
			// get id of inserted row
			ResultSet rsInsert = pstmtInsert.getGeneratedKeys();
			iddevice = rs.getInt(1);
			rsInsert.close();
			pstmtInsert.close();
		}
		
		
		// check if task can be submitted
		if (freeTasksLeft > MAX_FREE_TASKS) {
			// set 'sorry quota exceeded' response
			presp.setResponseCode(-1);
			presp.setResponseText("Free quota exceeded");
		} else {
			//private static String insertTask = "insert into task_table (image_url, sumbit_time, device_table_iddevice, unique_guid) values(?, ?, ?, ?)";
			PreparedStatement pstmtInsert = conn.prepareStatement(insertTask);
			pstmtInsert.setString(1, presp.getImage_url());
			pstmtInsert.setDate(2, (Date) preq.getTimestamp());
			pstmtInsert.setInt(3, iddevice);
			pstmtInsert.setString(4, presp.getServerUniqueId());
			pstmtInsert.executeUpdate();
			pstmtInsert.close();
			// reduce the count
			pstmtInsert = conn.prepareStatement(updateCount);
			pstmtInsert.setString(1, preq.getDevice_id());
			pstmtInsert.executeUpdate();
			pstmtInsert.close();
			freeTasksLeft--;
			
			presp.setResponseCode(0);
			presp.setResponseText("Success");
		}
		
		presp.setFreeImagesLeft(freeTasksLeft);
		
	}
	
	public static TaskStatusResponse getStatus(TaskStatusRequest taskReq) {
		TaskStatusResponse taskStatusResp = new TaskStatusResponse();
		// make db query to get the response from assignment table
		// if taskid is present, then add where clause to query to get the 
		// response filtered by just that taskid
		
		return taskStatusResp;
	}

}

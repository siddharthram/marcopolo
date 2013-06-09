package com.marcopolo.mturk;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Iterator;

import com.amazonaws.mturk.requester.Assignment;
import com.amazonaws.mturk.service.axis.RequesterService;
import com.amazonaws.mturk.util.PropertiesClientConfig;
import com.marcopolo.service.data.DataAccess;
import com.marcopolo.service.dto.TaskStatus;
import com.marcopolo.service.dto.TaskStatusResponse;

/**
 * Submit external question to turk
 */
public class CheckTurkStatus {

	private static RequesterService service = null;;

	// Defining the location of the file containing the QAP and the properties
	// of the HIT
	private static String mturkProperties = "/mturk.properties";


	public static void init(String path) throws IOException {
		service = new RequesterService(new PropertiesClientConfig(path
				+ mturkProperties));
	}



	/**
	 * Creates the Best Image HIT
	 * 
	 * @param previewFile
	 *            The filename of the preview file to be generated. If null, no
	 *            preview file will be generated and the HIT will be created on
	 *            Mechanical Turk.
	 */
	public static String checkStatus() {
		String resp = "Something bad happened. Check logs";

		try {
			TaskStatusResponse taskStatusResponse  = DataAccess.getOpenTurkTasks();
			ArrayList<TaskStatus> turkSubmittedTasks = taskStatusResponse.getTaskStatuses();
			for (Iterator<TaskStatus> taskIter = turkSubmittedTasks.iterator(); taskIter
					.hasNext();) {
				TaskStatus taskStatus = (TaskStatus) taskIter.next();
				Assignment[] assignments = service.getAssignmentsForHIT(taskStatus.getTurkHitId(), 1);
				assignments[0].getAnswer();
				
			}
			
			
		} catch (Exception e) {
			resp = e.getLocalizedMessage();
		}
		return resp;
	}

}

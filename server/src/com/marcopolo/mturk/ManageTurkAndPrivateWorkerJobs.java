package com.marcopolo.mturk;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

import com.marcopolo.service.data.DataAccess;
import com.marcopolo.service.dto.TaskStatus;
import com.marcopolo.service.dto.TaskStatusResponse;

public class ManageTurkAndPrivateWorkerJobs implements Runnable {

	@Override
	public void run() {
		System.out.println("Executing the task from scheduler");
		submitAllTasksToTurk("0.15"); // default turk price for the task
		unlockPrivateWorkerTasks();
	}

	/**
	 * Submit the jobs to turk and returns output string
	 * @return
	 */
	public String submitAllTasksToTurk(String defaultTurkPrice) {
		StringBuilder output = new StringBuilder();
		try {
			TaskStatusResponse taskStatusResponse = DataAccess
					.getOverDueOpenTasks();
			ArrayList<TaskStatus> overdueTasks = taskStatusResponse
					.getTaskStatuses();
			ArrayList<String> submitErrorTasks = new ArrayList<String>();

			String resp = null;
			for (Iterator<TaskStatus> taskIter = overdueTasks.iterator(); taskIter
					.hasNext();) {
				TaskStatus taskStatus = (TaskStatus) taskIter.next();
				resp = ExternalQuestion.submitMturkJob(taskStatus, defaultTurkPrice);
				output.append(resp);
				if (null == resp || resp.startsWith("Error")) {
					submitErrorTasks.add(taskStatus.getServerUniqueRequestId());
					System.out.println("error in submitting job - " + taskStatus.getServerUniqueRequestId() + " with error " + resp);
				}
				output.append("\n================================================\n");
			}
			// reopen the errored out tasks if there are any
			if (submitErrorTasks.size() > 0 ) {
				DataAccess.reopenErroredOutTasks(submitErrorTasks);
			}
		} catch (Exception e) {
			System.err
					.println("Error in submiting job to turk. It will skip this run and remaining jobs.");
			//e.printStackTrace();
		}
		return output.toString();

	}

	/**
	 * Unlock private worker jobs
	 * @return
	 */
	
	public void unlockPrivateWorkerTasks() {
		try {
			DataAccess.unlockPendingOverDueTasks();
		} catch (Exception e) {
			System.err
					.println("Error in opening private worker tasks.");
			//e.printStackTrace();
		}

	}
	public static void main(String[] args) {
		Executors.newSingleThreadScheduledExecutor().scheduleAtFixedRate(
				new ManageTurkAndPrivateWorkerJobs(), 1, 1, TimeUnit.SECONDS);
	}

}
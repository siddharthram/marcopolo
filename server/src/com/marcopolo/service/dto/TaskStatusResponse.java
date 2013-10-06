package com.marcopolo.service.dto;

import java.util.ArrayList;

public class TaskStatusResponse {
	public ArrayList<TaskStatus> taskStatuses = new ArrayList<TaskStatus>();
	public int imagesLeft;
	
	public int getImagesLeft() {
		return imagesLeft;
	}
	public void setImagesLeft(int imagesLeft) {
		this.imagesLeft = imagesLeft;
	}

	public ArrayList<TaskStatus> getTaskStatuses() {
		return taskStatuses;
	}

	public void setTaskStatuses(ArrayList<TaskStatus> taskStatuses) {
		this.taskStatuses = taskStatuses;
	}

	public void addTaskStatus(TaskStatus taskstatus) {
		taskStatuses.add(taskstatus);
	}
}

package com.marcopolo.mturk;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.URLEncoder;
import java.util.Properties;

import com.amazonaws.mturk.addon.HITProperties;
import com.amazonaws.mturk.addon.HITQuestion;
import com.amazonaws.mturk.requester.HIT;
import com.amazonaws.mturk.service.axis.RequesterService;
import com.amazonaws.mturk.util.PropertiesClientConfig;
import com.marcopolo.service.dto.TaskStatus;

/**
 * Submit external question to turk
 */
public class ExternalQuestion {

	private static RequesterService service = null;;
	private static HITProperties hitProps = null;;

	// Defining the location of the file containing the QAP and the properties
	// of the HIT
	private static String hitPropertiesFile = "/hit.properties";
	private static String mturkProperties = "/mturk.properties";
	private static final double maxReward = 0.25d; // in cents

	// transcription server url
	private static String baseTranscriptionURL = "https://ximly.herokuapp.com/tasks/";

	public static void init(String path) throws IOException {
		service = new RequesterService(new PropertiesClientConfig(path
				+ mturkProperties));
		InputStream in = new FileInputStream(path + hitPropertiesFile);
		Properties propfile = new Properties();
		propfile.load(in);
		hitProps = new HITProperties(propfile);
	}

	/**
	 * Check to see if your account has sufficient funds
	 * 
	 * @return true if there are sufficient funds. False if not.
	 */
	public static boolean hasEnoughFund() {
		double balance = service.getAccountBalance();
		System.out.println("Got account balance: "
				+ RequesterService.formatCurrency(balance));
		return balance > 0;
	}

	/**
	 * Creates the Best Image HIT
	 * 
	 * @param previewFile
	 *            The filename of the preview file to be generated. If null, no
	 *            preview file will be generated and the HIT will be created on
	 *            Mechanical Turk.
	 */
	public static String submitMturkJob(TaskStatus taskStatus, String price) {
		String resp = "Error : Something bad happened. Check logs";

		try {
			// Loading the HIT properties file. HITProperties is a helper class
			// that contains the
			// properties of the HIT defined in the external file. This feature
			// allows you to define
			// the HIT attributes externally as a file and be able to modify it
			// without recompiling your code.
			// In this sample, the qualification is defined in the properties
			// file.

			double mturkPrice = 0d;
			try {
				if (price == null) {
					throw new NumberFormatException("price not specified ");
				}
				mturkPrice = Double.parseDouble(price);
				// do not go above max reward
				if (mturkPrice > maxReward) {
					throw new NumberFormatException("Max price exceeded");
				}
			} catch (NumberFormatException e) {
				System.out.println("Debug : " + e.getLocalizedMessage()
						+ " No mturk price '" + price
						+ "'. So setting to default value");
				mturkPrice = hitProps.getRewardAmount();
			}

			String externalQuestion = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><ExternalQuestion xmlns=\"http://mechanicalturk.amazonaws.com/AWSMechanicalTurkDataSchemas/2006-07-14/ExternalQuestion.xsd\">"
					+ "<ExternalURL>"
					+ baseTranscriptionURL
					+ taskStatus.getServerUniqueRequestId()
					+ "/preview?imageUrl="
					+ URLEncoder.encode(taskStatus.getImageUrl(), "UTF-8")
					+ "&amp;"
					+ "requestedResponseFormat=" 
					+ taskStatus.getRequestedResponseFormat()
					+ "</ExternalURL>"
					+ "<FrameHeight>600</FrameHeight>"
					+ "</ExternalQuestion>";

			HITQuestion question = new HITQuestion();
			question.setQuestion(externalQuestion);

			// Validate the question (QAP) against the XSD Schema before making
			// the call.
			// If there is an error in the question, ValidationException gets
			// thrown.
			// This method is extremely useful in debugging your QAP. Use it
			// often.
			// QAPValidator.validate(question.getQuestion());

			// Create a HIT using the properties and question files
			HIT hit = service.createHIT(
					null, // HITTypeId
					hitProps.getTitle(),
					hitProps.getDescription(),
					hitProps.getKeywords(), // keywords
					question.getQuestion(), mturkPrice,
					hitProps.getAssignmentDuration(),
					hitProps.getAutoApprovalDelay(), hitProps.getLifetime(),
					hitProps.getMaxAssignments(), hitProps.getAnnotation(), // requesterAnnotation
					hitProps.getQualificationRequirements(), null // responseGroup
					);

			resp = "Created HIT: " + hit.getHITId() + " with price "
					+ mturkPrice;
			resp += "\nYou may see your HIT with HITTypeId '"
					+ hit.getHITTypeId() + "' here: ";
			resp += "\n" + service.getWebsiteURL() + "/mturk/preview?groupId="
					+ hit.getHITTypeId();
			resp += "\n" + "question url submitted was " + externalQuestion;
		} catch (Exception e) {
			resp = "Error : " + e.getLocalizedMessage();
		}
		return resp;
	}

}

package com.marcopolo.mturk;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

import com.amazonaws.mturk.addon.HITProperties;
import com.amazonaws.mturk.addon.HITQuestion;
import com.amazonaws.mturk.requester.HIT;
import com.amazonaws.mturk.service.axis.RequesterService;
import com.amazonaws.mturk.util.PropertiesClientConfig;

/**
 * The Best Image sample application will create a HIT asking a worker to choose
 * the best image of three given a set of criteria.
 * 
 * mturk.properties must be found in the current file path.
 * 
 * The following concepts are covered: - Using the <FormattedContent>
 * functionality in QAP - File based QAP and HIT properties HIT loading -
 * Validating the correctness of QAP - Using a basic system qualification -
 * Previewing the HIT as HTML
 * 
 */
public class ExternalQuestion {

	private static RequesterService service = null;;
	private static HITProperties hitProps = null;;
	
	// Defining the location of the file containing the QAP and the properties
	// of the HIT
	private static String hitPropertiesFile = "/hit.properties";
	private static String mturkProperties = "/mturk.properties";

	// transcription server url
	private static String baseTranscriptionURL = "http://ximly.herokuapp.com?serverUniqueRequestId=";
	
	public static void init(String path) throws IOException {
		service = new RequesterService(new PropertiesClientConfig(path + mturkProperties));
		Properties propfile = new Properties();
		InputStream in = new FileInputStream(path + hitPropertiesFile);  
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
	public static String submitMturkJob(String serverGuid) {
		String resp = "Something bad happened. Check logs";
		try {
			// Loading the HIT properties file. HITProperties is a helper class
			// that contains the
			// properties of the HIT defined in the external file. This feature
			// allows you to define
			// the HIT attributes externally as a file and be able to modify it
			// without recompiling your code.
			// In this sample, the qualification is defined in the properties
			// file.
		
			String externalQuestion = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><ExternalQuestion xmlns=\"http://mechanicalturk.amazonaws.com/AWSMechanicalTurkDataSchemas/2006-07-14/ExternalQuestion.xsd\">"
					+ "<ExternalURL>" +
					baseTranscriptionURL + serverGuid + 
					"</ExternalURL>"
					+ "<FrameHeight>600</FrameHeight>" + "</ExternalQuestion>";

			HITQuestion question = new HITQuestion();
			question.setQuestion(externalQuestion);

			// Validate the question (QAP) against the XSD Schema before making
			// the call.
			// If there is an error in the question, ValidationException gets
			// thrown.
			// This method is extremely useful in debugging your QAP. Use it
			// often.
			//QAPValidator.validate(question.getQuestion());

			// Create a HIT using the properties and question files
			HIT hit = service.createHIT(
					null, // HITTypeId
					hitProps.getTitle(),
					hitProps.getDescription(),
					hitProps.getKeywords(), // keywords
					question.getQuestion(), hitProps.getRewardAmount(),
					hitProps.getAssignmentDuration(),
					hitProps.getAutoApprovalDelay(), hitProps.getLifetime(),
					hitProps.getMaxAssignments(), hitProps.getAnnotation(), // requesterAnnotation
					hitProps.getQualificationRequirements(), null // responseGroup
					);

			resp =  "Created HIT: " + hit.getHITId();
			resp += "\nYou may see your HIT with HITTypeId '"
					+ hit.getHITTypeId() + "' here: ";
			resp += "\n" +  service.getWebsiteURL()
					+ "/mturk/preview?groupId=" + hit.getHITTypeId();
		} catch (Exception e) {
			resp = e.getLocalizedMessage();
		}
		return resp;
	}

}

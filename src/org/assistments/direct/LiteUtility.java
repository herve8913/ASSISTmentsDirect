package org.assistments.direct;

import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;
import java.util.concurrent.atomic.AtomicLong;

import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.assistments.connector.controller.AssignmentController;
import org.assistments.connector.controller.SchoolController;
import org.assistments.connector.controller.StudentClassController;
import org.assistments.connector.controller.UserController;
import org.assistments.connector.domain.StudentClass;
import org.assistments.connector.domain.User;
import org.assistments.connector.utility.Constants;
import org.assistments.connector.utility.Response;
import org.assistments.dao.controller.ExternalAssignmentDAO;
import org.assistments.dao.controller.ExternalStudentClassDAO;
import org.assistments.dao.controller.ExternalUserDAO;
import org.assistments.dao.domain.ExternalAssignment;
import org.assistments.dao.domain.ExternalStudentClass;
import org.assistments.dao.domain.ExternalUser;

import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

public class LiteUtility {

	public static String Direct_SCHOOL_REF = "070c9b2f-0ebe-46f0-a22e-e7d3d8a16ced";
	public static String PARTNER_REF = "Direct-Ref";
	public static String PARTNER_ID = "6";
	public static final String PASSWORD = "12345";
	public static String MARK = "Micro ASSISTments";
	static final String m_prefix = "PS";
    static final String m_version = "A";
    public static final String TIMEZONE = "GMT-4";
    public static final String REGISTRATION_CODE = "LAOLI";
    public static final String STUDENT_REPORT_SUFFIX = "_student_report_url";
//    public static final String DIRECT_URL = "http://test1.assistments.org:8080/direct";
//    public static final String DIRECT_URL = "http://csta14-5.cs.wpi.edu/direct";
//    public static final String DIRECT_URL = "http://www.smarterassignments.org";
	public static final String DIRECT_URL = "http://hmd12-2.cs.wpi.edu:8080/direct";    
	public static final String LOGIN_FAILURE = DIRECT_URL + "/login_failure";
    public static final String ASSIGNMENT_LINK_PREFIX = DIRECT_URL + "/assignment";
    public static final String REPORT_LINK_PREFIX = DIRECT_URL + "/report";
    
    public static final String UPLOAD_DIRECTORY = "C:/Users/swang3/workspace/direct/WebContent/StudentListFiles";
    
    public static User populateStudentInfo(String firstName, String lastName, String userName) {
		User user = new User();
		user.setUserType(Constants.PROXY);
		user.setFirstName(firstName);
		user.setLastName(lastName);
		user.setUsername(userName);
		user.setTimeZone(LiteUtility.TIMEZONE);
		return user;
	}
    
    public static void sendHtmlEmail(String recipientEmail, String subject, String html) throws MessagingException {
    	Properties props = new Properties();
		props.put("mail.smtp.host", "smtp.gmail.com");
		props.put("mail.smtp.socketFactory.port", "465");
		props.put("mail.smtp.socketFactory.class",
				"javax.net.ssl.SSLSocketFactory");
		props.put("mail.smtp.auth", "true");
		props.put("mail.smtp.port", "465");

		Session session = Session.getDefaultInstance(props,
				new javax.mail.Authenticator() {
					protected PasswordAuthentication getPasswordAuthentication() {
						return new PasswordAuthentication(
								"the.assistment.teacher", "wpiassistment");
					}
				});


		Message message = new MimeMessage(session);
		message.setFrom(new InternetAddress(
				"the.assistment.teacher@gmail.com"));
		message.setRecipients(Message.RecipientType.TO,
				InternetAddress.parse(recipientEmail));
		message.setSubject(subject);
//		message.setText(text);
		message.setContent(html, "text/html; charset=utf-8");

		Transport.send(message);
    }
    
    public static void sendEmail(String recipientEmail, String subject, String text) throws MessagingException {
    	Properties props = new Properties();
		props.put("mail.smtp.host", "smtp.gmail.com");
		props.put("mail.smtp.socketFactory.port", "465");
		props.put("mail.smtp.socketFactory.class",
				"javax.net.ssl.SSLSocketFactory");
		props.put("mail.smtp.auth", "true");
		props.put("mail.smtp.port", "465");

		Session session = Session.getDefaultInstance(props,
				new javax.mail.Authenticator() {
					protected PasswordAuthentication getPasswordAuthentication() {
						return new PasswordAuthentication(
								"the.assistment.teacher", "wpiassistment");
					}
				});


		Message message = new MimeMessage(session);
		message.setFrom(new InternetAddress(
				"the.assistment.teacher@gmail.com"));
		message.setRecipients(Message.RecipientType.TO,
				InternetAddress.parse(recipientEmail));
		message.setSubject(subject);
		message.setText(text);

		Transport.send(message);
    }
    
	public static String generateStudentReportId(String studentRef, String assignmentRef) {
		return studentRef + "_" + assignmentRef + STUDENT_REPORT_SUFFIX;
	}
	
	public static String generateStudentReportURL(String studentRef, String assignmentRef) {
		return DIRECT_URL + "/studentReport?assignment_ref="+assignmentRef
				+"&student_ref="+studentRef;
	}
	
	public static List<String> transferUser (User user, String thirdPartyID, String password) throws TransferUserException {
		List<String> result = new ArrayList<String>();

		String userRef = new String();
		String accessToken = new String();

		ExternalUserDAO userDAO = new ExternalUserDAO(PARTNER_REF);

		if (!userDAO.isUserExist(thirdPartyID)) {
			// teacher account doesn't exist, then create a new account for this
			// teacher
			ExternalUser externalUser = new ExternalUser(PARTNER_REF);
			externalUser.setPartnerExternalReference(thirdPartyID);

			// create new User
			Response r = UserController.createUser(user, PARTNER_REF);
			if (r.getHttpCode() == 201) {
				JsonElement jElement = new JsonParser().parse(r.getContent());
				JsonObject jObject = jElement.getAsJsonObject();
				userRef = jObject.get("user").getAsString();
			} else {
				throw new TransferUserException(r.getContent());
			}

			externalUser.setAssistmentsExternalRefernce(userRef);

			accessToken = createAccessToken(userRef);

			externalUser.setAssistmentsAccessToken(accessToken);
			try {
				externalUser.setPartnerAccessToken(getHash(password));
			} catch (Exception e) {
				e.printStackTrace();
				throw new TransferUserException(e.getMessage());
			}
			String school_ref = LiteUtility.Direct_SCHOOL_REF;
			SchoolController.assignUserToSchool(userRef, school_ref,
					LiteUtility.PARTNER_REF, accessToken);
			// update db
			userDAO.addNewUser(externalUser);
		} else {
			ExternalUser externalUser = userDAO.findByPartnerExternalRef(thirdPartyID);
			
			if(externalUser.getPartnerAccessToken() == null || externalUser.getPartnerAccessToken() == "") {
				try {
					externalUser.setPartnerAccessToken(getHash(password));
				} catch (Exception e) {
					e.printStackTrace();
					throw new TransferUserException(e.getMessage());
				}
				userDAO.update(externalUser);
			}

			if (externalUser.getAssistmentsAccessToken() == null
					|| externalUser.getAssistmentsAccessToken() == "") {
				String tmp = createAccessToken(externalUser.getAssistmentsExternalRefernce());
				externalUser.setAssistmentsAccessToken(tmp);
//				externalUser.setNote("CreatedByConnector");
				userDAO.update(externalUser);
			}
			userRef = externalUser.getAssistmentsExternalRefernce();
			accessToken = externalUser.getAssistmentsAccessToken();
		}
		result.add(userRef);
		result.add(accessToken);
		return result;
	}

	public static List<String> transferUser(User user, String thirdPartyId) throws TransferUserException {
		List<String> result = new ArrayList<String>();

		String userRef = new String();
		String accessToken = new String();

		ExternalUserDAO userDAO = new ExternalUserDAO(PARTNER_REF);

		if (!userDAO.isUserExist(thirdPartyId)) {
			// teacher account doesn't exist, then create a new account for this
			// teacher
			ExternalUser externalUser = new ExternalUser(PARTNER_REF);
			externalUser.setPartnerExternalReference(thirdPartyId);

			// create new User
			Response r = UserController.createUser(user, PARTNER_REF);
			if (r.getHttpCode() == 201) {
				JsonElement jElement = new JsonParser().parse(r.getContent());
				JsonObject jObject = jElement.getAsJsonObject();
				userRef = jObject.get("user").getAsString();
			} else {
				throw new TransferUserException(r.getContent());
			}

			externalUser.setAssistmentsExternalRefernce(userRef);

			accessToken = createAccessToken(userRef);

			if (accessToken == null) {
				return null;
			}
			externalUser.setAssistmentsAccessToken(accessToken);
			String school_ref = LiteUtility.Direct_SCHOOL_REF;
			SchoolController.assignUserToSchool(userRef, school_ref,
					LiteUtility.PARTNER_REF, accessToken);
			// update db
			userDAO.addNewUser(externalUser);
		} else {
			ExternalUser externalUser = userDAO.findByPartnerExternalRef(thirdPartyId);

			if (externalUser.getAssistmentsAccessToken() == null
					|| externalUser.getAssistmentsAccessToken() == "") {
				String tmp = createAccessToken(externalUser	.getAssistmentsExternalRefernce());
				externalUser.setAssistmentsAccessToken(tmp);
				externalUser.setNote("CreatedByConnector");
				userDAO.update(externalUser);
			}
			userRef = externalUser.getAssistmentsExternalRefernce();
			accessToken = externalUser.getAssistmentsAccessToken();
		}
		result.add(userRef);
		result.add(accessToken);
		return result;
	}
	
	public static void directToErrorPage(String message, String instruction, HttpServletRequest req, HttpServletResponse resp) 
			throws ServletException, IOException {
		RequestDispatcher dispatcher = req.getRequestDispatcher("/error.jsp");
		req.setAttribute("error_message", message);
		req.setAttribute("instruction", instruction);
		dispatcher.forward(req, resp);
		return;
	}

	public static List<String> transferStudent(User student, String partnerExternalRef) throws TransferUserException {
		List<String> result = new ArrayList<String>();

		String userRef = new String();
		String accessToken = new String();

		ExternalUserDAO userDAO = new ExternalUserDAO(PARTNER_REF);
		if (!userDAO.isUserExist(partnerExternalRef)) {
			// teacher account doesn't exist, then create a new account for this
			// teacher
			ExternalUser externalUser = new ExternalUser(PARTNER_REF);
			externalUser.setPartnerExternalReference(partnerExternalRef);

			// create new User
			Response r = UserController.createUser(student, PARTNER_REF);
			if (r.getHttpCode() == 201) {
				JsonElement jElement = new JsonParser().parse(r.getContent());
				JsonObject jObject = jElement.getAsJsonObject();
				userRef = jObject.get("user").getAsString();
			} else {
				throw new TransferUserException(r.getContent());
			}

			externalUser.setAssistmentsExternalRefernce(userRef);
			accessToken = createAccessToken(userRef);
			externalUser.setAssistmentsAccessToken(accessToken);

			// update db
			userDAO.addNewUser(externalUser);
		} else {
			ExternalUser externalUser = userDAO
					.findByPartnerExternalRef(partnerExternalRef);

			if (externalUser.getAssistmentsAccessToken() == null
					|| externalUser.getAssistmentsAccessToken() == "") {
				String tmp = createAccessToken(externalUser.getAssistmentsExternalRefernce());
				externalUser.setAssistmentsAccessToken(tmp);
			}
			userRef = externalUser.getAssistmentsExternalRefernce();
			accessToken = externalUser.getAssistmentsAccessToken();
			userDAO.update(externalUser);
		}
		result.add(userRef);
		result.add(accessToken);
		return result;
	}
	
	public static String createClass(String studentClassName,
			String accessToken, String studentClassPartnerRef) {
		ExternalStudentClass studentClass = new ExternalStudentClass(PARTNER_REF);
		ExternalStudentClassDAO studentClassDAO = new ExternalStudentClassDAO(
				PARTNER_REF);
		String classRef;
		if (!studentClassDAO.isClassExist(studentClassPartnerRef)) {
			StudentClass assisTmentsClass = new StudentClass(studentClassName);
			Response r = StudentClassController.createStudentClass(
					assisTmentsClass, PARTNER_REF, accessToken);

			if (r.getHttpCode() == 201) {
				classRef = parseClassJson(r.getContent());
			} else {
				return null;
			}
			studentClass.setAssistmentsExternalRefernce(classRef);
			studentClass.setAssistmentsAccessToken(accessToken);
			studentClass.setPartnerExternalReference(studentClassPartnerRef);
//			studentClass.setUser_access_token(MARK);
			studentClassDAO.addNewClass(studentClass);
			return classRef;
		} else {
			studentClass = studentClassDAO
					.findByPartnerExternalRef(studentClassPartnerRef);
			return studentClass.getAssistmentsExternalRefernce();
		}
	}
	
	public static String createAssignment(String problemSetID, 
			String studentClassRef, String accessToken, String thirdPartyID) {
		ExternalAssignmentDAO assignmentDAO = new ExternalAssignmentDAO(
				PARTNER_REF);
		String partnerExternalRef = thirdPartyID;
		// if (!assignmentDAO.isAssignmentExist(partnerExternalRef)) {
		ExternalAssignment assignment = new ExternalAssignment(PARTNER_REF);
//		assignment.setExternal_refernce(partnerExternalRef);
//		assignment.setUser_connector_token(MARK);
		String assignmentRef = "";
		Response r = AssignmentController.createAssignment(problemSetID,
				studentClassRef, LiteUtility.PARTNER_REF, accessToken);
		if (r.getHttpCode() == 201) {
			assignmentRef = parseAssignmentJson(r.getContent());
			assignment.setAssistmentsExternalRefernce(assignmentRef);
			assignment.setAssistmentsAccessToken(accessToken);
			assignment.setPartnerExternalReference(partnerExternalRef);
			assignment.setNote(studentClassRef);
			assignmentDAO.addNewAssignment(assignment);
			return assignmentRef;
		} else {
			return null;
		}
	}

	public static String createAssignment(String problemSetID,
			String studentClassRef, String accessToken) {
		ExternalAssignmentDAO assignmentDAO = new ExternalAssignmentDAO(
				PARTNER_REF);
		String partnerExternalRef = studentClassRef;
		// if (!assignmentDAO.isAssignmentExist(partnerExternalRef)) {
		ExternalAssignment assignment = new ExternalAssignment(PARTNER_REF);
//		assignment.setUser_connector_token(MARK);
		String assignmentRef = "";
		Response r = AssignmentController.createAssignment(problemSetID,
				studentClassRef, PARTNER_REF, accessToken);
		if (r.getHttpCode() == 201) {
			assignmentRef = parseAssignmentJson(r.getContent());
			assignment.setAssistmentsExternalRefernce(assignmentRef);
			assignment.setAssistmentsAccessToken(accessToken);
			assignment.setPartnerExternalReference(partnerExternalRef);
			assignmentDAO.addNewAssignment(assignment);
			return assignmentRef;
		} else {
			return null;
		}
	}

	public static User populateStudentInfo(String firstName, String lastName) {
		User student = new User();

		student.setUserType(Constants.PROXY);
		student.setPassword(PASSWORD);
		student.setFirstName(firstName);
		student.setLastName(lastName);
		// user.setEmail(ltiUser.getEmail());
		Long time = uniqueCurrentTimeMS();
		String fakeEmail = time.toString();
		student.setEmail(fakeEmail);
		student.setUsername(fakeEmail);
		student.setDisplayName(firstName + " " + lastName);
		student.setTimeZone(TIMEZONE);
		student.setRegistrationCode(REGISTRATION_CODE);
		return student;
	}

	public static User populateTeacherInfo(String firstName, String lastName,
			String displayName) {
		User user = new User();
		user.setUserType(Constants.PRINCIPAL);
		user.setPassword(LiteUtility.PASSWORD);
		user.setFirstName(firstName);
		user.setLastName(lastName);
		user.setDisplayName(displayName);

		Long  time = uniqueCurrentTimeMS();
		String fakeEmail = time.toString() + "@als.com";
		user.setEmail(fakeEmail);
		user.setUsername(time.toString());
		user.setTimeZone(TIMEZONE);
		user.setRegistrationCode(REGISTRATION_CODE);
		return user;
	}
	
	/**
	 * Create access token inside ASSISTments for this user based on user external reference
	 * Before calling this function, make sure the user does not have access token
	 * @param userRef -- use external reference inside ASSISTments
	 * @return access  token inside ASSSISTments
	 */
	public static String createAccessToken(String userRef) throws TransferUserException {
		String accessToken= "";
//			ASSISTmentsRequest assistmentsRequest = new ASSISTmentsRequest();
//			assist_access_token = assistmentsRequest.createAccessToken(userRef);
		Response r = UserController.createAccessToken(userRef, LiteUtility.PARTNER_REF);
		if(r.getHttpCode() < 400) {
			JsonElement jElement = new JsonParser().parse(r.getContent());
			JsonObject jObject = jElement.getAsJsonObject();
			accessToken = jObject.get("access").getAsString();
		} else {
			throw new TransferUserException(r.getContent());
		}
		return accessToken;
	}
	
	public static String encodeProblemSetId(int psId) {
        if (psId == 0)
            return "";
        
        String code = "abcdefghjkmnpqrstuvwxyz23456789";
        String prefix = "PS";
        String version = "A";                
        int index = psId;
        StringBuffer encodeId = new StringBuffer();        
        if (version.equals("A")) {
            while (index > 0) {
                char c = code.charAt(index % code.length());
                index /= code.length();
                encodeId.append(c);
            }
        }
        return prefix + version + encodeId.reverse().toString().toUpperCase();
    }

	/**
	 * Convert encoded problem set string to problem set id
	 * @param psString -- encoded problem set string (PSxxxx)
	 * @return problem set number id (a String)
	 */
	public static String decodeProblemSetString(String psString) {
        if (psString.isEmpty()) {
            return null;
        }
        
        // decode prefix
        if (!psString.substring(0, m_prefix.length()).equalsIgnoreCase(m_prefix)) {
            return null;
        }
        
        // decode version
        if (!psString.substring(m_prefix.length(), m_prefix.length() + m_version.length()).equalsIgnoreCase(m_version)) {
            return null;
        }
        
        // decode problem id
        String code = "abcdefghjkmnpqrstuvwxyz23456789";
        int decodedId = 0;
        String psStringLowerCase = psString.toLowerCase();
        for (int i = m_prefix.length() + m_version.length(); i < psStringLowerCase.length(); i++) {
            char c = psStringLowerCase.charAt(i);
            int oldValue = decodedId;
            decodedId = decodedId * code.length() + code.indexOf(c);
            if (decodedId < oldValue) {
                throw new RuntimeException("Overflow decoded id");
            }
        }
        return new Integer(decodedId).toString();
    }

	private static String parseClassJson(String classRefJson) {
		JsonElement jEelement = new JsonParser().parse(classRefJson);
		JsonObject jObject = jEelement.getAsJsonObject();
		String classRef = jObject.get("class").toString(); // "d15daef3972c4a7528afd6f97e9f536a"
		classRef = classRef.substring(1, classRef.length() - 1);
		return classRef;

	}

	private static String parseAssignmentJson(String assingmentRef) {
		JsonElement jEelement = new JsonParser().parse(assingmentRef);
		JsonObject jObject = jEelement.getAsJsonObject();
		String assignmentRef = jObject.get("assignment").toString(); // "d15daef3972c4a7528afd6f97e9f536a"
		assignmentRef = assignmentRef.substring(1, assignmentRef.length() - 1);
		return assignmentRef;

	}
	private static final AtomicLong LAST_TIME_MS = new AtomicLong();
	public static long uniqueCurrentTimeMS() {
	    long now = System.currentTimeMillis();
	    while(true) {
	        long lastTime = LAST_TIME_MS.get();
	        if (lastTime >= now)
	            now = lastTime+1;
	        if (LAST_TIME_MS.compareAndSet(lastTime, now))
	            return now;
	    }
	}
	public static String getHash(String password)  {
		String generatedPassword = null;
        try {
            // Create MessageDigest instance for MD5
            MessageDigest md = MessageDigest.getInstance("MD5");
            //Add password bytes to digest
            md.update(password.getBytes());
            //Get the hash's bytes
            byte[] bytes = md.digest();
            //This bytes[] has bytes in decimal format;
            //Convert it to hexadecimal format
            StringBuilder sb = new StringBuilder();
            for(int i=0; i< bytes.length ;i++)
            {
                sb.append(Integer.toString((bytes[i] & 0xff) + 0x100, 16).substring(1));
            }
            //Get complete hashed password in hex format
            generatedPassword = sb.toString();
        }
        catch (NoSuchAlgorithmException e)
        {
            e.printStackTrace();
        }
        return generatedPassword;
	 }
	//the method used to generate the URL of customized image
	public static URL getCustomizedImgURL(){
		URL url = null;
		try {
			url = new URL("http://www.communityadvocate.com/wp-content/uploads/2012/02/wpi_logo.gif");
		} catch (MalformedURLException e) {
			// TODO Auto-generated catch block
			System.out.println("URL loading encounters error.");
			e.printStackTrace();
		}
		return url;
	}
}

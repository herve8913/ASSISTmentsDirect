package org.assistments.direct;

import java.io.IOException;
import java.net.URLEncoder;
import java.util.List;

import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.commons.codec.binary.Base32;
import org.assistments.connector.controller.AssignmentController;
import org.assistments.connector.controller.StudentClassController;
import org.assistments.connector.domain.User;
import org.assistments.connector.utility.Constants;
import org.assistments.connector.utility.Response;
import org.assistments.dao.controller.ExternalAssignmentDAO;
import org.assistments.dao.controller.ExternalShareLinkDAO;
import org.assistments.dao.controller.ExternalStudentClassDAO;
import org.assistments.dao.domain.ExternalAssignment;
import org.assistments.dao.domain.ExternalShareLink;
import org.assistments.dao.domain.ExternalStudentClass;

import com.google.api.client.http.HttpStatusCodes;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

@WebServlet({"/sign_in_with_facebook"})
public class SignInWithFacebook extends HttpServlet {
	private static final long serialVersionUID = -5014015865556824034L;
	
	public SignInWithFacebook() {
		super();
	}
	
	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		doPost(req, resp);
	}
	
	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException ,IOException {
		//first we should check where the request comes from
		String userId = req.getParameter("user_id");
//		String email = req.getParameter("email");
		String firstName = req.getParameter("first_name");
		String lastName = req.getParameter("last_name");
		
		String assignmentRef = req.getParameter("assignment_ref");
		ExternalAssignmentDAO assignmentDAO = new ExternalAssignmentDAO(LiteUtility.PARTNER_REF);
		ExternalAssignment assignment = assignmentDAO.findByExternalRef(assignmentRef);
		
		String userName = firstName + "_" + lastName;
		HttpSession reqSession = req.getSession();
		//if teacher signs in with google
		if(req.getParameter("teacher") != null) {
			String problemSet = (String)reqSession.getAttribute("problem_set");
			String shareLinkRef = (String)reqSession.getAttribute("share_link_ref");
			String problemSetName = (String)reqSession.getAttribute("problem_set_name");
			String problemSetStr = (String)reqSession.getAttribute("problem_set_str");
			
			String thirdPartyId = "facebook_" + userId;
			String studentClassPartnerRef = thirdPartyId;
			String displayName = firstName + " " + lastName;
			User teacher = LiteUtility.populateTeacherInfo(firstName, lastName, displayName);
			List<String> teacherRefAccessToken = null;
			try {
				
				teacherRefAccessToken = LiteUtility.transferUser(teacher, thirdPartyId);
			} catch(TransferUserException e) {
				String errorMessage = e.getMessage();
				String instruction = "The server seems to be unstable at this moment. Please take a break and try it again later.";
				LiteUtility.directToErrorPage(errorMessage, instruction, req, resp);
				return;
			}
			String teacherRef = teacherRefAccessToken.get(0);
			String teacherToken = teacherRefAccessToken.get(1);
			String studentClassName = "Class";
			// create a class for this teacher
			String studentClassRef = LiteUtility.createClass(studentClassName,
					teacherToken, studentClassPartnerRef);
			// create class assignment
			// String problemSetID = Utility.decodeProblemSetString(problemSet);
			assignmentRef = LiteUtility.createAssignment(problemSet,
					studentClassRef, teacherToken, thirdPartyId);
			Base32 base32 = new Base32();
			String reportRef = base32.encodeAsString(assignmentRef.getBytes());
			
			String teacherLink = LiteUtility.REPORT_LINK_PREFIX + "/" + reportRef;
			String studentLink = LiteUtility.ASSIGNMENT_LINK_PREFIX + "/" + assignmentRef;
			//store the association between share link and user
			ExternalShareLink shareLink = new ExternalShareLink(LiteUtility.PARTNER_REF);
			shareLink.setAssistmentsExternalRefernce(shareLinkRef);
			shareLink.setAssistmentsAccessToken(teacherToken);
			shareLink.setPartnerExternalReference(thirdPartyId);
			shareLink.setNote(assignmentRef);
			ExternalShareLinkDAO shareLinkDAO = new ExternalShareLinkDAO(LiteUtility.PARTNER_REF);
			shareLinkDAO.save(shareLink);
			
			reqSession.setAttribute("student_link", studentLink);
			reqSession.setAttribute("teacher_link", teacherLink);
//			reqSession.setAttribute("problem_set_name", problemSetName);
			reqSession.setAttribute("user", teacherRef);
			reqSession.setAttribute("email", thirdPartyId);
			reqSession.setAttribute("from", "facebook");
			reqSession.setAttribute("submit", "Sign in with Facebook");
			resp.getWriter().print(req.getContextPath() + "/teacher");
			
			return;
		}
		User student = LiteUtility.populateStudentInfo(firstName, lastName, userName);
		String partnerExternalRef = "facebook_student" + userId;
		List<String> studentRefAccessToken = null;
		try {
			studentRefAccessToken = LiteUtility.transferStudent(student, partnerExternalRef);
		} catch(TransferUserException e) {
			String errorMessage = e.getMessage();
			String instruction = "The server seems to be unstable at this moment. Please take a break and try it again later.";
			LiteUtility.directToErrorPage(errorMessage, instruction, req, resp);
			return;
		}
		String studentRef = studentRefAccessToken.get(0);
		String studentToken = studentRefAccessToken.get(1);
		String token = assignment.getAssistmentsAccessToken();
		ExternalStudentClassDAO classDAO = new ExternalStudentClassDAO(LiteUtility.PARTNER_REF);
		ExternalStudentClass esc = classDAO.findByAccessToken(token);
		String studentClassRef = esc.getAssistmentsExternalRefernce();
		//enroll student into the class
		StudentClassController.enrollStudent(studentClassRef, studentRef, LiteUtility.PARTNER_REF, studentToken);
		//save url to student report
		String studentReportURL = Constants.ASSISSTments_URL+"external_tutor/student_class/report?partner_id="+LiteUtility.PARTNER_ID
				+"&class_ref="+studentClassRef+"&assignment_ref="+assignmentRef;
		ServletContext context = getServletContext();
		String studentReportId = LiteUtility.generateStudentReportId(studentRef, assignmentRef);
		context.setAttribute(studentReportId, studentReportURL);
		String onExit = LiteUtility.generateStudentReportURL(studentRef, assignmentRef);
//		String onExit = "http://csta14-5.cs.wpi.edu:8080/connector/studentReport";
		//have to encode url twice
		onExit = URLEncoder.encode(onExit, "UTF-8");
		onExit = URLEncoder.encode(onExit, "UTF-8");
		Response res = AssignmentController.getAssignment(assignmentRef, LiteUtility.PARTNER_REF, studentToken, onExit);
		if(res.getHttpCode() == 200) {
			JsonElement jElement = new JsonParser().parse(res.getContent());
			JsonObject jObject = jElement.getAsJsonObject();
			String tutorURL = jObject.get("handler").getAsString();
//			String onFailure = "assistments.org";
			String loginURL = Constants.LOGIN_URL;
			String addressToGo = String.format("%1$s?partner=%2$s&access=%3$s&on_success=%4$s&on_failure=%5$s", 
					loginURL, LiteUtility.PARTNER_REF, studentToken, tutorURL, LiteUtility.LOGIN_FAILURE);
			resp.setStatus(HttpStatusCodes.STATUS_CODE_OK);
			resp.getWriter().print(addressToGo);
		} else {
			String errorMessage = res.getContent();
			String instruction = "The server seems to be unstable at this moment. Please take a break and try it again later.";
			LiteUtility.directToErrorPage(errorMessage, instruction, req, resp);
			return;
		}		
	}
	
}

package org.assistments.direct.teacher;

import java.io.IOException;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.commons.codec.binary.Base32;
import org.assistments.connector.utility.Constants;
import org.assistments.dao.controller.ExternalAssignmentDAO;
import org.assistments.dao.controller.ExternalStudentClassDAO;
import org.assistments.dao.controller.ExternalUserDAO;
import org.assistments.dao.domain.ExternalAssignment;
import org.assistments.dao.domain.ExternalStudentClass;
import org.assistments.dao.domain.ExternalUser;
import org.assistments.direct.LiteUtility;

@WebServlet({ "/report/*", "/Report/*" })
public class Report extends HttpServlet {

	private static final long serialVersionUID = 828888353846628643L;

	public Report() {
		super();
	}
	
	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {
		doGet(req, resp);
	}
	
	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {

		String pathInfo = req.getPathInfo();
		pathInfo = pathInfo.substring(1);
		String reportRef = pathInfo;
		
		if(reportRef == null) {
			String errorMessage = "It seems that the web page you just typed in doesn't exist.";
			String instruction = "If you entered the URL in by hand, double check that it is correct";
			RequestDispatcher dispatcher = req.getRequestDispatcher("/error.jsp");
			req.setAttribute("error_message", errorMessage);
			req.setAttribute("instruction", instruction);
			dispatcher.forward(req, resp);
		}
		
		Base32 base32 = new Base32();
		String assignmentRef = new String(base32.decode(reportRef));
		
		ExternalAssignmentDAO assignmentDAO = new ExternalAssignmentDAO(LiteUtility.PARTNER_REF);
		ExternalAssignment externalAssignment = assignmentDAO.findByExternalRef(assignmentRef);
		
		if(externalAssignment != null) {
			HttpSession session = req.getSession();
			session.setAttribute("report_ref", reportRef);
			String email = req.getParameter("email");
			//TODO: Change URL to test1 or production
//			String onSuccess = "http://csta14-5.cs.wpi.edu:3000/external_teacher/student_class/assignment?ref="+assignmentRef;
			String onSuccess = Constants.ASSISSTments_URL + "external_teacher/student_class/assignment?ref=" + assignmentRef;
			String onFailure = "assistments.org";
//			String loginURL = "http://csta14-5.cs.wpi.edu:3000/api2_helper/user_login";
			String loginURL = Constants.LOGIN_URL;
			/*
			if(session.getAttribute("user") == null && email == null) {
				req.getRequestDispatcher("/report_login.jsp").forward(req, resp);
				return;
			}*/
			String token = externalAssignment.getAssistmentsAccessToken();
			ExternalStudentClassDAO classDAO = new ExternalStudentClassDAO(LiteUtility.PARTNER_REF);
			ExternalStudentClass studentClass = classDAO.findByAccessToken(token);
			ExternalUserDAO userDAO = new ExternalUserDAO(LiteUtility.PARTNER_REF);
			ExternalUser user = userDAO.findByAccessToken(token);
			/*
			if(session.getAttribute("user") != null) {
				String userRef = (String)session.getAttribute("user");
				if(!userRef.equals(user.getExternal_refernce())) {
					req.setAttribute("assignment_ref", assignmentRef);
					req.getRequestDispatcher("/report_login.jsp").forward(req, resp);
					return;
				}
			} else if (email != null) {
				email = email.trim().toLowerCase();
				String password = req.getParameter("password");
				if(!user.getUser_connector_token().equals(LiteUtility.getHash(password))) {
					req.setAttribute("email", email);
					req.setAttribute("assignment_ref", assignmentRef);
					req.setAttribute("message", "Log in was unsuccessful.");
					req.getRequestDispatcher("/report_login.jsp").forward(req, resp);
					return;
				}
			} */
			session.setAttribute("user", user.getAssistmentsExternalRefernce());
			String addressToGo = String.format("%1$s?partner=%2$s&access=%3$s&on_success=%4$s&on_failure=%5$s", 
					loginURL, LiteUtility.PARTNER_REF, user.getAssistmentsAccessToken(), onSuccess, onFailure);
			resp.sendRedirect(resp.encodeRedirectURL(addressToGo));
		} else {
			String errorMessage = "It seems that the web page you just typed in doesn't exist.";
			String instruction = "If you entered the URL in by hand, double check that it is correct";
			RequestDispatcher dispatcher = req.getRequestDispatcher("/error.jsp");
			req.setAttribute("error_message", errorMessage);
			req.setAttribute("instruction", instruction);
			dispatcher.forward(req, resp);
		}
	}
}

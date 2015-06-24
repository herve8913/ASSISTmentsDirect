package org.assistments.direct;

import java.io.IOException;
import java.util.List;

import javax.mail.MessagingException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.codec.binary.Base32;
import org.assistments.connector.controller.ShareLinkController;
import org.assistments.connector.domain.User;
import org.assistments.dao.controller.ExternalShareLinkDAO;
import org.assistments.dao.domain.ExternalShareLink;

import com.google.api.client.http.HttpStatusCodes;

@WebServlet({"/create_share_link"})
public class CreateShareLink extends HttpServlet {
	private static final long serialVersionUID = 7480149288637584087L;

	public CreateShareLink() {
		super();
	}
	
	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {
		doPost(req, resp);
	}
	
	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {
		String emails = req.getParameter("emails");
		String message = req.getParameter("message");
		String problemSetId = req.getParameter("problem_set_id");
		String distributorId = req.getParameter("distributor_id");
		Long problemSetIdLong = Long.valueOf(problemSetId);
		Long distributorIdLong = Long.valueOf(distributorId);
		int typeId = 2;
		
		emails = emails.trim();
		String[] emailsArr = emails.split(";");
		
		for(int i = 0; i < emailsArr.length; i++) {
			String email = emailsArr[i].trim();
			
			String shareLinkRef = ShareLinkController.createShareLink(problemSetIdLong, distributorIdLong, 
					LiteUtility.PARTNER_REF, typeId, email);
			
			User teacherInfo = LiteUtility.populateTeacherInfo(
					"ASSISTmentsDirect", "Teacher", "Teacher");
			List<String> refAndToken = null;
			try {
					refAndToken = LiteUtility.transferUser(teacherInfo, email);
			} catch(TransferUserException e) {
				String instruction = "The server seems to be unstable at this moment. Please take a break and try it again later.";
				//return 
			}
			String userRef = refAndToken.get(0);
			String accessToken = refAndToken.get(1);
			
			String studentClassName = "Class";
			String studentClassPartnerRef = email;
			// create a class for this teacher
			String studentClassRef = LiteUtility.createClass(studentClassName,
					accessToken, studentClassPartnerRef);
			// create class assignment
			String assignmentRef = LiteUtility.createAssignment(problemSetId,
					studentClassRef, accessToken, email);
			Base32 base32 = new Base32();
			String reportRef = base32.encodeAsString(assignmentRef.getBytes());
			
			String teacherLink = LiteUtility.REPORT_LINK_PREFIX + "/" + reportRef;
			String studentLink = LiteUtility.ASSIGNMENT_LINK_PREFIX + "/" + assignmentRef;
			//store the association between share link and user
			ExternalShareLink shareLink = new ExternalShareLink(LiteUtility.PARTNER_REF);
			shareLink.setAssistmentsExternalRefernce(shareLinkRef);
			shareLink.setAssistmentsAccessToken(accessToken);
			shareLink.setPartnerExternalReference(email);
			shareLink.setNote(assignmentRef);
			ExternalShareLinkDAO shareLinkDAO = new ExternalShareLinkDAO(LiteUtility.PARTNER_REF);
			shareLinkDAO.save(shareLink);
			//<a href=""></a>
			String studentHyperLink = "<a href=\""+studentLink+"\" target=\"_blank\">"+studentLink+"</a>";
			String teacherHyperLink = "<a href=\""+teacherLink+"\" target=\"_blank\">"+teacherLink+"</a>";
			message = message.replace("<span class=\"replace\">Assignment Link shows up here.</span>", studentHyperLink);
			message = message.replace("<span class=\"replace\">Report Link shows up here.</span>", teacherHyperLink);
			String text = message;
			String subject = "[ASSISTments] An Assignment Has been Created for You";

			try {
				LiteUtility.sendHtmlEmail(email, subject, text);
			} catch (MessagingException e) {
				//we fail to send out emails
			} 
		}
		resp.setStatus(HttpStatusCodes.STATUS_CODE_OK);
		resp.getWriter().print("Success");
	}
}

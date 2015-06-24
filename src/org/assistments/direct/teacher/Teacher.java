package org.assistments.direct.teacher;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.commons.codec.binary.Base32;
import org.assistments.connector.controller.ShareLinkController;
import org.assistments.connector.controller.StudentClassController;
import org.assistments.connector.controller.UserController;
import org.assistments.connector.domain.ShareLink;
import org.assistments.connector.domain.User;
import org.assistments.connector.utility.Response;
import org.assistments.dao.controller.ExternalShareLinkDAO;
import org.assistments.dao.controller.ExternalStudentClassDAO;
import org.assistments.dao.controller.ExternalUserDAO;
import org.assistments.dao.domain.ExternalShareLink;
import org.assistments.dao.domain.ExternalStudentClass;
import org.assistments.dao.domain.ExternalUser;
import org.assistments.direct.LiteUtility;

import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

@WebServlet({ "/Teacher", "/teacher" })
public class Teacher extends HttpServlet {
	private static final long serialVersionUID = -8603316572284984324L;

	public Teacher() {
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
		HttpSession session = req.getSession();
		String email = new String();
		if(session.getAttribute("email") == null || session.getAttribute("user") == null) {
			req.getRequestDispatcher("/teacher_login.jsp").forward(req, resp);
			return;
		} else {
			email = session.getAttribute("email").toString();
		}
		ExternalShareLinkDAO shareLinkDAO = new ExternalShareLinkDAO(LiteUtility.PARTNER_REF);
		//get this teacher's assignments
		List<Map<String, String>> assignmentsInfo = new ArrayList<Map<String, String>>();
		List<ExternalShareLink> shareLinks = shareLinkDAO.getExternalShareLinksByUser(email);
		Base32 base32 = new Base32();
		Collections.sort(shareLinks, Collections.reverseOrder());
		if(shareLinks != null) {
			Iterator<ExternalShareLink> ite = shareLinks.iterator();
			while(ite.hasNext()) {
				ExternalShareLink externalLink = ite.next();
				ShareLink link = ShareLinkController.getShareLinkByRef(externalLink.getAssistmentsExternalRefernce(), LiteUtility.PARTNER_REF);
				Map<String, String> info = new HashMap<String, String>();
				String encodedID = LiteUtility.encodeProblemSetId(link.getProblemSet().getDecodedID());
				String tmpStudentLink = LiteUtility.ASSIGNMENT_LINK_PREFIX + "/" + externalLink.getNote();
				String tmpTeacherLink = LiteUtility.REPORT_LINK_PREFIX + "/" + base32.encodeAsString(externalLink.getNote().getBytes());
				info.put("problem_set_name", link.getProblemSet().getName());
				info.put("problem_set_id", encodedID);
				info.put("student_link", tmpStudentLink);
				info.put("teacher_link", tmpTeacherLink);
				String linkURL = LiteUtility.DIRECT_URL + "/share/" + externalLink.getAssistmentsExternalRefernce();
				info.put("share_link", linkURL);
				assignmentsInfo.add(info);
			}
			session.setAttribute("assignments", assignmentsInfo);
		}
		//get all students
		//Temporally put code here
		//get student class ref
		/*
		ExternalUserDAO userDAO = new ExternalUserDAO(LiteUtility.PARTNER_REF);
		ExternalUser teacher = userDAO.findByPartnerExternalRef(email);
		String onBehalf = teacher.getAssistmentsAccessToken();
		ExternalStudentClass studentClass = new ExternalStudentClassDAO(LiteUtility.PARTNER_REF).findByPartnerExternalRef(email);
		String studentClassRef = studentClass.getAssistmentsExternalRefernce();
		Response r = StudentClassController.getClassMembers(studentClassRef, LiteUtility.PARTNER_REF, onBehalf);
		List<String> studentRefs = new ArrayList<String>();
		if(r.getHttpCode() == 200) { // success
			//parse the response to get each student ref
			JsonElement jEelement = new JsonParser().parse(r.getContent());
			JsonObject jObject = jEelement.getAsJsonObject();
			JsonArray jsonStuRefArr = jObject.get("students").getAsJsonArray();
			Iterator<JsonElement> iter = jsonStuRefArr.iterator();
			while(iter.hasNext()) {
				JsonElement tmpElement = iter.next();
				studentRefs.add(tmpElement.getAsString());
			}			
		}
		//get student info
		Iterator<String> iter = studentRefs.iterator();
		List<User> studentInfo = new ArrayList<User>();
		while(iter.hasNext()) {
			String tmpRef = iter.next();
			Response res = UserController.getUserProfile(tmpRef, LiteUtility.PARTNER_REF, onBehalf);
			User tmpStudent = new User();
			if(res.getHttpCode() == 200) { //success
				JsonElement jEelement = new JsonParser().parse(res.getContent());
				JsonObject jObject = jEelement.getAsJsonObject();
				String userType = jObject.get("userType").getAsString();
				String firstName = jObject.get("firstName").getAsString();
				String lastName = jObject.get("lastName").getAsString();
				String displayName = jObject.get("displayName").getAsString();
				String userName = jObject.get("username").getAsString();
				String stuEmail = jObject.get("email").isJsonNull() ? "" :  jObject.get("email").getAsString();
				String timeZone = jObject.get("timezone").isJsonNull() ? "" : jObject.get("timeZone").getAsString();
				tmpStudent.setUserType(userType);
				tmpStudent.setFirstName(firstName);
				tmpStudent.setLastName(lastName);
				tmpStudent.setDisplayName(displayName);
				tmpStudent.setUsername(userName);
				tmpStudent.setEmail(stuEmail);
				tmpStudent.setTimeZone(timeZone);
				studentInfo.add(tmpStudent);
			}	
		}
		session.setAttribute("students", studentInfo);
		*/
		RequestDispatcher dispatcher = req.getRequestDispatcher("/teacher.jsp");
		
		dispatcher.forward(req, resp);
	}
}

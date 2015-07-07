package org.assistments.direct.teacher;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.assistments.connector.controller.StudentClassController;
import org.assistments.dao.controller.ExternalUserDAO;
import org.assistments.dao.domain.ExternalUser;
import org.assistments.direct.LiteUtility;

import com.google.gson.JsonObject;

/**
 * Servlet implementation class CreateNewSection
 */
@WebServlet({ "/CreateNewSection", "/create_new_section" })
public class CreateNewSection extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public CreateNewSection() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		doPost(request, response);
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		HttpSession session = request.getSession();
		String sectionName = request.getParameter("sectionName");
		List<Map<String,String>> allSections = (List<Map<String, String>>) session.getAttribute("all_sections");
		int studentClassId = Integer.parseInt(allSections.get(0).get("student_class_id"));
		String email = (String) session.getAttribute("email");
		ExternalUserDAO userDAO = new ExternalUserDAO(
				LiteUtility.PARTNER_REF);
		ExternalUser user = userDAO.findByPartnerExternalRef(email);
		String partnerAccessToken = user.getPartnerAccessToken();
		int studentClassSectionId = StudentClassController.addNewSection(studentClassId, sectionName, partnerAccessToken, email);
		JsonObject json = new JsonObject();
		PrintWriter out = response.getWriter();
		json.addProperty("sectionId", Integer.toString(studentClassSectionId));
		out.write(json.toString());
		
	}

}

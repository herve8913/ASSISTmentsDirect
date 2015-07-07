package org.assistments.direct.teacher;

import java.io.IOException;

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

/**
 * Servlet implementation class DeleteStudent
 */
@WebServlet({ "/DeleteStudent", "/delete_student" })
public class DeleteStudent extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public DeleteStudent() {
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
		int studentId = Integer.parseInt(request.getParameter("studentId"));
		int sectionId = Integer.parseInt(request.getParameter("sectionId"));
		
		String teacherRef = new String();
		HttpSession session = request.getSession();
		String teacherPartnerExternalRef = (String)session.getAttribute("email");
		ExternalUserDAO userDAO = new ExternalUserDAO(LiteUtility.PARTNER_REF);
		ExternalUser user = userDAO.findByPartnerExternalRef(teacherPartnerExternalRef);
		teacherRef = user.getAssistmentsExternalRefernce();
		String studentDisplayName = StudentClassController.getStudentDisplayName(studentId);
		String partnerExternalRef = studentDisplayName+"_"+teacherRef;
		StudentClassController.deleteStudent(studentId, sectionId, partnerExternalRef);
		
	}

}

package org.assistments.direct.student;

import java.io.IOException;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.assistments.direct.LiteUtility;


@WebServlet({ "/studentReport", "/StudentReport" })
public class StudentReport extends HttpServlet {
	private static final long serialVersionUID = -3765332785755296446L;
	
	public StudentReport() {
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
		ServletContext context = getServletContext();
		String studentRef = req.getParameter("student_ref");
		String assignmentRef = req.getParameter("assignment_ref");
		String studentReportId = LiteUtility.generateStudentReportId(studentRef, assignmentRef);
		if(context.getAttribute(studentReportId) != null) {
			String studentReportURL = context.getAttribute(studentReportId).toString();
			context.removeAttribute(studentReportId);
			resp.sendRedirect(studentReportURL);
		} else {
			RequestDispatcher dispatcher = req.getRequestDispatcher("/assignment_finished.jsp");
			dispatcher.forward(req, resp);
			return;
		}
		
	}
	
}

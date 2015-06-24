package org.assistments.direct;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.assistments.dao.controller.ExternalUserDAO;
import org.assistments.dao.domain.ExternalUser;

@WebServlet({ "/ResetPassword", "/reset_password" })
public class ResetPassword extends HttpServlet {
	private static final long serialVersionUID = 1L;

	public ResetPassword() {
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

		String submit = req.getParameter("submit");
		String email = req.getParameter("email");
		ExternalUserDAO userDAO = new ExternalUserDAO(
				LiteUtility.PARTNER_REF);
		if (submit == null) {
			if(session.getAttribute("user") != null) {
				String userRef = session.getAttribute("user").toString();
				ExternalUser user = userDAO.findByExternalRef(userRef);
				session.setAttribute("email", user.getPartnerExternalReference());
			}
			req.getRequestDispatcher("/reset_password.jsp").forward(req, resp);
		} else {
			String password = req.getParameter("current_password");
			String newPassword = req.getParameter("new_password");
			ExternalUser user = userDAO.findByPartnerExternalRef(email);
			session.setAttribute("email", email);
			if(user == null) {
				String error = "Email doesn't exist!";
				req.setAttribute("error", error);
				req.getRequestDispatcher("/reset_password.jsp").forward(req,
						resp);
				return;
			}
			if (user.getPartnerAccessToken().equals(
					LiteUtility.getHash(password))) {
				// reset the password
				user.setPartnerAccessToken(LiteUtility.getHash(newPassword));
				userDAO.update(user);
//				session.removeAttribute("email");
				String message = "Password reset successfully!";
				req.setAttribute("message", message);
				req.getRequestDispatcher("/reset_password.jsp").forward(req,
						resp);
			} else {
				String error = "Current password is incorrect!";
				req.setAttribute("error", error);
				req.getRequestDispatcher("/reset_password.jsp").forward(req,
						resp);
			}
		}

	}
}

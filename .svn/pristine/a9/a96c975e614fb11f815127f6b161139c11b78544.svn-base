package org.assistments.direct.teacher;

import java.io.IOException;
import java.security.GeneralSecurityException;
import java.util.Arrays;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.assistments.dao.controller.ExternalUserDAO;
import org.assistments.dao.domain.ExternalUser;
import org.assistments.direct.LiteUtility;

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken.Payload;
import com.google.api.client.http.HttpStatusCodes;
import com.google.api.client.http.HttpTransport;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.JsonFactory;
import com.google.api.client.json.jackson2.JacksonFactory;

@WebServlet({ "/TeacherLogin", "/teacher_login" })
public class TeacherLogin extends HttpServlet {
	
	static final String CLIENT_ID = "588893615069-3l8u6q8n9quf6ouaj1j9de1m4q24kb4k.apps.googleusercontent.com";

	private static final long serialVersionUID = 4524996561917493950L;

	public TeacherLogin() {
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
		if (req.getParameter("option") == null) {
			String submit = req.getParameter("submit");
			
			if (submit == null) {
				req.getRequestDispatcher("/teacher_login.jsp").forward(req,
						resp);
				return;
			}
			String email = req.getParameter("email").toLowerCase();
			String password = req.getParameter("password");
			HttpSession session = req.getSession();
			ExternalUserDAO userDAO = new ExternalUserDAO(
					LiteUtility.PARTNER_REF);
			ExternalUser user = userDAO.findByPartnerExternalRef(email);

			if (user == null) {	//Couldn't find the user
				String message = "Incorrect Email or Password!";
				req.setAttribute("email", email);
				req.setAttribute("message", message);
				req.getRequestDispatcher("/teacher_login.jsp").forward(req,
						resp);
			} else {
				if (user.getPartnerAccessToken().equals(
						LiteUtility.getHash(password))) {
					session.setAttribute("email", email);
					session.setAttribute("user", user.getAssistmentsExternalRefernce());
					session.setAttribute("from", "form");
					String host = req.getHeader("X-Forwarded-Server");
					String scheme = req.getScheme();
					if(host == null) {
						resp.sendRedirect("teacher");
					} else {
						resp.sendRedirect("teacher");
					}
					
				} else { // Wrong password
					String message = "Incorrect Email or Password!";
					req.setAttribute("email", email);
					req.setAttribute("message", message);
					req.getRequestDispatcher("/teacher_login.jsp").forward(req,
							resp);
					return;
				}

			}
		} else if("facebook".equals(req.getParameter("option").toString())) {
			String thirdPartyId = "facebook_" + req.getParameter("user_id");
			ExternalUserDAO userDAO = new ExternalUserDAO(LiteUtility.PARTNER_REF);
			
			if(userDAO.isUserExist(thirdPartyId)) {
				ExternalUser user = userDAO.findByPartnerExternalRef(thirdPartyId);
				HttpSession session = req.getSession();
				session.setAttribute("user", user.getAssistmentsExternalRefernce());
				session.setAttribute("email", thirdPartyId);
				session.setAttribute("from", "facebook");
				resp.getWriter().print(req.getContextPath() + "/teacher");
			} else {
				String message = "Sorry. We couldn't find any account associated with your Facebook account in our system!";
				resp.setStatus(203);
				resp.getWriter().print(message);
				return;
			}
		} else if("google".equals(req.getParameter("option").toString())) {
			String idTokenString = req.getParameter("idtoken");
			
			HttpTransport transport = new NetHttpTransport();
			JsonFactory jsonFactory = JacksonFactory.getDefaultInstance();
			GoogleIdTokenVerifier verifier = new GoogleIdTokenVerifier.Builder(transport, jsonFactory).
					setAudience(Arrays.asList(CLIENT_ID)).build();
			GoogleIdToken idToken = null;
			try {
				idToken = verifier.verify(idTokenString);
			} catch(GeneralSecurityException e) {
				e.printStackTrace();
			}
			if(idToken != null) {
				Payload payload = idToken.getPayload();
				String userId = payload.getSubject();
				
				String thirdPartyId = "google_" + userId;
				ExternalUserDAO userDAO = new ExternalUserDAO(LiteUtility.PARTNER_REF);
				req.getRequestURL();
				if(userDAO.isUserExist(thirdPartyId)) {
					ExternalUser user = userDAO.findByPartnerExternalRef(thirdPartyId);
					HttpSession session = req.getSession();
					session.setAttribute("user", user.getAssistmentsExternalRefernce());
					session.setAttribute("email", thirdPartyId);
					session.setAttribute("from", "google");
					resp.getWriter().print(req.getContextPath() + "/teacher");
					return;
				} else {
					String message = "Sorry. We couldn't find any account associated with your Google account in our system!";
					resp.getWriter().print(message);
					resp.setStatus(203);
					return;
				}
			}
		}
	}
}

package org.assistments.direct;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.assistments.dao.controller.ExternalUserDAO;
import org.assistments.dao.domain.ExternalUser;

import com.google.gson.JsonObject;

@WebServlet({ "/CheckPassword", "/check_password" })
public class CheckPassword extends HttpServlet {

	private static final long serialVersionUID = 4310974466946366147L;
	
	public CheckPassword() {
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
		String email = req.getParameter("email");
		String password = req.getParameter("password");
		PrintWriter pw = resp.getWriter();
		JsonObject json = new JsonObject();
		
		ExternalUserDAO userDAO = new ExternalUserDAO(LiteUtility.PARTNER_REF);
		if(userDAO.isUserExist(email)) {
			ExternalUser user = userDAO.findByPartnerExternalRef(email);
			if(LiteUtility.getHash(password).equals(user.getPartnerAccessToken())) {
				json.addProperty("result", "true");
			} else {
				json.addProperty("result", "wrong");
			}
		} else {
			json.addProperty("result", "wrong");
			
		}
		pw.write(json.toString());
		pw.flush();
		pw.close();
	}

}

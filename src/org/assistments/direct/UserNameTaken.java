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
import org.json.simple.JSONObject;

@WebServlet({ "/isUserNameTaken" })
public class UserNameTaken extends HttpServlet {

	private static final long serialVersionUID = 2631728906468613401L;
	
	public UserNameTaken() {
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
		ExternalUserDAO userDAO = new ExternalUserDAO(LiteUtility.PARTNER_REF);
		
		JSONObject json = new JSONObject();
		if(userDAO.isUserExist(email)) {
			ExternalUser user = userDAO.findByPartnerExternalRef(email);
			if(user.getPartnerAccessToken() != null && !user.getPartnerAccessToken().equals("")) {
				json.put("result", "true");
			} else {
				json.put("result", "false");
			}
		} else {
			json.put("result", "false");
		}
		PrintWriter pw = resp.getWriter();
		pw.write(json.toJSONString());
		pw.flush();
		pw.close(); 
	}

}

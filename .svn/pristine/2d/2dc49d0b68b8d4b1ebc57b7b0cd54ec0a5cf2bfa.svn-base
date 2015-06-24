package org.assistments.direct;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.assistments.connector.controller.ProblemSetController;
import org.assistments.connector.controller.ShareLinkController;
import org.assistments.connector.controller.UserController;
import org.assistments.connector.domain.ProblemSet;
import org.assistments.connector.domain.User;
import org.assistments.connector.exception.ReferenceNotFound;

@WebServlet({"/details_page"})
public class DetailsPage extends HttpServlet {
	private static final long serialVersionUID = 4419340825676094665L;

	public DetailsPage() {
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
		String problemSetId = req.getParameter("problem_set_id");
		String distributorId = req.getParameter("distributor_id");
		Long problemSetIdLong = Long.valueOf(problemSetId);
		Long distributorIdLong = Long.valueOf(distributorId);
		String genericLink = new String();
		
		User distributor = new User();
		ProblemSet ps = new ProblemSet();
		try {
				distributor = UserController.getDistributorInfo(Integer.valueOf(distributorId));
				ps = ProblemSetController.find(Integer.valueOf(problemSetId));
		} catch(ReferenceNotFound e) {
			
		} catch(NumberFormatException e) {
			
		}
		//create generic share link
		if(ShareLinkController.isGenericShareLinkExists(problemSetIdLong, distributorIdLong)) {
			String genericRef = ShareLinkController.getShareLinkRef(problemSetIdLong, distributorIdLong, 1, LiteUtility.PARTNER_REF);
			genericLink = LiteUtility.DIRECT_URL + "/share/" + genericRef;
		} else {
			String genericRef = ShareLinkController.createShareLink(problemSetIdLong, distributorIdLong, LiteUtility.PARTNER_REF, 1, "");
			genericLink = LiteUtility.DIRECT_URL + "/share/" + genericRef;
		}
		HttpSession session = req.getSession();
		session.setAttribute("generic_link", genericLink);
		session.setAttribute("problem_set_id", ps.getDecodedID());
		session.setAttribute("problem_set_name", ps.getName());
		session.setAttribute("distributor_name", distributor.getDisplayName());
		session.setAttribute("distributor_id", distributorId);
		req.getRequestDispatcher("details_page.jsp").forward(req, resp);
	}
}

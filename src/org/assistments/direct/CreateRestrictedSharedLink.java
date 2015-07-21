package org.assistments.direct;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.assistments.connector.controller.ProblemSetController;
import org.assistments.connector.controller.ShareLinkController;
import org.assistments.connector.controller.UserController;
import org.assistments.connector.domain.ProblemSet;
import org.assistments.connector.domain.User;
import org.assistments.connector.exception.ReferenceNotFound;

import com.google.gson.JsonObject;

/**
 * Servlet implementation class CreateRestrictedSharedLink
 */
@WebServlet("/CreateRestrictedSharedLink")
public class CreateRestrictedSharedLink extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public CreateRestrictedSharedLink() {
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
		String url = request.getParameter("url");
		String form = request.getParameter("form");
		String problemSetId = request.getParameter("problem_set_id");
		String distributorId = request.getParameter("distributor_id");
		Long problemSetIdLong = Long.valueOf(problemSetId);
		Long distributorIdLong = Long.valueOf(distributorId);
		String restrictedGenericLink = new String();
		
		User distributor = new User();
		ProblemSet ps = new ProblemSet();
		try {
				distributor = UserController.getDistributorInfo(Integer.valueOf(distributorId));
				ps = ProblemSetController.find(Integer.valueOf(problemSetId));
		} catch(ReferenceNotFound e) {
			
		} catch(NumberFormatException e) {
			
		}
		//create generic share link
		if(ShareLinkController.isRestrictedShareLinkExists(problemSetIdLong, distributorIdLong, url, form)) {
			String genericRef = ShareLinkController.getRestrictedShareLinkRef(problemSetIdLong, distributorIdLong, 1, LiteUtility.PARTNER_REF, url, form);
			restrictedGenericLink = LiteUtility.DIRECT_URL + "/share/" + genericRef;
		} else {
			String genericRef = ShareLinkController.createRestrictedShareLink(problemSetIdLong, distributorIdLong, LiteUtility.PARTNER_REF, "generic", url, form);
			restrictedGenericLink = LiteUtility.DIRECT_URL + "/share/" + genericRef;
		}
		PrintWriter out = response.getWriter();
		JsonObject json = new JsonObject();
		json.addProperty("generic_link", restrictedGenericLink);
		out.write(json.toString());
		out.flush();
		out.close();
	}

}

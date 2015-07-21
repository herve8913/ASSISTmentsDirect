package org.assistments.direct;

import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.List;

import net.oauth.parameters.OAuth2Parameters;

import com.google.gdata.client.spreadsheet.SpreadsheetService;
import com.google.gdata.data.spreadsheet.SpreadsheetEntry;
import com.google.gdata.data.spreadsheet.SpreadsheetFeed;
import com.google.gdata.util.AuthenticationException;
import com.google.gdata.util.ServiceException;

public class Testing {

	public static void main(String[] args) throws AuthenticationException,
			MalformedURLException, IOException, ServiceException {

		String clientId = "868469417184-ava3g9j9t1c5q4ntif5qgr36v0m2pis4.apps.googleusercontent.com";
		String clientSecret = "MZHG7lHHH36w3Fp4UXY70Xzt";
		String scope = "https://spreadsheets.google.com/feeds https://docs.google.com/feeds";

		OAuth2Parameters parameters = new OAuth2Parameters();
		parameters.setClientId(clientId);
		parameters.setClientSecret(clientSecret);
		parameters.setScope(scope);
		SpreadsheetService service = new SpreadsheetService("ASSISTmentsDirect");

		// TODO: Authorize the service object for a specific user (see other
		// sections)

		// Define the URL to request. This should never change.
		URL SPREADSHEET_FEED_URL = new URL(
				"https://spreadsheets.google.com/feeds/spreadsheets/private/full");

		// Make a request to the API and get all spreadsheets.
		SpreadsheetFeed feed = service.getFeed(SPREADSHEET_FEED_URL,
				SpreadsheetFeed.class);
		List<SpreadsheetEntry> spreadsheets = feed.getEntries();

		// Iterate through all of the spreadsheets returned
		for (SpreadsheetEntry spreadsheet : spreadsheets) {
			// Print the title of this spreadsheet to the screen
			System.out.println(spreadsheet.getTitle().getPlainText());
		}
	}

}

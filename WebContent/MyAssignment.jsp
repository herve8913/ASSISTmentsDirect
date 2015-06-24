<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<meta name="google-signin-client_id"
	content="588893615069-3l8u6q8n9quf6ouaj1j9de1m4q24kb4k.apps.googleusercontent.com">
<title>ASSISTments Direct</title>
<link rel="stylesheet"  href="../pure-release-0.6.0/pure-min.css">
<link rel="stylesheet"  href="../stylesheets/styles.css">
<link rel="stylesheet" href="../stylesheets/teacher.css">
<script src="https://apis.google.com/js/platform.js"  async defer>
</script>
<script type="text/javascript"	src="../js/jquery.min.js"></script>
<script type="text/javascript" 	src="../js/script.js"></script>
<script type="text/javascript">
	$(document).ready(function() {
		$("#google_login_indicator").css("visibility", "hidden");
		$("#facebook_login_indicator").css("visibility", "hidden");
		loadFacebook();
	});
	function onSignIn(googleUser) {
		var assignment_ref = $("#assignment_ref").val();
		var id_token = googleUser.getAuthResponse().id_token;
		signOut();
		$("#google_login_indicator").css("visibility", "visible");
		$.ajax({
			url: "../sign_in_with_google",
			type: "POST",
			data: {idtoken: id_token, assignment_ref: assignment_ref},
			success: function(data) {
				console.log(data);
				window.location.replace(data);
			},
			error: function(data) {
				console.log(data);
			}
		})
	}
	//Here we run a very simple test of the Graph API after login is
	// successful.  See statusChangeCallback() for when this call is made.
	function sign_in_with_facebook() {
		console.log('Welcome!  Fetching your information.... ');
		$("#facebook_login_indicator").css("visibility", "visible");
		FB.api('/me', function(response) {
			console.log(response);
			console.log('Successful login for: '
				+ response.name);
			//send user info to server to create an account
			var assignment_ref = $("#assignment_ref").val();
			$.ajax({
				url: "../sign_in_with_facebook",
				type: 'POST',
				data: {assignment_ref: assignment_ref, user_id: response.id, first_name: response.first_name, last_name: response.last_name},
				//dataType: "json",
				async: true,
				success: function(data) {
					console.log(data);
					window.location.replace(data);
				},
				error: function(data) {
					console.log(data);
				}
			});
		});
	}
	function fb_login() {
		FB.login(function(response) {
			if (response.authResponse) {
				sign_in_with_facebook();
			}

		}, {
			scope : 'public_profile,email'
		});
	}
	//sign out from google
	function signOut() {
	    var auth2 = gapi.auth2.getAuthInstance();
	    auth2.signOut().then(function () {
	      console.log('User signed out.');
	    });
	  }
</script>
</head>
<body>
	<div id="page-wrap">
		<div id="header" style="height: 60px;">	
		<div class="home-menu pure-menu pure-menu-horizontal pure-menu-fixed" style="height: 60px;">
			<img alt="ASSISTments" src="../images/direct_logo.gif" height="50px;" width="250px;" 
			style="position: absolute; top: 10px; left: 10%;">
		
		</div>
		</div>
		<form action="../beginAssignment"
			method="post" class="pure-form pure-form-aligned"
			style="margin: 30px 0 0 0;">
			<fieldset>
				<legend>Please input your first name and last name, then
					click 'Go to Assignment' to start the assignment.</legend>
				<input type="hidden" name="assignment_ref" id="assignment_ref"
					value=<%=request.getAttribute("assignment_ref").toString()%>>
				<br>
				<div style="margin: 0 auto; min-width: 350px; width: 50%;">
					<div class="pure-control-group">
						<label for="first_name">First Name</label> <input type="text"
							name="first_name" placeholder="First Name" required>
					</div>
					<div class="pure-control-group">
						<label for="last_name">Last Name</label> <input type="text"
							name="last_name" placeholder="Last Name" required>
					</div>
					<div class="pure-controls">
						<input type="submit" value="Go to Assignment"
							class="pure-button pure-button-primary">
					</div>
				</div>
			</fieldset>
		</form>
		<h3>---- or ----</h3>
		<!-- sign in with google -->
		<div style="width: 250px; margin: auto; display: inline-block;">
			<div id="my-signin2" class="g-signin2" data-onsuccess="onSignIn" data-theme="dark" 
				data-width="250" data-height="50" data-longtitle="true"></div>
		</div>
		<img style="display: inline-block; position: relative; bottom:10px;"	src="../images/indicator.gif" 
			id="google_login_indicator" height="25" width="25">
		<div style="margin-top: 20px;"></div>
		<div id="fb-root"></div>
		<!-- sign in with facebook -->
		<a href="javascript:void(0);" onclick="fb_login();" style="text-decoration: none;"> 
			<img src="../images/sign_in_with_facebook.png"
			width="260px" height="60px" border="0" alt="Sign in with Facebook">
		</a>
		<img 	style="display: inline; bottom:10px; position: relative;" src="../images/indicator.gif" 
			id="facebook_login_indicator" height="25" width="25">
			
	</div>
</body>
</html>
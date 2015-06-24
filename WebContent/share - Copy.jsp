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
<link rel="stylesheet"
	href="${pageContext.request.contextPath}/pure-release-0.6.0/pure-min.css">
<link rel="stylesheet"
	href="${pageContext.request.contextPath}/stylesheets/styles.css">
<script type="text/javascript"  src="https://apis.google.com/js/platform.js"  async defer></script>
<style type="text/css">
div.pure-control-group label.pure-u-1 {
	width: 250px;
}
</style>
<script type="text/javascript"
	src="${pageContext.request.contextPath}/jquery-2.1.3.js"></script>
<script type="text/javascript"
	src="${pageContext.request.contextPath}/jquery-ui.js"></script>
<script type="text/javascript" 	src="${pageContext.request.contextPath}/js/script.js"></script>
<script type="text/javascript">
	$(function() {
		var buttonPressed;
		$("#legend_content").hide();
		$("#password_div").hide();
		$("#confirm_password_div").hide();
		$("#google_login_indicator").css("visibility", "hidden");
		$("#facebook_login_indicator").css("visibility", "hidden");
		$("#message").hide();
		loadFacebook();
		$("#login_form").submit(function(event) {
			if(buttonPressed == "login") {
				event.preventDefault();
				var email = $("#login_form  #email").val();			
				$.ajax({
					url: '../isUserNameTaken',
					type: 'POST',
					data: {email: email},
					dataType: "json",
					async: true,
					success: function(data) {
						if(data.result == "true") {
							$("#submit").val("Login");
							$("#login").hide();
							$("#password_div").show();
							$("#password").prop('required', true);
						} else {
							$("#submit").val("Sign up");
							$("#login").hide();
							$("#password_div").show();
							$("#confirm_password_div").show();
							$("#password").prop('required', true);
							$("#confirm_password").prop('required', true);
						}
						
					},
					error: function(data) {
						$("#message").html("You just encountered an error. Please try it again.");
						$("#message").effect("highlight");
						event.preventDefault();
					}
				});
			} else {
				var buttonName = $("#submit").val();
				if(buttonName == "Get Links") {
					
				} else if(buttonName == "Sign up") {
					var email = $("#login_form  #email").val();	
					var password = $("#login_form  #password").val();	
					var confirm_password = $("#login_form  #confirm_password").val();
					if(password != confirm_password) {
						$("#message").html("Password and Confirm Password don't match!");
						$("#message").effect("highlight");
						$("#login_indicator").css("visibility", "hidden");
						event.preventDefault();
					} else {
						
					}
				} else if(buttonName = "Login"){
					//first check if password is correct!
					var email = $("#login_form  #email").val();	
					var password = $("#login_form  #password").val();	
					$.ajax({
						url: '../check_password',
						type: 'POST',
						data: {email: email, password: password},
						dataType: "json",
						async: false,
						success: function(data) {
							if(data.result == "true") {
								
							} else if(data.result == "wrong") {
								$("#message").show();
								$("#message").html("Wrong combination of email and password!");
								$("#message").effect("highlight");
								$("#login_indicator").css("visibility", "hidden");
								event.preventDefault();
							}
						},
						error: function(data) {
							$("#message").html("You just encountered an error. Please try it again.");
							$("#message").effect("highlight");
							$("#login_indicator").css("visibility", "hidden");
							event.preventDefault();
						}
					});
				}
			}
		});
		$("#login").click(function() {
			$("#message").hide();
			buttonPressed = "login";
		});
		$("#submit").click(function() {
			$("#message").hide();
			$("#login_indicator").css("visibility", "visible");
			buttonPressed = "submit";
		});
	});
	
	function toggleLegend() {
		$("#legend_content").toggle('blind', function() {
			if($(this).is(':visible')) {
				$("#legend_link").html('[-] Legend');
			} else {
				$("#legend_link").html('[+] Legend');
			}
		});
	}
	function onSignIn(googleUser) {
		var assignment_ref = $("#assignment_ref").val();
		var id_token = googleUser.getAuthResponse().id_token;
		$("#google_login_indicator").css("visibility", "visible");
		signOut();
		$.ajax({
			url: "../sign_in_with_google",
			type: "POST",
			data: {idtoken: id_token, assignment_ref: assignment_ref, teacher: true},
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
		$("#facebook_login_indicator").css("visibility", "visible");
		console.log('Welcome!  Fetching your information.... ');
		FB.api('/me', function(response) {
			console.log(response);
			console.log('Successful login for: '
				+ response.name);
			//send user info to server to create an account
			var assignment_ref = $("#assignment_ref").val();
			$.ajax({
				url: "../sign_in_with_facebook",
				type: 'POST',
				data: {assignment_ref: assignment_ref, user_id: response.id, first_name: response.first_name, last_name: response.last_name, teacher: true},
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
		<div id="header" style="height:10%;"> 
			<span style="float: left; padding: 10px 0 0 10px;">The problem set was shared by ${sessionScope.distributer_name }</span>
		</div>
		<div style="clear: both;"></div>
		<div id="legend" style="float: right; padding-right: 10%;">
			<a href="javacript:void(0);" onclick="toggleLegend()" id='legend_link'>[+] Legend</a>
		</div>
		<div style="clear: both;"></div>
		<div style="" id="legend_content">
			<div style="border: solid 1px; text-align: left; padding: 30px ; margin: 30px;">
			Assignment Link: This is a link that you will deliver to your students. When the student clicks on the link they will go to 
			a page where they enter their name and then start the assignment. When they are done they will get an overview of their work.  
 			<br><br>
			How you deliver the link to your students depends on what  methods you already have in place.  
			Some teachers email the links, other use learner management systems to deliver the links and others put the links up on their websites. 
			You can decide the best way that works for you. 
 			<br><br>
			Report Link: This is where the teacher can see the results of all the students who used the connected Tutor Link.  
			Any student who has ever used your links in the past will be on the report but there will only be data for those who used the link for this assignment.
			 If one student wrote their name differently they will show up twice, for example a student Joseph may use Joe one time nad Joseph another time, 
			 this student will show up twice. 
			 </div>
		</div>
		<div style="clear: both;"></div>
		<div style="width: 70%; margin: 0 auto; min-width: 550px;">
			<br><br><br>
			<h4>Get your Assignment Link and Report Link for:</h4>
			<h2>${sessionScope.problem_set_name }</h2>
						<br>
					<br><br>
			<form method="post" class="pure-form pure-form-aligned" id="login_form" 
				name="login_form" action="${pageContext.request.contextPath}/ShareSetup">
				<fieldset>
					<div class="pure-control-group"> 
						<label for="email" >Email</label><input type="email"  id="email" name="email" class="pure-input-1-2"
							placeholder="Email Address" required pattern="^\S+@(([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,6})$">
					</div>
					<div class="pure-control-group" id="password_div">
						<label for="password" >Password </label> <input type="password" id="password" name="password" class="pure-input-1-2"
							placeholder="Password">
					</div>
					<div class="pure-control-group" id="confirm_password_div">
						<label for="confirm_password" >Confirm Password </label> <input type="password"  id="confirm_password" name="confirm_password"
							class="pure-input-1-2" placeholder="Password">
					</div>
					
					<div style='margin:15px 5px 10px 5px; color:red' id="message"></div>
					
					<div class="pure-controls">
						<input type="submit" value="Get Links"
							class="pure-button" name="submit" id="submit" >
						<img 	src="${pageContext.request.contextPath}/images/indicator.gif"
						style="visibility: hidden;" id="login_indicator" height="25" width="25">
						<input type="submit" value="Login to Receive Links"
							class="pure-button" name="login" id="login" >
					</div>
				</fieldset>
			</form>
		</div>
			<h3>---- Or ----</h3>
			<!-- sign in with google -->
			<div style="width: 250px; margin: auto; display: inline-block;">
				<div id="my-signin2" class="g-signin2" data-onsuccess="onSignIn" data-theme="dark" 
				data-width="250" data-height="50" data-longtitle="true"></div>
			</div>
			<img style="display: inline-block; position: relative; bottom:10px;"	src="${pageContext.request.contextPath}/images/indicator.gif" id="google_login_indicator" height="25" width="25">
			<div style="margin-top: 20px;"></div>
			<div id="fb-root"></div>
			<!-- sign in with facebook -->
			<a href="javascript:void(0);" onclick="fb_login();" style="text-decoration: none;"> 
				<img src="${pageContext.request.contextPath}/images/sign_in_with_facebook.png"
					width="260px" height="60px" border="0" alt="Sign in with Facebook">
			</a>
			<img 	style="display: inline; bottom:10px; position: relative;" src="${pageContext.request.contextPath}/images/indicator.gif" id="facebook_login_indicator" height="25" width="25">
			<c:remove var="email" scope="session" />
			 <c:remove var="message" scope="session" />
		<div class="footer">
			<div style="float: left; padding-bottom: 30px;">Brought to you by</div>
		</div>
	</div> <!-- end of page-wrap -->
	
</body>
</html>
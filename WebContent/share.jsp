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
<link rel="stylesheet" href="../pure-release-0.6.0/pure-min.css">
<link rel="stylesheet" href="../stylesheets/styles.css">
<script type="text/javascript"  src="https://apis.google.com/js/platform.js"  async defer></script>
<style type="text/css">
div.pure-control-group label.pure-u-1 {
	width: 250px;
}
</style>
<script type="text/javascript"	src="../js/jquery.min.js"></script>

<script type="text/javascript"	src="../js/jquery-ui.min.js"></script>
<script type="text/javascript" 	src="../js/script.js"></script>
<script type="text/javascript">
	$(function() {
		var buttonPressed;
		var correctCode="";
		$("#get_links_form").hide();
		$("#login_area").hide();
		//$("#password").prop('disabled', true);
		$("#log_in").prop('disabled', true);
		$("#create_account").prop('disabled', true);
		$("#google_login_indicator").css("visibility", "hidden");
		$("#facebook_login_indicator").css("visibility", "hidden");
		$("#message").hide();
		$("#verify_panel").hide();
		loadFacebook();
		var permittedEmails = [];
		if($("#url").val()!=""){
			$("#submit").prop("disabled", true);
			var url = $("#url").val();
			//url= "https://spreadsheets.google.com/feeds/cells/1BYl_LEjzWaUCc4jb97e_RP374Eeqop9-rBl6r6-kOZg/od6/public/values?alt=json"; //modify later
			$.getJSON(url, function(data){
				var entry = data.feed.entry;
				$(entry).each(function(){
					permittedEmails.push(this.gs$cell.$t);
				});
				
			});
		}
		
		//offer two options
		$('input[name=optionsRadios]').on("click", function() {
			var option = $('input[name=optionsRadios]:checked').val();
			if( option == "option1") {
				$("#get_links_form").show();
				$("#login_area").hide();
			} else if(option == "option2") {
				$("#get_links_form").hide();
				$("#login_area").show();
			}
		});
		$("#login_area #email, #login_area #password").focus(function() {
			$("#message").hide();
		});
		$("#login_area #email").keyup(function() {
			var email = $("#login_form  #email").val();	
			if(email == null || email == ""  ) {
				return false;
			}
			var url = $("#url").val();
			if(url!=""){
				var flag = false;
				for(var i =0; i<permittedEmails.length;i++){
					if(permittedEmails[i] == email){
						flag=true;
						$.ajax({
							url: '../isUserNameTaken',
							type: 'POST',
							data: {email: email},
							dataType: "json",
							async: true,
							success: function(data) {
								if(data.result == "true") {
									$("#log_in").prop("disabled", false);
									$("#create_account").prop("disabled", true);
									$("#verify_panel").hide();
								} else {
									$("#log_in").prop("disabled", true);
									$("#create_account").prop("disabled", false);
								}
								
							},
							error: function(data) {
								$("#message").html("You just encountered an error. Please try it again.");
								$("#message").effect("highlight");
								event.preventDefault();
							}
						});
						break;
					}
				}
				if(!flag){
					$("#log_in").prop("disabled", true);
					$("#create_account").prop("disabled", true);
					return false;
				}
			} else if(url == ""){
				$.ajax({
					url: '../isUserNameTaken',
					type: 'POST',
					data: {email: email},
					dataType: "json",
					async: true,
					success: function(data) {
						if(data.result == "true") {
							$("#log_in").prop("disabled", false);
							$("#create_account").prop("disabled", true);
							$("#verify_panel").hide();
						} else {
							$("#log_in").prop("disabled", true);
							$("#create_account").prop("disabled", false);
						}
						
					},
					error: function(data) {
						$("#message").html("You just encountered an error. Please try it again.");
						$("#message").effect("highlight");
						event.preventDefault();
					}
				});
			}
		});
		$("#get_links_form #email").keyup(function(){
			var email = $("#get_links_form #email").val();
			if(email == null || email == ""  ) {
				return false;
			}
			if($("#url").val()==""){
				return false;
			} else{
				var flag = false;
				for(var i=0;i<permittedEmails.length;i++){
					if(permittedEmails[i] == email){
						$("#submit").prop("disabled", false);
						flag = true;
						break;
					}
				}
				if (!flag) {
					$("#submit").prop("disabled", true);
				}
			}
		});
		$("#login_form").submit(function(event) {
			if(buttonPressed == "Log in"){
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
							$("#login_indicator").css("visibility", "visible");
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
			} else if (buttonPressed == "Create Account") {
				$("#create_account_indicator").css("visibility", "hidden");
				//check email
				event.preventDefault();
				var email = $("#login_form  #email").val();	
				var action = "GetVerifyCode";
				$.ajax({
					url: '../check_email',
					type: 'POST',
					data:{email: email, action: action},
					dataType: "json",
					async: false,
					success: function(data){
						if(data.result == "true"){
							$("#verifyCode").val("");
							$("#verify_panel").slideDown();
							$("#create_account").prop("disabled", true);
							correctCode = data.correct_code;
						}else{
							$("#message").html("Please check your email. Make sure it's a valid email");
							$("#message").show();
							$("#message").effec("highlight");
						}
					},
					error: function(data){
						$("#message").html("You just encountered an error. Please try it again.");
						$("#message").effect("highlight");
						$("#login_indicator").css("visibility", "hidden");
					}
				});
			} else if(buttonPressed == "Verified"){
				var code = $("#verifyCode").val();
				var action = "VerifyingCode";
				$.ajax({
					url: '../check_email',
					type: 'POST',
					data: {code: code, action: action, correct_code: correctCode},
					dataType: "json",
					async: false,
					success: function(data){
						if(data.result == "true") {
							$("#login_indicator").css("visibility", "visible");
						} else if(data.result == "wrong") {
							$("#message").show();
							$("#message").html("The verify code is wrong.");
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
		});
		$("input[name=submit]").click(function() {
			$("#message").hide();
			//$("#login_indicator").css("visibility", "visible");
			buttonPressed = $(this).val();
		});
		$("#get_links_form").submit(function(e) {
			$("#get_links_indicator").css("visibility", "visible");
		});
	});
	function onSignIn(googleUser) {
		var assignment_ref = $("#assignment_ref").val();
		var id_token = googleUser.getAuthResponse().id_token;
		$("#google_login_indicator").css("visibility", "visible");
		console.log(id_token);
		$.ajax({
			url: "../sign_in_with_google",
			type: "POST",
			data: {idtoken: id_token, assignment_ref: assignment_ref, teacher: true},
			success: function(data) {
				signOut();
				console.log(data);
				window.location.replace(data);
			},
			error: function(data) {
				signOut();
				console.log(data);
			}
		});
	}
	//Here we run a very simple test of the Graph API after login is
	// successful.  See statusChangeCallback() for when this call is made.
	function sign_in_with_facebook() {
		$("#facebook_login_indicator").css("visibility", "visible");
		console.log('Welcome!  Fetching your information.... ');
		FB.api('/me', function(response) {
			console.log(response);
			console.log('Successful login for: '
				+ response);
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
		<div id="header" style="height:100px; background-color: #E1E6E6;"> 
			<img style="height:70px; display:block; margin:auto;" src="${sessionScope.customizedImgURL}"/>
			<span style="position: relative; top:5px;">The problem set was shared by ${sessionScope.distributer_name }</span>
		</div>
		<div style="width: 70%; margin: 40px auto 0 auto; min-width: 550px;">
			<h2>${sessionScope.problem_set_name }</h2>
			<hr>
			<h4>Get your Assignment and Report Links</h4>
			<!-- text-align: left -->
			<div style="text-align: left; margin-left: 25%;">
				<label for="option-two" class="pure-radio">
        			<input id="option-two" type="radio" name="optionsRadios" value="option1">
        			Email me my links
    			</label>
    			<div style="margin: 20px 0 0 0;"></div>
				<form method="post" class="pure-form" id="get_links_form" 
				name="login_form" action="../ShareSetup">
				<fieldset>
					<input type = "hidden" id="url" value="${sessionScope.url}">
					<input type = "hidden" id="form" value="${sessionScope.form}">
					<div class="pure-control-group"> 
						<label for="email" style="margin: 5px 20px 0 0;">Email</label><input type="email"  id="email" name="email" class="pure-input-2-3"
							placeholder="Email Address" required pattern="^\S+@(([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,6})$">				
						<input type="submit" value="Send"
							class="pure-button" name="submit" id="submit"  >
						<img 	src="../images/indicator.gif"
						style="visibility: hidden;" id="get_links_indicator" height="25" width="25" alt="" >	
					</div>	
				</fieldset>
				</form>
				<div style="margin: 20px 0 0 0;"></div>
    			<label for="option-three" class="pure-radio">
        			<input id="option-three" type="radio" name="optionsRadios" value="option2">
        			Login or create an account to get my links
    			</label>
			<div style="margin: 10px 0 0 0;"></div>
    		<i style="font-size: small;">Why make an account? <br>
    			Teachers with accounts will have their links organized at ASSISTmentsDirect.org
    		</i>
    		</div>
    		<!-- login or create account area -->
    		<div style="margin: 10px 0 0 0;" id="login_area" >
			<form method="post" class="pure-form pure-form-aligned" id="login_form" 
				name="login_form" action="../ShareSetup">
				<fieldset>
					<div class="pure-control-group"> 
						<label for="email" >Email</label><input type="email"  id="email" name="email" class="pure-input-1-2"
							placeholder="Email Address" required pattern="^\S+@(([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,6})$">
					</div>
					<div class="pure-control-group" id="password_div">
						<label for="password" >Password </label> <input type="password" id="password" name="password" class="pure-input-1-2"
							placeholder="Password" required>
					</div>	
								
					<div style='margin:15px 5px 10px 5px; color:red' id="message"></div>
					<div class="pure-controls">
						<input type="submit" value="Log in"
							class="pure-button" name="submit" id="log_in" >
						<img 	src="../images/indicator.gif"
						style="visibility: hidden;" id="login_indicator" height="25" width="25">
						<input type="submit" value="Create Account"
							class="pure-button" name="submit" id="create_account" >
						<img 	src="../images/indicator.gif"
						style="visibility: hidden;" id="create_account_indicator" height="25" width="25">
					</div>
					<div id="verify_panel" class="pure-control-group">
						<p>Please enter the verify code you received in your email.</p>
						<input type="password"  id="verifyCode" name="verifyCode" class="pure-input-1-3" placeholder="Verify Code" >
						<input type= "submit" value ="Verified" class = "pure-button" name="submit" id="verify_code">
					</div>	
				</fieldset>
			</form>
			<h5>---- or ----</h5>
			<!-- sign in with google -->
			<div style="width: 250px; margin: auto; display: inline-block;">
				<div id="my-signin2" class="g-signin2" data-onsuccess="onSignIn" data-theme="dark" 
				data-width="250" data-height="50" data-longtitle="true"></div>
			</div>
			<img style="display: inline-block; position: relative; bottom:10px;"	src="../images/indicator.gif" id="google_login_indicator" height="25" width="25">
			<div style="margin-top: 10px;"></div>
			<div id="fb-root"></div>
			<!-- sign in with facebook -->
			<a href="javascript:void(0);" onclick="fb_login();" style="text-decoration: none;"> 
				<img src="../images/sign_in_with_facebook.png"
					width="260px" height="60px" border="0" alt="Sign in with Facebook">
			</a>
			<img 	style="display: inline; bottom:10px; position: relative;" src="../images/indicator.gif" id="facebook_login_indicator" height="25" width="25">
			</div>
		</div>
			<c:remove var="email" scope="session" />
			 <c:remove var="message" scope="session" />
		<div style="position:absolute; left: 0px; bottom: 30px;">
			<span style="float:left; padding-left: 10px;">Powered by </span><br>
			<img alt="ASSISTments Direct" src="../images/direct_logo.gif" height="50px" width="250px">
		</div>
	</div> <!-- end of page-wrap -->
</body>
</html>
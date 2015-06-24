<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<meta name="google-signin-client_id" content="588893615069-3l8u6q8n9quf6ouaj1j9de1m4q24kb4k.apps.googleusercontent.com">
<title>Sign in with Google</title>
<script src="https://apis.google.com/js/platform.js?onload=renderButton" async defer></script>
<script type="text/javascript"
	src="${pageContext.request.contextPath}/jquery-2.1.3.js"></script>
<script type="text/javascript">
function renderButton() {
    gapi.signin2.render('my-signin2', {
    	'scope': 'https://www.googleapis.com/auth/plus.login',
    	'width': 250,
    	'height': 50,
    	'longtitle': true,
      	'theme': 'dark',
      	'onSuccess': onSignIn
    });
  }
function onSignIn(googleUser) {
	  var profile = googleUser.getBasicProfile();
	  console.log('ID: ' + profile.getId());
	  console.log('Name: ' + profile.getName());
	  console.log('Email: ' + profile.getEmail());
	  
	  var id_token = googleUser.getAuthResponse().id_token;
	  var xhr = new XMLHttpRequest();
	  xhr.open('POST', 'http://csta14-5.cs.wpi.edu:8080/direct/sign_in_with_google');
	  xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
	  xhr.onload = function() {
	    console.log('Signed in as: ' + xhr.responseText);
	  };
	  xhr.send('idtoken=' + id_token);
	}
function signOut() {
    var auth2 = gapi.auth2.getAuthInstance();
    auth2.signOut().then(function () {
      console.log('User signed out.');
    });
  }
</script>
</head>
<body>
	<div id="my-signin2"></div>
	<a href="#" onclick="signOut();">Sign out</a>
</body>
</html>
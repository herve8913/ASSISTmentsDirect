<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>ASSISTments Direct</title>
<link rel="stylesheet" 	href="pure-release-0.6.0/pure-min.css">
<link rel="stylesheet" 	href="stylesheets/styles.css">
<link rel="stylesheet" 	href="stylesheets/teacher.css">
<link rel="stylesheet" 	href="stylesheets/jquery-ui.css">
	<script type="text/javascript" 	src="js/jquery.min.js"></script>
<script type="text/javascript" 	src="js/jquery-ui.min.js"></script>
<style type="text/css">
	#accordion > h3 {
		margin-top: 10px;
  	}
  	.ui-state-active {
  		font-weight: bold;
  		background: #b4d8e7;
  		color: #000000;
  	}
	tbody.share_link tr td, tbody.direct_links tr td {
		border-top: 3px solid;
		border-bottom: 3px solid !important;
	}
	.datagrid table tbody:last-child tr td{ 
		border-bottom: none !important; 
	}
	.home-menu .pure-menu-selected a {
		color: white !important;
	}
	.sortable_section {
    border: 1px solid #eee;
    width: 242px;
    min-height: 20px;
    list-style-type: none;
    margin: 0;
    padding: 5px 0 0 0;
    margin-right: 10px;
  }
  .sortable_section li{
    margin: 0 5px 5px 5px;
    padding: 5px;
    font-size: 1.2em;
    width: 220px;
  }
</style>
<script>
  	$(function() {
  		var section_counter = 1; // need to modify it later.
  		
  		$( document ).tooltip();
  		var headers = $('#accordion .accordion-header');
  		$(".direct_links").hide();
  		$(".share_link").hide();
  		$( ".sortable_section" ).sortable({
  	      connectWith: ".connectedSortable"
  	    }).disableSelection();
  		
  		//$("#student_list").sortable();
		$.each(headers, function(index, value) {
			var panel = $(this).next();
  		    var isOpen = panel.is(':visible');
  		    if(isOpen) {
  		    	$(this).addClass("ui-state-active");
  		    	$(this).removeClass("ui-state-default");
  		    } else {
  		    	$(this).removeClass("ui-state-active");
  		    	$(this).addClass("ui-state-default");
  		    }
		});
  		// add the accordion functionality
  		headers.click(function() {
  		    var panel = $(this).next();
  		    var isOpen = panel.is(':visible');
  		    if(!isOpen) {
  		    	$(this).addClass("ui-state-active");
  		    	$(this).removeClass("ui-state-default");
  		    	$(".ui-accordion-header-icon", this).removeClass("ui-icon-plusthick");
  		    	$(".ui-accordion-header-icon", this).addClass("ui-icon-closethick");
  		    } else {
  		    	$(this).removeClass("ui-state-active");
  		    	$(this).addClass("ui-state-default");
  		    	$(".ui-accordion-header-icon", this).removeClass("ui-icon-closethick");
  		    	$(".ui-accordion-header-icon", this).addClass("ui-icon-plusthick");
  		    }
  		    // open or close as necessary
  		    panel[isOpen? 'slideUp': 'slideDown']()
  		        // trigger the correct custom event
  		        .trigger(isOpen? 'hide': 'show');

  		    // stop the link from causing a pagescroll
  		    return false;
  		});
  		
  		$("#add_new_section").button({
  			icons:{primary:"ui-icon-plusthick"}
  		});
  		
  		//show direct links
  		$(".direct_links_viewer").click(function() {
  			//$(".direct_links").hide("slow");
  			$(this).parent().parent().parent().next().next().toggle("slow");
  		});
  		$(".share_link_viewer").click(function() {
  			//$(".direct_links").hide("slow");
  			$(this).parent().parent().parent().next().toggle("slow");
  		});
  		
  		$("#upload_student_list").click(function(){
  			var student_list_file_name = $("#student_list_file").val();
  			if(student_list_file_name == ""){
  				alert("Please choose the file you want to upload."); // need to modify it later
  				return;
  			}
  			$("#upload_student_list").val("Importing..");
  			$("#import_student_list_indicator").css("visibility","visible");
  			var formData = new FormData($('#upload_form'));
  			formData.append("teacher_id","1"); //need to modify this data later
  			formData.append("student_list_file", $('input[type=file]')[0].files[0], student_list_file_name);
  			$.ajax({
  				url:'ImportStudentList',
  				type:'POST',
  				data:formData,
  				dataType: "json",
  				async:true,
  				processData: false,  // tell jQuery not to process the data
  	            contentType: false, 
  				success:function(data){
  					if (data.result=="true"){
  						$.ajax({
  			  				url:'UploadStudentList',
  			  				type: 'POST',
  			  				data: {student_list_file_name: student_list_file_name},
  			  				dataType:"json",
  			  				async: true,
  			  				success: function(data){
  			  					var res = "";
  			  					for (var i=0;i<data.length;i++){
  			  	  					res += "<li class='ui-state-default'>" + data[i].first_name+" "+ data[i].last_name + "</li>";
  			  					}
  			  					$("#student_list").append(res);
  			  					$("#import_student_list_indicator").css("visibility","hidden");
  			  					$("#upload_student_list").val("Import");
  			  				},
  			  				error: function(data){
  								alert("error occurred");
  			  				}
  			  			});
  					}else{
  						alert("something wrong")
  					}
  				},
  				error:function(data){
  					alert("error occurred during import");
  				}
  			});
  			
  		});
  		
  		$("#add_new_section").click(function(){
  			section_counter++;
  			var newSection = "";
  			newSection += "<h4>Student List for Section "+section_counter+":</h4>";
  			newSection += "<div><ul id='student_list_section"+section_counter+"' class='connectedSortable sortable_section'></ul></div><hr></hr>";
  			$("#student_list_zone").append(newSection);
  			$( ".sortable_section" ).sortable({
  	  	      connectWith: ".connectedSortable"
  	  	    }).disableSelection();
  		});
  	});
</script>
</head>
<body>

<div id="page-wrap">
	<div id="header" style="height: 60px;">	
		<div class="home-menu pure-menu pure-menu-horizontal pure-menu-fixed" >
			<img alt="ASSISTments" src="${pageContext.request.contextPath}/images/direct_logo.gif" height="50px;" width="250px;" 
				style="position: absolute; top: 10px; left: 10%;">
			<ul class="pure-menu-list" style="position: relative; left: -10%;">
        		<li class="pure-menu-item pure-menu-selected">
        			<a href="${pageContext.request.contextPath}/teacher" class="pure-menu-link">Home</a>
        		</li>
        		<c:choose>
        			<c:when test = "${ sessionScope.from eq 'form'}">
        			<li class="pure-menu-item pure-menu-has-children pure-menu-allow-hover">
            			<a href="javascript:void(0);" id="menuLink1" class="pure-menu-link">Hello, ${sessionScope.email}</a>
            			<ul class="pure-menu-children">
                		<li class="pure-menu-item"><a  href="${pageContext.request.contextPath}/ResetPassword" 
                			class="pure-menu-link" id="reset_password" >Reset Password</a></li>
                		<li class="pure-menu-item"><a  href="${pageContext.request.contextPath}/Logout" 
                			class="pure-menu-link" id="logout">Logout</a></li>
            			</ul>
        			</li>
        			</c:when>
        			<c:when test = "${ sessionScope.from eq 'google'}">
        			<li class="pure-menu-item">
            			<a  href="${pageContext.request.contextPath}/Logout" 
                			class="pure-menu-link" id="logout">Logout</a>
        			</li>
        			</c:when>
        			<c:when test = "${sessionScope.from eq 'facebook'}">
        			<li class="pure-menu-item">
            			<a  href="${pageContext.request.contextPath}/Logout" 
                			class="pure-menu-link" id="logout">Logout</a>
        			</li>
        			</c:when>
        		</c:choose>
    		</ul>
		</div>
    		
	</div>
	<div style="width: 90%; margin: 100px auto 0 auto; text-align: left; min-width: 550px;">

		<div id="accordion" class="ui-accordion ui-widget ui-helper-reset">
			<c:if test="${not empty sessionScope.student_link}">
			<h3 class="accordion-header ui-accordion-header ui-helper-reset ui-state-default ui-accordion-icons ui-corner-all">
				<span class="ui-accordion-header-icon ui-icon ui-icon-triangle-1-e"></span>
				Newly Created Assignment
			</h3>
				<div class="ui-accordion-content ui-helper-reset ui-widget-content ui-corner-bottom">
					<br><br>
					Assignment ${sessionScope.problem_set_name } has been created.
					<br><br><br>
					Give this link to your students. They will enter their name and do the assignment.<br>
   					<a href="${sessionScope.student_link }" target="_blank">${sessionScope.student_link }</a>
 					<br><br><br>
 					Use this link to see a report on how they did on the assignment: <br>
 					<a href="${sessionScope.teacher_link }" target="_blank">${sessionScope.teacher_link }</a>
 					<br><br>
				</div>
			</c:if>
				
			<h3 class="accordion-header ui-accordion-header ui-helper-reset ui-state-default ui-accordion-icons ui-corner-all">
				<span class="ui-accordion-header-icon ui-icon ui-icon-closethick"></span>
				Assignments
			</h3>
				<div id="assignments" class="ui-accordion-content ui-helper-reset ui-widget-content ui-corner-bottom">
					<div class="datagrid">
					<table width="100%">
						<thead>
						<tr>
							<th>Problem Set Name</th>
							<th>Share Link</th>
							<th>Direct Links</th>
						</tr>
						</thead>
					<c:forEach items="${sessionScope.assignments }" var="assignment" varStatus="loop">
					<tbody>
						<tr ${loop.index % 2 eq 0 ? "class='alt'" : "" }>
							<td><c:out value="${assignment.problem_set_name }"></c:out></td>
							<td><a href="javascript:void(0);" class="share_link_viewer">View</a></td>
							<td><a href="javascript:void(0);"  class="direct_links_viewer">View</a></td>
						</tr>
					</tbody>
					<tbody class="share_link">
						<tr height="100px;">
							<td colspan="3">
							<span style="height: 20px;">Share Link: 
								<a href="${assignment.share_link }" target="_blank">${assignment.share_link } </a></span><br><br>
							</td>
						</tr>
					</tbody>
					<tbody class="direct_links" >
						<tr height="150px;">
							<td colspan="3">
							<span style="height: 20px;">Teacher Report Link: 
								<a href="${assignment.teacher_link }" target="_blank">${assignment.teacher_link } </a></span><br><br>
							<span style="height: 20px;">Student Assignment Link: 
								<a href="${assignment.student_link }" target="_blank">${assignment.student_link }</a></span>
							</td>
						</tr>
					</tbody>
					</c:forEach>
					</table>
					</div>
				</div>
				<h3 class="accordion-header ui-accordion-header ui-helper-reset ui-state-default ui-accordion-icons ui-corner-all">
				<span class="ui-accordion-header-icon ui-icon ui-icon-closethick"></span>
					Roster
				</h3>
				<div id="roster" class="ui-accordion-content ui-helper-reset ui-widget-content ui-corner-bottom">
					<div id="student_list_zone">
						<h4>Student List:</h4>
						<form id="upload_form" enctype="multipart/form-data">
							<input id="student_list_file" type="file" name="student_list_file">
							<input id="upload_student_list" type="button" class="pure-button" value="Import">
							<img alt="" src="images/question_mark.png" style="position:relative;top:3px;" id="import_tooltip" height="15" width="15" title="Please upload the CSV file contains students' names">
							<img src="images/indicator.gif"
							 style="visibility:hidden;"id="import_student_list_indicator" height="25" width="25" alt="" >
						</form>
						<div>
							<ul id="student_list" class="connectedSortable sortable_section">
								<li class="ui-state-default">sample</li>
							</ul>
						</div>
						<hr></hr>
						<h4>Student List for Section 1:</h4>
						
						<div>
							<ul id="student_list_section1" class="connectedSortable sortable_section">
								<li class="ui-state-default">item1</li>
								<li class="ui-state-default">item2</li>
								<li class="ui-state-default">item3</li>
							</ul>
						</div>
						<hr></hr>
					</div>
					<button id="add_new_section">New Section</button>
				</div>
				<!-- end of assignment list -->
			<!-- 
			<h3 class="accordion-header ui-accordion-header ui-helper-reset ui-state-default ui-accordion-icons ui-corner-all">
				<span class="ui-accordion-header-icon ui-icon ui-icon-triangle-1-e"></span>
				My Students
			</h3>
			<div id="students" class="ui-accordion-content ui-helper-reset ui-widget-content ui-corner-bottom">
				<c:forEach items="${sessionScope.students }" var="student" varStatus="loop">
					<div><c:out value="${student.displayName }"></c:out></div>
				</c:forEach>
			</div>
			 -->
		</div>
	</div>
</div>
<c:remove var="problem_set_name" scope="session"/>
<c:remove var="student_link" scope="session"/>
<c:remove var="teacher_link" scope="session"/>
</body>
</html>
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
<script src="https://apis.google.com/js/platform.js" async defer></script>
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
  	.import-icon:hover{
  		border:2px solid #2c9ab7 !important
  	}
  	.import-icon{
  		width:25%;
  		text-align:center;
  		height:60px;
  		border: 2px solid #e0e0e0 !important;
  		margin-left:15px;
  		margin-right:15px;
  		margin-bottom:15px;
  		cursor: pointer;
  	}
  	#upload_student_list_with_google{
  		margin-top:9px;
  		height:65%;
  	}
  	#upload_student_list_with_file{
  		margin-top:10px;
  		height:65%;
  	}
  	#upload_student_list_with_excel{
  		margin-top:15px;
  		height:45%;
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
	/* modify pure button */
	.button-success,
        .button-error,
        .button-warning,
        .button-secondary {
            color: white;
            border-radius: 4px;
            text-shadow: 0 1px 1px rgba(0, 0, 0, 0.2);
        }

        .button-success {
            background: rgb(28, 184, 65); /* this is a green */
        }

        .button-error {
            background: rgb(202, 60, 60); /* this is a maroon */
        }

        .button-warning {
            background: rgb(223, 117, 20); /* this is an orange */
        }

        .button-secondary {
            background: rgb(66, 184, 221); /* this is a light blue */
        }
</style>
<script>
  	$(function() {
  		var section_counter = 1; // need to modify it later.
  		
  		$( document ).tooltip();
  		var headers = $('#accordion .accordion-header');
  		$(".direct_links").hide();
  		$(".share_link").hide();
  		
  		//$("#student_list").sortable();
		$.each(headers, function(index, value) {
			var panel = $(this).next();
  		    var isOpen = panel.is(':visible');
  		    if(isOpen) {
  		    	$(this).removeClass("ui-state-default");
  		    	$(this).addClass("ui-state-active");
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
  		    	$(this).removeClass("ui-state-default");
  		    	$(this).addClass("ui-state-active");
  		    	$(".ui-accordion-header-icon", this).removeClass("ui-icon-triangle-1-e");
  		    	$(".ui-accordion-header-icon", this).addClass("ui-icon-triangle-1-s");
  		    } else {
  		    	$(this).removeClass("ui-state-active");
  		    	$(this).addClass("ui-state-default");
  		    	$(".ui-accordion-header-icon", this).removeClass("ui-icon-triangle-1-s");
  		    	$(".ui-accordion-header-icon", this).addClass("ui-icon-triangle-1-e");
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
  			var firstSectionName = $("#group_name option:first-child").html();
  			var firstSectionId = $("#group_name option:first-child").val();
  			
  			var student_list_file_name = $("#student_list_file").val();
  			if(student_list_file_name == ""){
  				$( "#dialog-message" ).dialog( "open" );
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
  			  				data: {student_list_file_name: student_list_file_name, from:"file"},
  			  				dataType:"json",
  			  				async: true,
  			  				success: function(data){
  			  					var res = "";
  			  					var rs = "";
  			  					for (var i=0;i<data.length;i++){
  			  	  					res += "<tr><td>" + data[i].first_name+"</td><td>"+ data[i].last_name + "</td><td>"+firstSectionName+"</td>"+
  			  	  						"<td><input class='place_in_group_checkboxes' type ='checkbox'	name ='add_to_group' value='"+data[i].student_id+"'>"+
  			  	  						"<input type='hidden' value='"+firstSectionId+"'></td></tr>";
  			  	  					rs += "<tr id='"+data[i].student_id+"'><td>"+ data[i].first_name + "</td><td>"+data[i].last_name+"</td><td>"+
  			  	  						"<input type='button' class='pure-button button-error delete_btn' value='Delete'></td></tr>";
  			  					}
  			  					$("#all_student_table").append(res);
								$("#"+firstSectionId+"_table").append(rs);
					  	  		$(".delete_btn").off("click");
					  	  		$(".delete_btn").click(function(){
					  	  			var studentId = $(this).parent().parent().attr("id");
					  	  			var sectionId = $(this).parent().parent().parent().parent().parent().parent().attr("id");
					  	  			$(this).parent().parent().remove();
					  	  			$.ajax({
					  	  				url:'DeleteStudent',
					  	  				type:'POST',
					  	  				data:{studentId:studentId, sectionId:sectionId},
					  	  				dataType:"text",
					  	  				async:true,
					  	  				success: function(data){
					  	  		  			$("#all_student_table input[value='"+studentId+"']").parent().parent().remove();
					  	  				},
					  	  				error: function(data){
					  	  					alert("error happens");
					  	  				}
					  	  			});
					  	  		});
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
  			var sectionName = $("#new_section_name").val();
			//check if the name is empty
  			if(sectionName == ""){
  				sectionName = "Default Group";
  			}
			//check if the name already exists in the database
			var allSectionNames = [];
  			$("#group_name option").each(function(){
  				allSectionNames.push($(this).html());
  			});
  			for (var index=0;index<allSectionNames.length;index++){
  				if(allSectionNames[index]==sectionName) {
  					alert("Section Name already exists");
  					return false;
  				}
  			}
  			$.ajax({
  				url:'CreateNewSection',
  				type:'POST',
  				data:{sectionName: sectionName},
  				dataType:"json",
  				async: true,
  				success: function(data){
  					var sectionId = data.sectionId;
  		  			section_counter++;
  					var newSection = "";
  		  			newSection += "<br><h4 class='accordion-header ui-accordion-header ui-helper-reset ui-state-active ui-accordion-icons ui-corner-all new_section_header'>";
  		  			newSection += "<span class='ui-accordion-header-icon ui-icon ui-icon-triangle-1-s'></span>"+sectionName+"</h4>";
  		  			newSection += "<div id='"+sectionId+"' class='ui-accordion-content ui-helper-reset ui-widget-content ui-corner-bottom'><br/><div class='datagrid'><table width='100%' style='text-align:center;' class='pure-table-striped'>";
  		  			newSection += "<thead><tr><th>First Name</th><th>Last Name</th><th>Remove</th></tr></thead>";
  		  			newSection += "<tbody id='"+sectionId+"_table'></tbody></table></div></div>";
	  		  		$("#student_list_zone").append(newSection);
	  	  			//setup new accordian action
	  	  			$(".new_section_header").click(function() {
	  	  	  		    var panel = $(this).next();
	  	  	  		    var isOpen = panel.is(':visible');
	  	  	  		    if(!isOpen) {
	  	  	  		    	$(this).removeClass("ui-state-default");
	  	  	  		    	$(this).addClass("ui-state-active");
	  	  	  		    	$(".ui-accordion-header-icon", this).removeClass("ui-icon-triangle-1-e");
	  	  	  		    	$(".ui-accordion-header-icon", this).addClass("ui-icon-triangle-1-s");
	  	  	  		    } else {
	  	  	  		    	$(this).removeClass("ui-state-active");
	  	  	  		    	$(this).addClass("ui-state-default");
	  	  	  		    	$(".ui-accordion-header-icon", this).removeClass("ui-icon-triangle-1-s");
	  	  	  		    	$(".ui-accordion-header-icon", this).addClass("ui-icon-triangle-1-e");
	  	  	  		    }
	  	  	  		    // open or close as necessary
	  	  	  		    panel[isOpen? 'slideUp': 'slideDown']()
	  	  	  		        // trigger the correct custom event
	  	  	  		        .trigger(isOpen? 'hide': 'show');
	
	  	  	  		    // stop the link from causing a pagescroll
	  	  	  		    return false;
	  	  	  		});
	  	  			//this header is already setup, remove new header identifier
	  	  			$(".new_section_header").removeClass("new_section_header");
	  	  			var newGroupNames ="<option value='"+sectionId+"'>"+sectionName+"</option>";
	  	  			$("#group_name").append(newGroupNames);
  				},
  				error: function(data){
  					alert("error");
  				}
  			});
  		});
  		
  		//place in group 
  	  	$("#place_in_group_btn").click(function(){
  	  		var sectionId = $("#group_name").val();
  	  		var sectionName = $("#group_name option:selected").html();
  	  		var studentsPlacedInGroup = [];
  	  		var studentsPreviousSections = [];
  	  		$("#all_student_table input:checked").each(function(){
  	  			studentsPlacedInGroup.push($(this).attr("value"));
  	  			studentsPreviousSections.push($(this).next().val());
  	  			$(this).parent().prev().html(sectionName);
  	  		});
  	  		
  	  		for(var i=0;i<studentsPlacedInGroup.length;i++){
  	  			var newRow = $("#"+studentsPlacedInGroup[i]).html();
  	  			newRow = "<tr id='"+studentsPlacedInGroup[i]+"'>"+newRow+"</tr>";
  	  			$("#"+studentsPlacedInGroup[i]).remove();
  	  			$("#"+sectionId+"_table").append(newRow);
  	  		}
  	  		//add delete btn 
  	  		$(".delete_btn").off("click");
  	  		$(".delete_btn").click(function(){
  	  			var studentId = $(this).parent().parent().attr("id");
  	  			var sectionId = $(this).parent().parent().parent().parent().parent().parent().attr("id");
  	  			$(this).parent().parent().remove();
  	  			$.ajax({
  	  				url:'DeleteStudent',
  	  				type:'POST',
  	  				data:{studentId:studentId, sectionId:sectionId},
  	  				dataType:"text",
  	  				async:true,
  	  				success: function(data){
  	  		  			$("#all_student_table input[value='"+studentId+"']").parent().parent().remove();
  	  				},
  	  				error: function(data){
  	  					alert("error happens");
  	  				}
  	  			});
  	  		});
  	  		$.ajax({
  	  			url:'PlaceInGroup',
  	  			type:'POST',
  	  			data:{studentIds:JSON.stringify(studentsPlacedInGroup), oldStudentClassSectionIds:JSON.stringify(studentsPreviousSections), newStudentClassSectionId:sectionId},
  	  			dataType:"text",
  	  			async:true,
  	  			success: function(data){
  	  				//alert("done");
  	  			},
  	  			error: function(data){
  	  				alert("error");
  	  			}
  	  		});
  	  	});
  		
  		//delete btn
  		$(".delete_btn").click(function(){
  			var studentId = $(this).parent().parent().attr("id");
  			var sectionId = $(this).parent().parent().parent().parent().parent().parent().attr("id");
  			$(this).parent().parent().remove();
  			$.ajax({
  				url:'DeleteStudent',
  				type:'POST',
  				data:{studentId:studentId, sectionId:sectionId},
  				dataType:"text",
  				async:true,
  				success: function(data){
  		  			$("#all_student_table input[value='"+studentId+"']").parent().parent().remove();
  				},
  				error: function(data){
  					alert("error happen");
  				}
  			});
  		});
  		
  		$("#import_btn").click(function(){
  			$("#import-list-slider").slideToggle();
  		});
  		
  		$( ".dlg" ).dialog({
  			autoOpen: false,
  	     	modal: true,
  	     	width:500,
  	     	height:230,
  	     	show:{
  	     		effect:"scale",
  	     		duration:300
  	     	},
  	      	buttons: {
  	        OK: function() {
  	          $( this ).dialog( "close" );
  	        }
  	      }
  	    });
  		$(".import-icon").click(function(){
  			var importSrc = $(".import_src" ,this).val();
  			window.location.href = importSrc;
  		});
  		$("#import-list-slider").hide();
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
				<span class="ui-accordion-header-icon ui-icon ui-icon-triangle-1-s"></span>
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
				<span class="ui-accordion-header-icon ui-icon ui-icon-triangle-1-s"></span>
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
				<!-- end of assignment list -->
				<!-- My Students -->
				<h3 class="accordion-header ui-accordion-header ui-helper-reset ui-state-default ui-accordion-icons ui-corner-all">
				<span class="ui-accordion-header-icon ui-icon ui-icon-triangle-1-s"></span>
					My Students
				</h3>
				<div id="roster" class="ui-accordion-content ui-helper-reset ui-widget-content ui-corner-bottom">
					<div id="student_list_zone">
						<h4 class="accordion-header ui-accordion-header ui-helper-reset ui-state-default ui-accordion-icons ui-corner-all" >
							<span class="ui-accordion-header-icon ui-icon ui-icon-triangle-1-s"></span>
							All Students
						</h4>
						<div id="all_students" class="ui-accordion-content ui-helper-reset ui-widget-content ui-corner-bottom">
							<div style="height:30px;">
								<div class="pure-u-1-3">Place checked students in to selected group</div>
								<div class="pure-u-1-6">
									<select id="group_name" style="width:90%;">
										<c:forEach items="${sessionScope.all_sections }" var="each_section" varStatus="loop">
										<option value="${each_section.id }">${each_section.name }</option>
										</c:forEach>
									</select>
								</div>
								<div class="pure-u-1-6"><input id="place_in_group_btn" type="button" value="Place in Group"></div>
							</div>
							<p><button id="import_btn" class="pure-button button-secondary">Import Student List</button></p>
					<!------------ the form is hidden right now, this block will be modified later ------------>
							<form id="upload_form" enctype="multipart/form-data" style="display:none;">
								<input id="student_list_file" type="file" name="student_list_file">
								<input id="upload_student_list" type="button" class="pure-button button-secondary" value="Import">
								<img alt="" src="images/question_mark.png" style="position:relative;top:3px;" id="import_tooltip" height="15" width="15" title="Please upload the CSV file contains students' names">
								<img src="images/indicator.gif"
								 style="visibility:hidden;"id="import_student_list_indicator" height="25" width="25" alt="" >
							</form>
					<!------------                        end form                                 ------------>
							<br/>
					<!---------------- the following block is a list of methods to import students list ------------------>
							<div id="import-list-slider" class="pure-g" style="text-align:left;">
								<div class="import-icon pure-u-1-3">
									<img id="upload_student_list_with_google" src="images/GoogleDrive.PNG"  />
									<input class="import_src" type="hidden" value="${pageContext.request.contextPath}/import_student_list.jsp">
								</div>
								<div class="import-icon pure-u-1-3">
									<img id="upload_student_list_with_file" src="images/FileImport.PNG"  />
									<input class="import_src" type="hidden" value="${pageContext.request.contextPath}/import_student_list_from_local_file.jsp">
								</div>
								<div class="import-icon pure-u-1-3">
									<img id="upload_student_list_with_excel" src="images/excel_import.PNG"  />
									<input class="import_src" type="hidden" value="${pageContext.request.contextPath}/import_student_list_from_excel.jsp">
								</div>
							</div>
					<!---------------------------------------- importing list block end ----------------------------------->		
							<div class="datagrid">
							<table width="100%" style="text-align:center;" class="pure-table-striped">
								<thead>
								<tr>
									<th>First Name</th>
									<th>Last Name</th>
									<th>Group</th>
									<th>Add to group</th>
								</tr>
								</thead>
								<tbody id="all_student_table">
									<c:forEach items="${sessionScope.all_students }" var="each_student" varStatus="loop">
									<tr>
										<td>${each_student.first_name }</td>
										<td>${each_student.last_name }</td>
										<td>${each_student.section_name }</td>
										<td><input class="place_in_group_checkboxes" type ="checkbox"	name ="add_to_group" value="${each_student.student_id }">
										<input type="hidden" value="${each_student.section_id }"></td>
									</tr>
									</c:forEach>
								</tbody>
							</table>
							</div>
						</div>
						<c:forEach items="${sessionScope.all_sections }" var="each_section" varStatus="loop">
						<br>
						<h4 class="accordion-header ui-accordion-header ui-helper-reset ui-state-default ui-accordion-icons ui-corner-all" >
							<span class="ui-accordion-header-icon ui-icon ui-icon-triangle-1-s"></span>
							${each_section.name }
						</h4>
						<div id = "${each_section.id }" class="ui-accordion-content ui-helper-reset ui-widget-content ui-corner-bottom">
							
							<br/>
							<div class="datagrid">
							<table width="100%" style="text-align:center;" class="pure-table-striped">
								<thead>
								<tr>
									<th>First Name</th>
									<th>Last Name</th>
									<th>Remove</th>
								</tr>
								</thead>
								<tbody id="${each_section.id }_table">
									<c:forEach items="${sessionScope.all_students }" var="each_student" varStatus="loop">
									<c:if test="${each_student.section_id==each_section.id}">
									<tr id="${each_student.student_id }">
										<td>${each_student.first_name }</td>
										<td>${each_student.last_name }</td>
										<td><input type ="button" class="pure-button button-error delete_btn" value="Delete"></td>
									</tr>
									</c:if>
									</c:forEach>
								</tbody>
							</table>
							</div>
						</div>
						</c:forEach>
					</div>
					
					<hr>
					<div class="pure-u-1-3"><input id="new_section_name" type="text" value="" style="width:90%; height:32px;"></div>
					<div class="pure-u-1-6"><button id="add_new_section">New Group</button></div>
				</div>
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
<div id="dialog-message" class="dlg" title="Upload File Error">
  <p>
    <span class="ui-icon ui-icon-closethick" style="float:left; margin:0 7px 50px 0;"></span>
    Please choose the file you want to upload
  </p>
</div>

<c:remove var="problem_set_name" scope="session"/>
<c:remove var="student_link" scope="session"/>
<c:remove var="teacher_link" scope="session"/>
</body>
</html>
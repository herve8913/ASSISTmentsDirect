<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" href="http://yui.yahooapis.com/pure/0.6.0/pure-min.css">
<link rel="stylesheet" href="stylesheets/styles.css">
<script type="text/javascript" src="jquery-2.1.3.js"></script>
<script type="text/javascript" src="knockout-3.3.0.js"></script>
<script type="text/javascript">
var GiftModel = function(gifts) {
    var self = this;
    self.gifts = ko.observableArray(gifts);
 
    self.addGift = function() {
        self.gifts.push({
        	student_first: "",
        	student_last: ""
        });
    };
 
    self.removeGift = function(gift) {
        self.gifts.remove(gift);
    };
 
    self.save = function(form) {
        alert("Could now transmit to server: " + ko.utils.stringifyJson(self.gifts));
        // To actually transmit to server as a regular form post, write this: ko.utils.postJson($("form")[0], self.gifts);
    };
};
 $(function() {
	 var viewModel = new GiftModel([
		{ student_first: "Tom", student_last: "Hanks"},
		{ student_first: "Adam", student_last: "Smith"}
	      
	 ]);
	 ko.applyBindings(viewModel);	 
 });

</script>
<title>Micro ASSISTments</title>
</head>
<body>
<div id="page-wrap">
<br><br><br>
<form action="LiteSetup"  method="POST"  class="pure-form pure-form-aligned">
<fieldset>
	<div class="pure-control-group">
		<label for="first_name">First Name </label>
		<input type="text" name="first_name"  placeholder="First Name">
	</div>
	<div class="pure-control-group">
		<label for="last_name">Last Name</label>
		<input type="text" name="last_name" placeholder="Last Name">
	</div>
	<div class="pure-control-group">
		<label for="display_name">Display Name</label>
		<input type="text" name="display_name"  placeholder="Display Name">
	</div>
	<div class="pure-control-group">
		<label  for="email">Email</label>
		<input type="text" name="email" placeholder="Email">
	</div>
	<div class="pure-control-group">
		<label for="roster">Roster</label>
		<input type="hidden"  value="yes" name="roster">
		<div id="roster" >
		<p>You have <span data-bind='text: gifts().length'>&nbsp;</span> student(s) on your roster.</p>
		<input type="hidden"  data-bind='textInput: gifts().length'  name="count">
		<table data-bind='visible: gifts().length > 0'  class="pure-table">
        <thead>
            <tr>
                <th>First Name</th>
                <th>Last Name</th>
                <th />
            </tr>
        </thead>
        <tbody data-bind='foreach: gifts'>
            <tr>
                <td><input class='required'  data-bind='value: student_first, uniqueName: true' /></td>
                <td><input class='required number'  data-bind='value: student_last, uniqueName: true' /></td>
                <td><a href='#' data-bind='click: $root.removeGift'>Delete</a></td>
            </tr>
        </tbody>
    </table>
 	<br><br>
    <button data-bind='click: addGift' class="pure-button">Add Student</button>
    </div>
	</div>
	<br>
	<div class="pure-control-group">
		<label for="problem_set">Problem Set</label>
		<input type="text" name="problem_set">
	</div>
	<div class="pure-controls">
		<input type="submit"  value="Submit"  class="pure-button pure-button-primary">
		</div>
	</fieldset>
</form>
</div> <!-- end of page wrap -->
</body>
</html>
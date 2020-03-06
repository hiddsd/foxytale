<?php
header("Content-Type: apllication/json");

session_start();
require("lib.php");
require("api.php");


switch ($_POST['command']) {
	case "login": 
		login($_POST['username'], $_POST['password']); break;
 
	case "register":
		register($_POST['username'], $_POST['password'], $_POST['email']); break;
		
	case "upload":
	upload($_SESSION['IdUser'], $_FILES['files'], $_POST['title'], $_POST['description'], $_POST['hashtags'], $_POST['contributers']);break;

	case "addPicture":
	addPicture($_SESSION['IdUser'], $_FILES['file'], $_POST['IdStory']);break;

	case "logout":
	logout();break;

	case "stream":
	stream((int)$_POST['IdStory'], $_SESSION['IdUser'], (int)$_POST['option'], (int)$_POST['searchoption'], $_POST['searchterm'], (int)$_POST['offset']);break;

	case "friendlist":
	friendlist($_SESSION['IdUser']);break;

	case "deleteFriend":
	deleteFriend($_SESSION['IdUser'], $_POST['friendname']);break;

	case "addFriend":
	addFriend($_SESSION['IdUser'], $_POST['friendname']);break;

	case "like":
	like($_SESSION['IdUser'], (int)$_POST['IdStory']);break;

	case "getNotifications":
	getNotifications($_SESSION['IdUser'], (int)$_POST['option']);break;

}

exit();
?>
<?php
function errorJson($msg){
	print json_encode(array('error'=>$msg));
	exit();
}

function register($user, $pass, $email) {
	//check if username exists
	$login = query("SELECT username FROM users WHERE username='%s' limit 1", $user);
	if (count($login['result'])>0) {
		errorJson('0001');
	}
	$login = query("SELECT email FROM users WHERE email='%s' limit 1", $email);
	if (count($login['result'])>0) {
		errorJson('0002');
	}
	//try to register the user
	$result = query("INSERT INTO users(username, password, email) VALUES('%s','%s','%s')", $user, $pass, $email);
	if (! isset($result['error'])) {
		//success
		login($user, $pass);
	} else {
		//error
		errorJson('0003');
	} 
}
function login($user, $pass) {
	$result = query("SELECT IdUser, username FROM users WHERE username='%s' AND password='%s' limit 1", $user, $pass);
 
	if (count($result['result'])>0) {
		//authorized
		$_SESSION['IdUser'] = $result['result'][0]['IdUser'];
		print json_encode($result);
	} else {
		//not authorized
		errorJson('Authorization failed');
	}
}

function addPicture($id, $photoData, $IdStory) {
	//check if a user ID is passed
	if (! isset($id)) errorJson('0007');

	//check if there was no error during the file upload
	if ($photoData['error']==0) {
		$result = query("INSERT INTO photos(IdUser,IdStory) VALUES('%d','%d')", $id, $IdStory);
		if ( !isset($result['error'])) {
 
			//database link
			global $link;
 
			//get the last automatically generated ID
			$IdPhoto = mysql_insert_id($link);

			//Create User folder if not exists
			$path = 'upload/'.$id;
			if (! (is_dir($path))) {
    			mkdir($path);
			}
			//Create Story Folder if not exists
			$path = 'upload/'.$id.'/'.$IdStory;
			if (! (is_dir($path))) {
    			mkdir($path);
			}

			//UpDate Story
			$result = query("UPDATE storys SET last_update=NOW() WHERE IdStory='%d'", $IdStory);
			//if user is not Story Creator: link user to story and add a notification
			$result = query("SELECT IdStory FROM storys WHERE IdStory='%d' AND IdCreator='%d'", $IdStory, $id);
			if (count($result['result'])==0) {
				$data = query("SELECT u.username, s.titel FROM users u, storys s WHERE s.IdStory='%d' AND u.IdUser='%d'", $IdStory, $id);
				$username = $data['result'][0]['username'];
				$titel = $data['result'][0]['titel'];
				//Check if user allready linked to story
				$result = query("SELECT IdUser FROM contributers WHERE IdStory='%d' AND IdUser='%d'", $IdStory, $id);
				if(count($result['result'])==0)
					$result = query("INSERT INTO contributers(IdUser, IdStory) VALUES('%d','%d')", $id, $IdStory);				
				$result = query("INSERT INTO notifications(IdStory, kind, IdUser, username, titel) VALUES('%d', 1, '%d', '%s', '%s')", $IdStory, $id, $username, $titel);
			}

			 
			//move the temporarily stored file to a convenient location
			if (move_uploaded_file($photoData['tmp_name'], "upload/".$id."/".$IdStory."/".$IdPhoto.".jpg")) {				
				print json_encode(array('successful'=>1));
			} else {
				errorJson('0008');
			};
 
		} else {
			errorJson('0009');
		}
	} else {
		errorJson('0008');
	}
}


function upload($id, $photoData, $title, $description, $hashtags, $contributers) {

	//check if a user ID is passed
	if (!isset($id)) errorJson('0007');
 
	//check if there was no error during the file upload
	$error = false;
	for($i=0; $i < count($photoData['error']); $i++){
		if($photoData['error'][$i] != 0)$error = true;
		if($photoData['type'][$i] != 'image/jpeg') $error = true;
	}

	if ($error == false) {
		//create Story
		$result = query("INSERT INTO storys(titel, description, IdCreator, contributers) VALUES('%s', '%s', '%d', '%d')", $title, $description, $id, $contributers);
		global $link;
		$IdStory = mysql_insert_id($link);

		//Add hashtags
		$hashtagArray = explode(",", $hashtags);
		foreach($hashtagArray as $hashtag){
			if($hashtag != "")$result = query("INSERT INTO hashtags(hashtag, IdStory) VALUES('%s','%d')", $hashtag, $IdStory);
		}
		//Create User folder if not exists
		$path = 'upload/'.$id;
		if ( !(is_dir($path))) {
    		mkdir($path);
		}
		//Create Story Folder if not exists
		$path = 'upload/'.$id.'/'.$IdStory;
		if ( !(is_dir($path))) {
    		mkdir($path);
		}			
		

		$error = false;
		$file_ary = reArrayFiles($photoData);
		$pic_count = 0;
		foreach ($file_ary as $file){
			$result = query("INSERT INTO photos(IdUser,IdStory) VALUES('%d','%d')", $id, $IdStory);
			if (!isset($result['error'])) {
 				$pic_count++;
				//database link
				global $link;
 
				//get the last automatically generated ID
				$IdPhoto = mysql_insert_id($link);				
 
				//move the temporarily stored file to a convenient location
				if (move_uploaded_file($file['tmp_name'], "upload/".$id."/".$IdStory."/".$IdPhoto.".jpg")) {
					//file moved, all good, generate thumbnail
					//first Picture of story is the cover
					if($pic_count == 1){
						thumb("upload/".$id."/".$IdStory."/".$IdPhoto.".jpg", 180);
						$result = query("UPDATE storys SET IdThumbnail='%d' WHERE IdStory='%d'", $IdPhoto, $IdStory);
					}								
				} else {
					$error = true;
					errorJson('0008');	
				} 
			} else {
				$error = true;
				errorJson('0009');
			}
		}
		if($error == false)print json_encode(array('successful'=>1));
	
	} else {
		errorJson('0009');
	}
}

function logout() {
	$_SESSION = array();
	session_destroy();
}

function stream($IdStory=0, $id=0, $option=0, $searchoption=0, $searchterm, $offset=0) {

	$offset = $offset * 18;

	//Friends
	if($option == 1){
		//check if a user ID is passed
		if ($id == 0) errorJson('Authorization required');
		
		if($searchoption == 1){
			//user Search
			$result = query("SELECT s.IdCreator, s.IdStory, s.IdThumbnail, s.contributers FROM storys s, users u, friends f WHERE f.IdUser = '%d' AND f.IdFriend = s.IdCreator AND s.IdCreator = u.IdUser AND u.username='%s' ORDER BY s.last_update DESC LIMIT %d,%d", $id, $searchterm, $offset, MAX_THUMBNAILS);
			if (count($result['result'])==0) {
				errorJson('0004');
			}
		} else if($searchoption == 2){
			//hashtag Search
			$result = query("SELECT s.IdCreator, s.IdStory, s.IdThumbnail, s.contributers FROM storys s, users u, friends f, hashtags h WHERE f.IdUser = '%d' AND f.IdFriend = s.IdCreator AND s.IdCreator = u.IdUser AND s.IdStory = h.IdStory AND h.hashtag='%s' ORDER BY s.last_update DESC LIMIT %d,%d", $id, $searchterm, $offset, MAX_THUMBNAILS);
			if (count($result['result'])==0) {
				errorJson('0005');
			}
		}else if($searchoption == 3){
			//Titel Search
			$result = query("SELECT s.IdCreator, s.IdStory, s.IdThumbnail, s.contributers FROM storys s, users u, friends f WHERE f.IdUser = '%d' AND f.IdFriend = s.IdCreator AND s.IdCreator = u.IdUser AND s.titel='%s' ORDER BY s.last_update DESC LIMIT %d,%d", $id, $searchterm, $offset, MAX_THUMBNAILS);
			if (count($result['result'])==0) {
				errorJson('0006');
			}
		}else{
			//all friends
			$result = query("SELECT s.IdCreator, s.IdStory, s.IdThumbnail, s.contributers FROM storys s, users u, friends f WHERE f.IdUser = '%d' AND f.IdFriend = s.IdCreator AND s.IdCreator = u.IdUser ORDER BY s.last_update DESC LIMIT %d,%d", $id, $offset, MAX_THUMBNAILS);
		}
		foreach ($result['result'] as &$value){
			$contributer = $value['contributers'];
			$creator = $value['IdCreator'];
			if($contributer == 1){
				$conresult = query("SELECT IdUser FROM friends WHERE IdUser='%d' AND IdFriend='%d'", $creator, $id);
				if(count($conresult['result'])>0) $contributer = 2;
			}
			$value['contributers'] = $contributer;
		}
	}

	//Mine
	else if($option == 2){	
		//check if a user ID is passed
		if ($id == 0) errorJson('Authorization required');

		if($searchoption == 2){
			//hashtag Search
			$result = query("SELECT s.IdCreator, s.IdStory, s.IdThumbnail, s.contributers FROM storys s, users u, hashtags h WHERE s.IdCreator = '%d' AND s.IdCreator = u.IdUser AND s.IdStory = h.IdStory AND h.hashtag='%s' ORDER BY s.last_update DESC LIMIT %d,%d", $id, $searchterm, $offset, MAX_THUMBNAILS);
			if (count($result['result'])==0) {
				errorJson('0005');
			}
		}
		else if($searchoption == 3){
			//titel search
			$result = query("SELECT s.IdCreator, s.IdStory, s.IdThumbnail, s.contributers FROM storys s, users u WHERE s.IdCreator = '%d' AND s.IdCreator = u.IdUser AND s.titel='%s' ORDER BY s.last_update DESC LIMIT %d,%d", $id, $searchterm, $offset, MAX_THUMBNAILS);
			if (count($result['result'])==0) {
				errorJson('0006');
			}
		}
		else{
			//All my Storys
			$result = query("SELECT s.IdCreator, s.IdStory, s.IdThumbnail, s.contributers FROM storys s, users u WHERE s.IdCreator = '%d' AND s.IdCreator = u.IdUser ORDER BY s.last_update DESC LIMIT %d,%d", $id, $offset, MAX_THUMBNAILS);
		}		
		foreach ($result['result'] as &$value){
			$value['contributers'] = 2;
		}
	}

	//ALL
	else if ($option == 0 && $IdStory == 0) {		
		if($searchoption == 1){
			//user Search
			$result = query("SELECT s.IdCreator, s.IdStory, s.IdThumbnail, s.contributers FROM storys s, users u WHERE s.IdCreator = u.IdUser AND u.username='%s' ORDER BY s.last_update DESC LIMIT %d,%d", $searchterm, $offset, MAX_THUMBNAILS);
			if (count($result['result'])==0) {
				errorJson('0004');
			}
		}else if($searchoption == 2){
			//hashtag Search
			$result = query("SELECT s.IdCreator, s.IdStory, s.IdThumbnail, s.contributers FROM storys s, users u, hashtags h WHERE s.IdCreator = u.IdUser AND s.IdStory = h.IdStory AND h.hashtag='%s' ORDER BY s.last_update DESC LIMIT %d,%d", $searchterm, $offset, MAX_THUMBNAILS);
			if (count($result['result'])==0) {
				errorJson('0005');
			}
		}else if($searchoption == 3){
			//title search
			$result = query("SELECT s.IdCreator, s.IdStory, s.IdThumbnail, s.contributers FROM storys s, users u WHERE s.IdCreator = u.IdUser AND s.titel='%s' ORDER BY s.last_update DESC LIMIT %d,%d", $searchterm, $offset, MAX_THUMBNAILS);
			if (count($result['result'])==0) {
				errorJson('0006');
			}
		}else{
			//ALL Storys
			//Taht have more likes than average
			$result = query("SELECT s.IdCreator, s.IdStory, s.IdThumbnail, s.contributers FROM storys s, users u WHERE s.IdCreator = u.IdUser AND s.likes >= (select avg(st.likes) from storys st) ORDER BY s.last_update DESC LIMIT %d", MAX_THUMBNAILS);
		}
		foreach ($result['result'] as &$value){
			$contributer = $value['contributers'];
			$creator = $value['IdCreator'];
			if($creator == $id) $contributer = 2;
			else if($contributer == 1){
				$conresult = query("SELECT IdUser FROM friends WHERE IdUser='%d' AND IdFriend='%d'", $creator, $id);
				if(count($conresult['result'])>0) $contributer = 2;
			}
			$value['contributers'] = $contributer;
		}

	} else { //Story detailansicht
		$result = query("SELECT s.IdStory, s.titel, s.likes, s.description, u.username, p.IdPhoto, p.IdUser, (SELECT count(IdUser) FROM contributers WHERE IdStory = '%d') AS contributercount FROM storys s, photos p, users u WHERE s.IdStory = '%d' AND s.IdStory = p.IdStory AND p.IdUser = u.IdUser ORDER BY p.IdPhoto LIMIT 1,10000", $IdStory, $IdStory);
	}
 
	if (!isset($result['error'])) {
		print json_encode($result);
	} else {
		errorJson('Photo stream is broken');
	}
}

function friendlist($IdUser){
	//check if a user ID is passed
	if (!isset($IdUser)) errorJson('Authorization required');

	$result = query("SELECT f.IdFriend, u.username FROM users u, friends f WHERE f.IdUser='%d' AND f.IdFriend = u.IdUser", $IdUser);
	if (!isset($result['error'])) {
		//success
		print json_encode($result);
	} else {
		errorJson('Show Friendlist failed');
	} 
}

function deleteFriend($IdUser, $friendname){
	//check if a user ID is passed
	if (!isset($IdUser)) errorJson('Authorization required');

	$result = query("DELETE del FROM friends AS del JOIN users AS u ON del.IdFriend = u.IdUser WHERE del.IdUser='%d' AND u.username = '%s'", $IdUser, $friendname);
	if (!isset($result['error'])) {
		//success
		print json_encode(array('successful'=>1));
	} else {
		errorJson('Delete Friend failed');
	} 
}

function addFriend($IdUser, $friendname){
	//check if a user ID is passed
	if (!isset($IdUser)) errorJson('Authorization required');

	//check if are allready friends
	$result = query("SELECT f.IdUser FROM friends f, users u WHERE f.IdUser='%d' AND f.IdFriend = u.IdUser AND u.username='%s'", $IdUser, $friendname);
	if (count($result['result'])>0) {
		errorJson('0012');
	}
	//Check if user exists
	$result = query("SELECT IdUser FROM users WHERE username='%s'", $friendname);
	if (count($result['result'])==0) {
		errorJson('0013');
	}
	$IdFriend = $result['result'][0]['IdUser'];

	$result = query("INSERT INTO friends (IdUser, IdFriend) VALUES('%d', '%d')", $IdUser, $IdFriend);
	
	//database link
	global $link;
	if (mysql_affected_rows($link) == 1) {
		//Add Notification 
		$data = query("SELECT username FROM users WHERE IdUser='%d'", $IdUser);
		$username = $data['result'][0]['username'];
		$result = query("INSERT INTO notifications(kind, IdUser, username) VALUES(3, '%d', '%s')", $IdFriend, $username);
		//success
		print json_encode(array('successful'=>1));
	} else {
		errorJson('0011');
	} 
}

function like($IdUser, $IdStory){
	//check if a user ID is passed
	if (!isset($IdUser)) errorJson('0007');

	//check if user already liked story
	$result = query("SELECT IdStory FROM likes WHERE IdStory='%d' AND IdUser='%d'", $IdStory, $IdUser);
	if (count($result['result'])>0) {
		errorJson('0010');
	}else{
		//Add Notification 
		$data = query("SELECT u.username, s.titel FROM users u, storys s WHERE s.IdStory='%d' AND u.IdUser='%d'", $IdStory, $IdUser);
		$username = $data['result'][0]['username'];
		$titel = $data['result'][0]['titel'];
		$result = query("INSERT INTO notifications(IdStory, kind, IdUser, username, titel) VALUES('%d', 2, '%d', '%s', '%s')", $IdStory, $IdUser, $username, $titel);
		//Like Story
		$result = query("INSERT INTO likes (IdStory, IdUser) VALUES('%d', '%d')", $IdStory, $IdUser);
		$result = query("UPDATE storys set likes = likes + 1 WHERE IdStory = '%d'", $IdStory);
		global $link;
		if (mysql_affected_rows($link) == 1) {
			//success
			print json_encode(array('successful'=>1));
		} else {
			errorJson('0011');
		} 
	}
}

function getNotifications($IdUser, $option){
	//check if a user ID is passed
	if (!isset($IdUser)) errorJson('Authorization required');

	if($option == 0){ //Get Notifications to my Story
		$result = query("SELECT n.IdStory, n.username, n.titel, n.kind FROM notifications n, storys s WHERE s.IdCreator='%d' AND n.IdStory = s.IdStory AND n.IdUser <> '%d' ORDER BY n.IdNotification DESC LIMIT 0,80", $IdUser, $IdUser);
	}
	else if($option == 1){ //Get Notifications to Storys i contributed
		$result = query("SELECT n.IdStory, n.username, n.titel, n.kind FROM notifications n, contributers c WHERE c.IdUser='%d' AND n.IdStory = c.IdStory AND n.IdUser <> '%d' ORDER BY n.IdNotification DESC LIMIT 0,80", $IdUser, $IdUser);
	}
	else if($option == 2){ //Get Notification if someone added me as friend
		$result = query("SELECT username, kind FROM notifications WHERE IdUser='%d' AND kind='%d' ORDER BY IdNotification DESC LIMIT 0,80", $IdUser, 3);
	}
	if (!isset($result['error']) && $result) {
		print json_encode($result);
	} else {
		errorJson('Notifications are broken');
	}
}

?>
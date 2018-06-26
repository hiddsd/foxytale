<?php

define("MAX_THUMBNAILS", 19);

//setup db connection
//$link = mysql_connect("localhost","root","domian");
$link = mysql_connect("...", "...", "...");
//mysql_select_db("story_strips", $link);
mysql_select_db("db", $link);

//executes a given sql query with the params and returns an array as result
function query() {
	global $link;
	$debug = false;
	
	//get the sql query
	$args = func_get_args();
	$sql = array_shift($args);

	//secure the input
	for ($i=0;$i<count($args);$i++) {
		$args[$i] = urldecode($args[$i]);
		$args[$i] = mysql_real_escape_string($args[$i], $link);
	}
	
	//build the final query
	$sql = vsprintf($sql, $args);
	
	if ($debug) print $sql;
	
	//execute and fetch the results
	$result = mysql_query($sql, $link);
	if (mysql_errno($link)==0 && $result) {
		
		$rows = array();

		if ($result!==true)
		while ($d = mysql_fetch_assoc($result)) {
			array_push($rows,$d);
		}
		
		//return json
		return array('result'=>$rows);
		
	} else {
	
		//error
		return array('error'=>'Database error');
	}
}

//loads up the source image, resizes it and saves with -thumb in the file name
function thumb($srcFile, $sideInPx) {

  $image = imagecreatefromjpeg($srcFile);
  $width = imagesx($image);
  $height = imagesy($image);
  
  $thumb = imagecreatetruecolor($sideInPx, $sideInPx);
  
  imagecopyresized($thumb,$image,0,0,0,0,$sideInPx,$sideInPx,$width,$height);
  
  imagejpeg($thumb, str_replace(".jpg","-thumb.jpg",$srcFile), 85);
  
  imagedestroy($thumb);
  imagedestroy($image);
}

function reArrayFiles(&$file_post) {

    $file_ary = array();
    $file_count = count($file_post['name']);
    $file_keys = array_keys($file_post);

    for ($i=0; $i<$file_count; $i++) {
        foreach ($file_keys as $key) {
            $file_ary[$i][$key] = $file_post[$key][$i];
        }
    }

    return $file_ary;
}

?>
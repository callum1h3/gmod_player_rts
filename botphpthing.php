<?php 
$req = "request";
$send = "send";
if ($_POST["request"] == $req) 
{
	if (file_exists($_POST["name"].".txt")) {
        $myfile = fopen($_POST["name"].".txt", "r") or die("Unable to open file!");
        echo fread($myfile,filesize($_POST["name"].".txt"));
        fclose($myfile);
        unlink($_POST["name"].".txt");
    }
}
elseif ($_POST["request"] == $send) 
{
    $myfile = fopen($_POST["name"].".txt", "w") or die("Unable to open file!");   
    fwrite($myfile, $_POST["info"]);
    fclose($myfile);
}
?>
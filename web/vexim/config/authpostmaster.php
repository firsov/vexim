<?php
  include_once dirname(__FILE__) . "/variables.php";
  include_once dirname(__FILE__) . "/httpheaders.php";

  $query = "SELECT clear FROM users WHERE localpart='".$_SESSION['localpart']."' and domain_id='".$_SESSION['domain_id']."' AND admin='1';";
  $results = $db->query($query);
  $row = $results->fetchRow();

  // If the localpart isn't in the cookie, or the database
  // password doesn't match the cookie password, reject the
  // user to the login screen
  // print_r($_SESSION);
  if (!isset($_SESSION['localpart'])) { header ("Location: index.php?login=failed"); };
  if ($row['clear'] != $_SESSION['clear']) { header ("Location: index.php?login=failed"); };
?>

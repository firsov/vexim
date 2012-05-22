<?php
  /* SQL Database login information */
  require_once "DB.php";
  include_once dirname(__FILE__) . "/i18n.php";

  $sqlserver = "unix+localhost";
  $sqltype = "mysql";
  $sqldb = "vexim";
  $sqluser = "vexim";
  $sqlpass = "%MYPW%";
  $dsn = "$sqltype://$sqluser:$sqlpass@$sqlserver/$sqldb";
  $db = DB::connect($dsn);
  if (DB::isError($db)) { die ($db->getMessage()); }
  $db->setFetchMode(DB_FETCHMODE_ASSOC); 

  $db->simpleQuery('set names UTF8');
  /* We use this IMAP server to check user quotas */
  $imapquotaserver = "{localhost:143/imap/notls}";
  $imap_to_check_quota = "no";

  /* Setting this to 0 if only admins should be allowed to login */
  $AllowUserLogin = 1;

  /* Choose whether to break up domain and user lists alphabetically */
  $alphadomains = 1;
  $alphausers = 1;

  $domaininput = "dropdown";

  /* The UID's and GID's control the default UID and GID for new domains
     and if postmasters can define their own.
     THE UID AND GID MUST BE NUMERIC! */
  $uid = "%UID%";
  $gid = "%GID%";
  $postmasteruidgid = "yes";

  /* The location of your mailstore for new domains.
     Make sure the directory belongs to the configured $uid/$gid! */
  $mailroot = "/usr/local/mail/";

  /* path to Mailman */
  $mailmanroot = "http://www.EXAMPLE.com/mailman";

  /* sa_tag is the default value to offer when we create new domains for SpamAssassin tagging
     sa_refuse is the default value to offer when we create new domains for SpamAssassin dropping */
  $sa_tag = "2";
  $sa_refuse = "5";

  /* max size of a vacation message */
  $max_vacation_length = 255;

  /* Welcome message, sent to new POP/IMAP accounts */
  $welcome_message = "Welcome, {$_POST['realname']} !\n\nYour new E-mail account is all ready for you.\n\n"
                   . "Here are some settings you might find useful:\n\n"
		   . "Username: {$_POST['localpart']}@{$_SESSION['domain']}\n"
		   . "POP3 server: mail.{$_SESSION['domain']}\n"
		   . "SMTP server: mail.{$_SESSION['domain']}\n";

  /* Welcome message, sent to new domains */
  $welcome_newdomain = "Welcome, and thank you for registering your e-mail domain\n"
  		     . "{$_POST['domain']} with us.\n\nIf you have any questions, please\n"
		     . "don't hesitate to ask your account representitive.\n";
?>

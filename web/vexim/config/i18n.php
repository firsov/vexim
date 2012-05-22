<?php

$language = 'ru_RU';
putenv ("LANG=$language");
setlocale(LC_ALL, "ru_RU.UTF-8");
bindtextdomain('messages', './locale');
textdomain('messages');

?>

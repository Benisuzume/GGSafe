CREATE TABLE IF NOT EXISTS `app` (
  `id` tinyint(1) unsigned NOT NULL,
  `is_disabled` tinyint(1) NOT NULL,
  `latest_version` decimal(2,1) NOT NULL,
  `download_url` varchar(64) NOT NULL,
  `proxy` varchar(512) NOT NULL,
  `ip_looking_up` varchar(15) NOT NULL,
  `message` varchar(2000) CHARACTER SET utf8 NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

INSERT INTO `app` (`id`, `is_disabled`, `latest_version`, `download_url`, `proxy`, `ip_looking_up`, `message`) VALUES
(1, 0, '1.8', 'http://ggsafe.ir/downloads/GGSafe-1.8-Setup.exe', '80.85.156.42:7456', '203.117.124.7', '\n【 لینک دانلود آخرین نسخه جی جی سیف 】\n【 http://forum.ggsafe.ir/showthread.php?tid=117 】\n\n【 برای دریافت آخرین اخبار گارنا لطفا عضو کانال تلگرام ما بشید 】\n【 http://telegram.me/GGSafe 】\n\n【 انجمن رسمی گارنا】\n【 http://forum.ggsafe.ir/ 】\n\n【 آموزش حل مشکل دریافت پیغام مپ هک (MH) 】\n【 http://forum.ggsafe.ir/showthread.php?tid=118 】\n\n【 لینک دانلود وارکرافت اورجینال برای دوستانی که از نسخه کپی شده استفاده میکنند و ارور مپ هک دریافت میکنند 】\n【 http://forum.ggsafe.ir/showthread.php?tid=131 】\n');

CREATE TABLE IF NOT EXISTS `chat_block` (
  `id` tinyint(3) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(16) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=1;

CREATE TABLE IF NOT EXISTS `log` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(15) NOT NULL,
  `machine_id` char(32) NOT NULL,
  `time` datetime NOT NULL,
  `ip` varchar(15) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1;

CREATE TABLE IF NOT EXISTS `pc_ban` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `machine_id` char(32) NOT NULL,
  `start` datetime NOT NULL,
  `end` datetime NOT NULL,
  `reason` varchar(128) NOT NULL,
  `admin` varchar(15) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1;


CREATE TABLE IF NOT EXISTS `rooms` (
  `RoomId` mediumint(8) unsigned NOT NULL,
  `RoomName` varchar(32) NOT NULL,
  `ServerId` tinyint(3) unsigned NOT NULL,
  `EntryLevel` tinyint(3) unsigned NOT NULL,
  `MaxUsers` tinyint(3) unsigned NOT NULL,
  PRIMARY KEY (`RoomId`),
  KEY `RoomName` (`RoomName`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `room_ban` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(15) NOT NULL,
  `room_name` varchar(32) NOT NULL,
  `start` datetime NOT NULL,
  `end` datetime NOT NULL,
  `reason` varchar(128) NOT NULL,
  `admim` varchar(15) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1;

CREATE TABLE IF NOT EXISTS `user_ban` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(15) NOT NULL,
  `start` datetime NOT NULL,
  `end` datetime NOT NULL,
  `reason` varchar(128) NOT NULL,
  `admin` varchar(15) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1;
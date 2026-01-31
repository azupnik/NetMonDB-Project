CREATE TABLE `Devices` (
  `device_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `mac_address` varchar(17) NOT NULL,
  `model` varchar(50) DEFAULT NULL,
  `location_name` varchar(50) DEFAULT 'Home',
  `installed_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`device_id`),
  UNIQUE KEY `mac_address` (`mac_address`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `Devices_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `Users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
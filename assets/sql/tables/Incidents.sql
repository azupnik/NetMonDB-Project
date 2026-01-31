CREATE TABLE `Incidents` (
  `incident_id` int(11) NOT NULL AUTO_INCREMENT,
  `provider_id` int(11) DEFAULT NULL,
  `start_time` timestamp NOT NULL DEFAULT current_timestamp(),
  `end_time` timestamp NULL DEFAULT NULL,
  `description` text DEFAULT NULL,
  `severity_level` enum('low','medium','critical') DEFAULT NULL,
  `status` enum('open','in_progress','resolved') DEFAULT 'open',
  PRIMARY KEY (`incident_id`),
  KEY `provider_id` (`provider_id`),
  CONSTRAINT `Incidents_ibfk_1` FOREIGN KEY (`provider_id`) REFERENCES `Providers` (`provider_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
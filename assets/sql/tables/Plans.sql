CREATE TABLE `Plans` (
  `plan_id` int(11) NOT NULL AUTO_INCREMENT,
  `provider_id` int(11) DEFAULT NULL,
  `name` varchar(100) NOT NULL,
  `max_download_mbps` int(11) NOT NULL CHECK (`max_download_mbps` > 0),
  `max_upload_mbps` int(11) NOT NULL CHECK (`max_upload_mbps` > 0),
  `price_pln` decimal(10,2) DEFAULT NULL CHECK (`price_pln` >= 0),
  `sla_guarantee_percent` decimal(5,2) DEFAULT 99.00 CHECK (`sla_guarantee_percent` between 0 and 100),
  PRIMARY KEY (`plan_id`),
  KEY `provider_id` (`provider_id`),
  CONSTRAINT `Plans_ibfk_1` FOREIGN KEY (`provider_id`) REFERENCES `Providers` (`provider_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
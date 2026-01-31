CREATE TABLE `Contracts` (
  `contract_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `plan_id` int(11) DEFAULT NULL,
  `start_date` date NOT NULL,
  `end_date` date DEFAULT NULL,
  `address_street` varchar(100) NOT NULL,
  `address_city` varchar(50) NOT NULL,
  `status` enum('active','expired','terminated') DEFAULT 'active',
  PRIMARY KEY (`contract_id`),
  KEY `user_id` (`user_id`),
  KEY `plan_id` (`plan_id`),
  CONSTRAINT `Contracts_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `Users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `Contracts_ibfk_2` FOREIGN KEY (`plan_id`) REFERENCES `Plans` (`plan_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
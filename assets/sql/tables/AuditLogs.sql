CREATE TABLE `AuditLogs` (
  `log_id` int(11) NOT NULL AUTO_INCREMENT,
  `table_name` varchar(50) DEFAULT NULL,
  `operation` varchar(10) DEFAULT NULL CHECK (`operation` in ('INSERT','UPDATE','DELETE')),
  `user_context` varchar(50) DEFAULT 'system',
  `change_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `details` text DEFAULT NULL,
  PRIMARY KEY (`log_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE `Invoices` (
  `invoice_id` int(11) NOT NULL AUTO_INCREMENT,
  `contract_id` int(11) DEFAULT NULL,
  `issue_date` date NOT NULL,
  `amount_pln` decimal(10,2) NOT NULL,
  `payment_status` enum('paid','unpaid','overdue') DEFAULT 'unpaid',
  `due_date` date NOT NULL,
  PRIMARY KEY (`invoice_id`),
  KEY `contract_id` (`contract_id`),
  CONSTRAINT `Invoices_ibfk_1` FOREIGN KEY (`contract_id`) REFERENCES `Contracts` (`contract_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
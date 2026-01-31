CREATE TABLE `IncidentAssignments` (
  `assignment_id` int(11) NOT NULL AUTO_INCREMENT,
  `incident_id` int(11) DEFAULT NULL,
  `tech_id` int(11) DEFAULT NULL,
  `assigned_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `notes` text DEFAULT NULL,
  PRIMARY KEY (`assignment_id`),
  KEY `incident_id` (`incident_id`),
  KEY `tech_id` (`tech_id`),
  CONSTRAINT `IncidentAssignments_ibfk_1` FOREIGN KEY (`incident_id`) REFERENCES `Incidents` (`incident_id`) ON DELETE CASCADE,
  CONSTRAINT `IncidentAssignments_ibfk_2` FOREIGN KEY (`tech_id`) REFERENCES `Technicians` (`tech_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
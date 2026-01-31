CREATE TABLE `Metrics` (
  `metric_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `device_id` int(11) DEFAULT NULL,
  `measured_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `ping_ms` int(11) DEFAULT NULL CHECK (`ping_ms` >= 0),
  `jitter_ms` int(11) DEFAULT NULL CHECK (`jitter_ms` >= 0),
  `packet_loss_percent` decimal(5,2) DEFAULT NULL CHECK (`packet_loss_percent` between 0 and 100),
  `download_speed_mbps` decimal(10,2) DEFAULT NULL CHECK (`download_speed_mbps` >= 0),
  `upload_speed_mbps` decimal(10,2) DEFAULT NULL CHECK (`upload_speed_mbps` >= 0),
  PRIMARY KEY (`metric_id`),
  KEY `device_id` (`device_id`),
  KEY `idx_metrics_date` (`measured_at`),
  CONSTRAINT `Metrics_ibfk_1` FOREIGN KEY (`device_id`) REFERENCES `Devices` (`device_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
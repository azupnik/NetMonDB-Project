DELIMITER $$
CREATE TRIGGER `Auto_Detect_Incident` AFTER INSERT ON `Metrics` FOR EACH ROW BEGIN
    DECLARE provider_id_var INT;
    
    IF NEW.ping_ms > 1000 THEN
        SELECT pl.provider_id INTO provider_id_var
        FROM Devices d
        JOIN Users u ON d.user_id = u.user_id
        JOIN Contracts c ON u.user_id = c.user_id
        JOIN Plans pl ON c.plan_id = pl.plan_id
        WHERE d.device_id = NEW.device_id
        LIMIT 1;
        INSERT INTO Incidents (provider_id, description, severity_level, status)
        VALUES (provider_id_var, CONCAT('AUTO-ALERT: Krytyczny ping na urządzeniu ID: ', NEW.device_id), 'critical', 'open');
    END IF;
END
$$
DELIMITER ;
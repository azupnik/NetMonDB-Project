DELIMITER $$

CREATE TRIGGER Auto_Close_Incident
BEFORE UPDATE ON Incidents
FOR EACH ROW
BEGIN
    IF NEW.status = 'resolved' AND OLD.status != 'resolved' AND NEW.end_time IS NULL THEN
        SET NEW.end_time = CURRENT_TIMESTAMP();
    END IF;
    
    IF NEW.status != 'resolved' AND OLD.status = 'resolved' THEN
        SET NEW.end_time = NULL;
    END IF;
END$$

DELIMITER ;
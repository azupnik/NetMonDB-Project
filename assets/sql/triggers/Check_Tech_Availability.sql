DELIMITER $$

CREATE TRIGGER Check_Tech_Availability
BEFORE INSERT ON IncidentAssignments
FOR EACH ROW
BEGIN
    DECLARE tech_status TINYINT;

    SELECT is_available INTO tech_status
    FROM Technicians
    WHERE tech_id = NEW.tech_id;

    IF tech_status = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'BŁĄD: Ten technik jest obecnie niedostępny. Wybierz innego pracownika.';
    END IF;
END$$

DELIMITER ;
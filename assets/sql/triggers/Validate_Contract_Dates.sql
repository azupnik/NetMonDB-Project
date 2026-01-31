DELIMITER $$

CREATE TRIGGER Validate_Contract_Dates
BEFORE INSERT ON Contracts
FOR EACH ROW
BEGIN
    IF NEW.end_date IS NOT NULL AND NEW.end_date < NEW.start_date THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'BŁĄD: Data zakończenia umowy nie może być wcześniejsza niż data rozpoczęcia!';
    END IF;
END$$

DELIMITER ;
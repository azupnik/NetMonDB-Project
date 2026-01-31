DELIMITER $$
CREATE TRIGGER `Prevent_User_Delete` BEFORE DELETE ON `Users` FOR EACH ROW BEGIN
    DECLARE active_count INT;
    
    SELECT COUNT(*) INTO active_count 
    FROM Contracts 
    WHERE user_id = OLD.user_id AND status = 'active';
    
    IF active_count > 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'TEST ZALICZONY: Blokada usunięcia aktywnego klienta!';
    END IF;
END
$$
DELIMITER ;
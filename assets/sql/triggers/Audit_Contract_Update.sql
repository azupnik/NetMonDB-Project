DELIMITER $$
CREATE TRIGGER `Audit_Contract_Update` AFTER UPDATE ON `Contracts` FOR EACH ROW BEGIN
    INSERT INTO AuditLogs (table_name, operation, user_context, details)
    VALUES ('Contracts', 'UPDATE', CURRENT_USER(), CONCAT('Zmiana ID umowy: ', OLD.contract_id, '. Stary status: ', OLD.status, ', Nowy: ', NEW.status));
END
$$
DELIMITER ;
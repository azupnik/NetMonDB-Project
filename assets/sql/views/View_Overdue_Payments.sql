CREATE OR REPLACE VIEW `View_Overdue_Payments` AS 
SELECT 
  `u`.`username` AS `username`, 
  `u`.`email` AS `email`, 
  `i`.`invoice_id` AS `invoice_id`, 
  `i`.`amount_pln` AS `amount_pln`, 
  `i`.`due_date` AS `due_date`, 
  to_days(current_timestamp()) - to_days(`i`.`due_date`) AS `Days_Late` 
FROM `Users` `u` 
JOIN `Contracts` `c` on `u`.`user_id` = `c`.`user_id` 
JOIN `Invoices` `i` on `c`.`contract_id` = `i`.`contract_id` 
WHERE `i`.`payment_status` = 'overdue';
CREATE OR REPLACE VIEW `View_Provider_Stats` AS 
SELECT 
  `p`.`name` AS `Provider`, 
  count(distinct `c`.`contract_id`) AS `Active_Contracts`, 
  round(avg(`m`.`download_speed_mbps`),1) AS `Avg_Download`, 
  round(avg(`m`.`ping_ms`),1) AS `Avg_Ping`, 
  (select count(0) from `Incidents` `i` where `i`.`provider_id` = `p`.`provider_id`) AS `Total_Incidents` 
FROM `Providers` `p` 
JOIN `Plans` `pl` on `p`.`provider_id` = `pl`.`provider_id` 
JOIN `Contracts` `c` on `pl`.`plan_id` = `c`.`plan_id` 
JOIN `Users` `u` on `c`.`user_id` = `u`.`user_id` 
JOIN `Devices` `d` on `u`.`user_id` = `d`.`user_id` 
JOIN `Metrics` `m` on `d`.`device_id` = `m`.`device_id` 
GROUP BY `p`.`name`;
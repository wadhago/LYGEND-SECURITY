-- ====================================================================
-- 🛡️ LYGEND - MSGP Security Control Room Terminal
-- DATABASE SCHEMA FOR MYSQL (8.0+)
-- Camp Gatepass, Roster & Ingress Management System
-- ====================================================================
-- 
-- العربية:
-- هذا الملف يحتوي على هيكل وقواعد البيانات الكاملة لنظام أمن المخيم متوافقاً مع خوادم MySQL.
-- يمكنك استيراد هذا الملف مباشرة لتهيئة قاعدة البيانات بالبيانات الافتراضية للتشغيل.
--
-- English:
-- This file contains the complete MySQL database schema for the LYGEND - MSGP Terminal.
-- You can import this file directly into your MySQL server to set up all tables and default data.

CREATE DATABASE IF NOT EXISTS `lygend_msgp_db` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `lygend_msgp_db`;

-- Set variables for standard setup
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS `system_error_logs`;
DROP TABLE IF EXISTS `db_backups`;
DROP TABLE IF EXISTS `reissue_logs`;
DROP TABLE IF EXISTS `access_logs`;
DROP TABLE IF EXISTS `visitors`;
DROP TABLE IF EXISTS `employees`;
DROP TABLE IF EXISTS `system_users`;
DROP TABLE IF EXISTS `journey_plans`;
SET FOREIGN_KEY_CHECKS = 1;

-- --------------------------------------------------------------------
-- 1. TABLE: system_users (مشغلو ومستخدمو النظام)
-- --------------------------------------------------------------------
CREATE TABLE `system_users` (
  `id` VARCHAR(50) NOT NULL,
  `username` VARCHAR(100) NOT NULL UNIQUE,
  `name` VARCHAR(255) NOT NULL,
  `role` ENUM('Admin', 'Manager / Auditor', 'Data Entry Clerk', 'Security Operator') NOT NULL,
  `is_active` TINYINT(1) NOT NULL DEFAULT 1,
  `password_hash` VARCHAR(255) NOT NULL DEFAULT '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', -- Default PIN '1234' hash (for custom auth systems)
  `last_login` DATETIME NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------------------
-- 2. TABLE: employees (بيانات الموظفين والبطاقات الأمنية)
-- --------------------------------------------------------------------
CREATE TABLE `employees` (
  `id` VARCHAR(50) NOT NULL, -- e.g. LYG-X545
  `first_name` VARCHAR(100) NOT NULL,
  `surname` VARCHAR(100) NOT NULL,
  `name` VARCHAR(255) NOT NULL, -- Full name
  `job_title` VARCHAR(150) NOT NULL,
  `company_name` VARCHAR(150) NOT NULL,
  `department` VARCHAR(150) NOT NULL,
  `nationality` VARCHAR(100) NOT NULL,
  `gate_pass_expiry_date` DATE NOT NULL,
  `status` ENUM('Active', 'Terminated', 'Resigned', 'Suspended', 'On-Leave', 'In Camp', 'ST6', 'Atbra', 'Khartoum', 'PortSudan', 'Else') NOT NULL,
  `contract_type` ENUM('Direct', 'Contracted') NOT NULL DEFAULT 'Direct',
  `photo_url` TEXT NULL,
  `issue_counter` INT NOT NULL DEFAULT 1,
  `inside_camp` TINYINT(1) NOT NULL DEFAULT 0,
  `last_movement_time` DATETIME NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_emp_status` (`status`),
  INDEX `idx_inside_camp` (`inside_camp`),
  INDEX `idx_gate_pass_expiry` (`gate_pass_expiry_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------------------
-- 3. TABLE: visitors (سجلات زوار المخيم والموردين)
-- --------------------------------------------------------------------
CREATE TABLE `visitors` (
  `id` VARCHAR(50) NOT NULL, -- e.g. VS-901
  `name` VARCHAR(255) NOT NULL,
  `company_name` VARCHAR(150) NOT NULL,
  `purpose` TEXT NOT NULL,
  `national_id` VARCHAR(100) NOT NULL,
  `entry_time` DATETIME NOT NULL,
  `expected_exit_time` DATETIME NOT NULL,
  `actual_exit_time` DATETIME NULL,
  `inside_camp` TINYINT(1) NOT NULL DEFAULT 1,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_visitor_inside` (`inside_camp`),
  INDEX `idx_expected_exit` (`expected_exit_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------------------
-- 4. TABLE: access_logs (سجلات الدخول والخروج للبوابات الإلكترونية)
-- --------------------------------------------------------------------
CREATE TABLE `access_logs` (
  `id` VARCHAR(50) NOT NULL,
  `person_id` VARCHAR(50) NOT NULL,
  `person_name` VARCHAR(255) NOT NULL,
  `person_type` ENUM('Employee', 'Visitor') NOT NULL,
  `action` ENUM('Check-In', 'Check-Out') NOT NULL,
  `timestamp` DATETIME NOT NULL,
  `operator_id` VARCHAR(50) NOT NULL,
  `operator_name` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `idx_log_timestamp` (`timestamp`),
  INDEX `idx_person_id` (`person_id`),
  CONSTRAINT `fk_log_operator` FOREIGN KEY (`operator_id`) REFERENCES `system_users` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------------------
-- 5. TABLE: reissue_logs (سجلات إعادة إصدار وطباعة البطاقات التالفة)
-- --------------------------------------------------------------------
CREATE TABLE `reissue_logs` (
  `id` VARCHAR(50) NOT NULL,
  `employee_id` VARCHAR(50) NOT NULL,
  `employee_name` VARCHAR(255) NOT NULL,
  `reason` ENUM('Lost Card', 'Damaged Card', 'Title Change', 'Other') NOT NULL,
  `details` TEXT NOT NULL,
  `timestamp` DATETIME NOT NULL,
  `approved_by` VARCHAR(255) NOT NULL,
  `previous_counter` INT NOT NULL,
  `new_counter` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `idx_reissue_emp` (`employee_id`),
  CONSTRAINT `fk_reissue_emp` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------------------
-- 6. TABLE: journey_plans (إدارة الرحلات والمهام الأمنية الخارجية JMP)
-- --------------------------------------------------------------------
CREATE TABLE `journey_plans` (
  `id` VARCHAR(50) NOT NULL, -- e.g. JMP-2026-001
  `date_of_journey` DATE NOT NULL,
  `duration_of_mission` VARCHAR(100) NOT NULL,
  `activity_mission_type` VARCHAR(255) NOT NULL,
  `driver_name_id` VARCHAR(255) NOT NULL,
  `telephone_number` VARCHAR(50) NOT NULL,
  `journey_leader` VARCHAR(255) NOT NULL,
  `gsf_escort_required` TINYINT(1) NOT NULL DEFAULT 0,
  `escort_destination` VARCHAR(255) NULL,
  `departure_date_time` DATETIME NOT NULL,
  `arrival_date_time` DATETIME NOT NULL,
  `vehicle_details` VARCHAR(255) NOT NULL,
  `vehicle_communications` VARCHAR(255) NOT NULL,
  `communications_telephone` VARCHAR(100) NULL,
  `communications_radio` VARCHAR(100) NULL,
  `communications_satellite` VARCHAR(100) NULL,
  `tracking_device_fitted` TINYINT(1) NOT NULL DEFAULT 0,
  `tracking_device_callsign` VARCHAR(100) NULL,
  `mission_description` TEXT NOT NULL,
  `signature_driver_leader` VARCHAR(255) NULL,
  `hod_approval_name` VARCHAR(255) NULL,
  `route_clearance_approval_name` VARCHAR(255) NULL,
  `special_security_instructions` TEXT NULL,
  `status` ENUM('Draft', 'Submitted', 'Approved', 'Completed', 'Cancelled') NOT NULL DEFAULT 'Draft',
  `passengers_json` JSON NOT NULL, -- JSON List of PassengerDetail: [{"nameId": "...", "companyFunction": "...", "mobilePhone": "..."}]
  `check_in_calls_json` JSON NOT NULL, -- JSON List of check-in milestones: [{"location": "...", "timeOfCall": "..."}]
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_journey_status` (`status`),
  INDEX `idx_journey_date` (`date_of_journey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------------------
-- 7. TABLE: db_backups (سجلات النسخ الاحتياطي لقاعدة البيانات)
-- --------------------------------------------------------------------
CREATE TABLE `db_backups` (
  `id` VARCHAR(50) NOT NULL,
  `file_name` VARCHAR(255) NOT NULL,
  `timestamp` DATETIME NOT NULL,
  `file_size` VARCHAR(50) NOT NULL,
  `employees_count` INT NOT NULL,
  `visitors_count` INT NOT NULL,
  `logs_count` INT NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------------------
-- 8. TABLE: system_error_logs (سجل أحداث النظام والتحذيرات الأمنية)
-- --------------------------------------------------------------------
CREATE TABLE `system_error_logs` (
  `id` VARCHAR(50) NOT NULL,
  `timestamp` DATETIME NOT NULL,
  `module` VARCHAR(100) NOT NULL,
  `severity` ENUM('Info', 'Warning', 'Error', 'Critical') NOT NULL,
  `message` TEXT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `idx_err_severity` (`severity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ====================================================================
-- SEED DATA (البيانات الافتراضية للتشغيل والتجربة)
-- ====================================================================

-- Insert System Users
INSERT INTO `system_users` (`id`, `username`, `name`, `role`, `is_active`, `last_login`) VALUES
('USR-01', 'admin', 'John Doe', 'Admin', 1, '2026-06-25 08:00:00'),
('USR-02', 'auditor', 'Alice Johnson', 'Manager / Auditor', 1, '2026-06-25 09:12:00'),
('USR-03', 'clerk1', 'Michael Chang', 'Data Entry Clerk', 1, '2026-06-25 08:45:00'),
('USR-04', 'gate_operator', 'Guardsman Budi', 'Security Operator', 1, '2026-06-25 06:00:00');

-- Insert Employees
INSERT INTO `employees` (`id`, `first_name`, `surname`, `name`, `job_title`, `company_name`, `department`, `nationality`, `gate_pass_expiry_date`, `status`, `contract_type`, `photo_url`, `issue_counter`, `inside_camp`, `last_movement_time`) VALUES
('LYG-X545', 'Mohamed', 'Okasha', 'Mohamed Okasha', 'Security Supervisor', 'Lygend Mining Inc.', 'Site Safety & Security', 'Egyptian', '2026-12-31', 'In Camp', 'Direct', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=400', 1, 1, '2026-06-22 08:15:00'),
('LYG-0102', 'Lin', 'Wei', 'Lin Wei', 'HSE Manager', 'Lygend Mining Inc.', 'Health & Safety', 'Chinese', '2026-12-31', 'In Camp', 'Direct', 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&q=80&w=400', 1, 1, '2026-06-21 08:15:00'),
('LYG-0105', 'Amir', 'Hamzah', 'Amir Hamzah', 'Heavy Machinery Lead', 'Bina Karya Sub-Con', 'Civil Works', 'Indonesian', '2026-08-15', 'In Camp', 'Contracted', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=400', 3, 1, '2026-06-22 06:30:00'),
('LYG-0112', 'Sarah', 'Connor', 'Sarah Connor', 'Procurement Specialist', 'Lygend Logistics', 'Supply Chain', 'Australian', '2026-05-30', 'On-Leave', 'Contracted', 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=400', 1, 0, '2026-06-19 17:45:00');

-- Insert Visitors
INSERT INTO `visitors` (`id`, `name`, `company_name`, `purpose`, `national_id`, `entry_time`, `expected_exit_time`, `actual_exit_time`, `inside_camp`) VALUES
('VS-901', 'Robert Parker', 'General Electric', 'Turbine Generator Inspection', 'US8492019A', '2026-06-25 08:30:00', '2026-06-25 17:00:00', NULL, 1),
('VS-902', 'Hadi Prasetyo', 'Pertamina Fuel Supply', 'Diesel Delivery Fuel Drop', 'ID317329402948', '2026-06-25 09:15:00', '2026-06-25 11:30:00', NULL, 1),
('VS-903', 'Elena Rostova', 'Siberian Inspections', 'Environmental Soil Audit', 'RU29482049A', '2026-06-24 09:00:00', '2026-06-24 18:00:00', '2026-06-24 17:45:00', 0);

-- Insert Access Logs
INSERT INTO `access_logs` (`id`, `person_id`, `person_name`, `person_type`, `action`, `timestamp`, `operator_id`, `operator_name`) VALUES
('AL-1001', 'LYG-0102', 'Lin Wei', 'Employee', 'Check-In', '2026-06-24 08:15:00', 'USR-04', 'Guardsman Budi'),
('AL-1002', 'LYG-0112', 'Sarah Connor', 'Employee', 'Check-Out', '2026-06-22 17:45:00', 'USR-04', 'Guardsman Budi'),
('AL-1003', 'LYG-0105', 'Amir Hamzah', 'Employee', 'Check-In', '2026-06-25 06:30:00', 'USR-04', 'Guardsman Budi'),
('AL-1004', 'VS-903', 'Elena Rostova', 'Visitor', 'Check-In', '2026-06-24 09:00:00', 'USR-04', 'Guardsman Budi'),
('AL-1005', 'VS-903', 'Elena Rostova', 'Visitor', 'Check-Out', '2026-06-24 17:45:00', 'USR-04', 'Guardsman Budi');

-- Insert Reissue Logs
INSERT INTO `reissue_logs` (`id`, `employee_id`, `employee_name`, `reason`, `details`, `timestamp`, `approved_by`, `previous_counter`, `new_counter`) VALUES
('RL-501', 'LYG-0105', 'Amir Hamzah', 'Damaged Card', 'Heavy machinery operator card damaged during drilling operations.', '2026-04-12 10:00:00', 'Alice Johnson', 1, 2);

-- Insert Journey Plans
INSERT INTO `journey_plans` (`id`, `date_of_journey`, `duration_of_mission`, `activity_mission_type`, `driver_name_id`, `telephone_number`, `journey_leader`, `gsf_escort_required`, `escort_destination`, `departure_date_time`, `arrival_date_time`, `vehicle_details`, `vehicle_communications`, `communications_telephone`, `communications_radio`, `communications_satellite`, `tracking_device_fitted`, `tracking_device_callsign`, `mission_description`, `status`, `passengers_json`, `check_in_calls_json`) VALUES
('JMP-2026-001', '2026-06-25', '1 Day', 'HSE Audit Visit to ST6 Outpost', 'LYG-X545', '+24991234567', 'Lin Wei', 1, 'ST6 Security Outpost', '2026-06-25 07:00:00', '2026-06-25 17:00:00', 'Land Cruiser 4x4 (White) - Plate: KH-2910', 'VHF Radio / Mobile Phone', '+24991234567', 'Channel 16', 'N/A', 1, 'MOBILE_PATROL_1', 'Routine HSE site and fire safety compliance audit of construction zone ST6.', 'Approved', 
 '[{"nameId": "Amir Hamzah", "companyFunction": "Civil Supervisor", "mobilePhone": "+24999120412"}]', 
 '[{"location": "Gate A Departure", "timeOfCall": "07:15"}, {"location": "Checkpoint 1 Progress", "timeOfCall": "08:30"}]');

-- Insert Db Backups
INSERT INTO `db_backups` (`id`, `file_name`, `timestamp`, `file_size`, `employees_count`, `visitors_count`, `logs_count`) VALUES
('BK-001', 'msgp_backup_20260620_0001.sql', '2026-06-20 02:00:00', '1.24 MB', 4, 3, 5);

-- Insert System Error Logs
INSERT INTO `system_error_logs` (`id`, `timestamp`, `module`, `severity`, `message`) VALUES
('ERR-101', '2026-06-25 10:15:00', 'CARD_PRINTER_SERVICE', 'Warning', 'Zebra Card Printer ZC300 ribbons level below 15% threshold.'),
('ERR-102', '2026-06-25 14:22:11', 'SPEED_GATE_B', 'Critical', 'Network timeout connection drop on biometric speed-gate reader at Gate A South.');

-- ====================================================================
-- END OF SCHEMA
-- ====================================================================

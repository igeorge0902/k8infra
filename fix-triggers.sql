-- Fix missing triggers: recreate with correct table name casing for MySQL 8 on Linux.

USE login_;

-- Triggers on forgotPsw (the dump had lowercase `forgotpsw`)
DROP TRIGGER IF EXISTS `forgotPsw_BEFORE_INSERT`;
DROP TRIGGER IF EXISTS `forgotPsw_BEFORE_UPDATE`;

-- Triggers on Last_seen (the dump had lowercase `last_seen`)
DROP TRIGGER IF EXISTS `tokens`;
DROP TRIGGER IF EXISTS `Last_seen_AFTER_UPDATE`;

-- Triggers on Tokens (the dump had lowercase `tokens`)
DROP TRIGGER IF EXISTS `Tokens_BEFORE_INSERT`;
DROP TRIGGER IF EXISTS `Tokens_BEFORE_UPDATE`;

DELIMITER ;;

CREATE TRIGGER `forgotPsw_BEFORE_INSERT` BEFORE INSERT ON `forgotPsw` FOR EACH ROW
BEGIN
  SET NEW.forgotRequestToken = RAND();
  SET NEW.isValid = 1;
END;;

CREATE TRIGGER `forgotPsw_BEFORE_UPDATE` BEFORE UPDATE ON `forgotPsw` FOR EACH ROW
BEGIN
  SET NEW.forgotRequestToken = RAND();
END;;

CREATE TRIGGER `tokens` AFTER INSERT ON `Last_seen` FOR EACH ROW
BEGIN
  DECLARE deviceId_ char(255);
  DECLARE id_ char(255);
  SELECT id, deviceId INTO id_, deviceId_ FROM Last_seen
    WHERE last_insert_id() = last_insert_id() ORDER BY id DESC LIMIT 1;
  INSERT INTO Tokens (deviceId, devices_id) VALUES (deviceId_, id_);
END;;

CREATE TRIGGER `Last_seen_AFTER_UPDATE` AFTER UPDATE ON `Last_seen` FOR EACH ROW
BEGIN
  DECLARE deviceId_ char(255);
  SELECT deviceId INTO deviceId_ FROM Last_seen
    WHERE last_insert_id() = last_insert_id() ORDER BY Session_ DESC LIMIT 1;
  UPDATE Tokens SET Tokens.deviceId = deviceId_
    WHERE Tokens.deviceId = deviceId_;
END;;

CREATE TRIGGER `Tokens_BEFORE_INSERT` BEFORE INSERT ON `Tokens` FOR EACH ROW
BEGIN
  SET NEW.token1 = UUID();
  SET NEW.token2 = RAND();
END;;

CREATE TRIGGER `Tokens_BEFORE_UPDATE` BEFORE UPDATE ON `Tokens` FOR EACH ROW
BEGIN
  SET NEW.token1 = UUID();
  SET NEW.token2 = RAND();
END;;

DELIMITER ;


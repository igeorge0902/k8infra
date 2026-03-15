-- Fix stored procedures: replace login. references with login_.

USE login_;

-- Add profilePicture column if missing (expected by mbook Logins entity)
SET @col_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA='login_' AND TABLE_NAME='logins' AND COLUMN_NAME='profilePicture');
SET @stmt = IF(@col_exists = 0,
    'ALTER TABLE logins ADD COLUMN profilePicture VARCHAR(1024) DEFAULT NULL',
    'SELECT 1');
PREPARE _stmt FROM @stmt;
EXECUTE _stmt;
DEALLOCATE PREPARE _stmt;

DROP PROCEDURE IF EXISTS get_hash;
DROP PROCEDURE IF EXISTS activate_voucher;
DROP PROCEDURE IF EXISTS check_voucher;
DROP PROCEDURE IF EXISTS copy_token2;
DROP PROCEDURE IF EXISTS delete_user;
DROP PROCEDURE IF EXISTS find_email;
DROP PROCEDURE IF EXISTS find_email2;
DROP PROCEDURE IF EXISTS get_processing_voucher;
DROP PROCEDURE IF EXISTS get_voucher;
DROP PROCEDURE IF EXISTS register_voucher;
DROP PROCEDURE IF EXISTS reset_voucher;
DROP PROCEDURE IF EXISTS set_voucher;
DROP PROCEDURE IF EXISTS update_password;

DELIMITER ;;

CREATE PROCEDURE `get_hash`(IN hash_ char(255), IN user_ char(255))
BEGIN
  SELECT hash_ FROM login_.logins
  WHERE login_.logins.hash_ = hash_ AND login_.logins.user = user_;
END;;

CREATE PROCEDURE `activate_voucher`(IN user char(255))
BEGIN
  DECLARE activationCode char(255);
  SELECT activation_Token INTO activationCode FROM login_.voucher_states
    JOIN login_.vouchers ON vouchers.voucher_ = voucher_states.voucher_
    JOIN login_.logins ON logins.uuid = vouchers.uuid
    WHERE login_.logins.user = user;
  UPDATE login_.voucher_states
    SET login_.voucher_states.isActivated = 1,
        login_.voucher_states.toBeActivated = 0
    WHERE login_.voucher_states.activation_Token = activationCode;
END;;

CREATE PROCEDURE `check_voucher`(IN voucher_ char(255))
BEGIN
  SELECT voucher_ FROM login_.voucher_states
  WHERE login_.voucher_states.voucher_ = voucher_
    AND login_.voucher_states.state = 'registered';
END;;

CREATE PROCEDURE `copy_token2`(IN voucher_ char(255))
BEGIN
  DECLARE token2_ char(255);
  SELECT login_.Tokens.token2 INTO token2_
    FROM login_.devices
    JOIN login_.vouchers ON login_.devices.uuid = login_.vouchers.uuid
    JOIN login_.Tokens ON login_.Tokens.deviceId = login_.devices.deviceId
    JOIN login_.voucher_states ON login_.voucher_states.voucher_ = vouchers.voucher_
    WHERE login_.vouchers.voucher_ = voucher_
    ORDER BY login_.Tokens.TIME_ DESC LIMIT 1;
  UPDATE login_.voucher_states
    SET login_.voucher_states.activation_token = token2_
    WHERE login_.voucher_states.voucher_ = voucher_;
END;;

CREATE PROCEDURE `delete_user`(IN user_ char(255))
BEGIN
  DECLARE uuid_ char(255);
  DECLARE voucher char(255);
  SELECT uuid INTO uuid_ FROM logins WHERE logins.user = user_;
  SELECT login_.vouchers.voucher_ INTO voucher
    FROM login_.logins
    JOIN login_.vouchers ON login_.logins.uuid = login_.vouchers.uuid
    WHERE login_.vouchers.uuid = uuid_;
  UPDATE login_.voucher_states
    SET login_.voucher_states.state = 'free',
        login_.voucher_states.activation_token = null
    WHERE login_.voucher_states.voucher_ = voucher
      AND (login_.voucher_states.state = 'registered' OR login_.voucher_states.state = 'processing');
  DELETE FROM login_.logins WHERE login_.logins.uuid = uuid_;
  DELETE FROM login_.vouchers WHERE login_.vouchers.uuid = uuid_;
END;;

CREATE PROCEDURE `find_email`(IN email char(255))
BEGIN
  SELECT email FROM login_.logins WHERE login_.logins.email = email;
END;;

CREATE PROCEDURE `find_email2`(IN email char(255))
BEGIN
  DECLARE email_ char(255);
  SELECT email INTO email_ FROM login_.logins WHERE login_.logins.email = email;
  SELECT forgotRequestToken, forgotRequestTime FROM login_.forgotPsw
    WHERE login_.forgotPsw.forgotUserEmail = email_
      AND login_.forgotPsw.isValid = 1;
END;;

CREATE PROCEDURE `get_processing_voucher`(IN voucher_ char(255))
BEGIN
  SELECT voucher_ FROM login_.voucher_states
  WHERE login_.voucher_states.voucher_ = voucher_
    AND login_.voucher_states.state = 'processing';
END;;

CREATE PROCEDURE `get_voucher`(IN voucher_ char(255))
BEGIN
  SELECT voucher_ FROM login_.voucher_states
  WHERE login_.voucher_states.voucher_ = voucher_
    AND login_.voucher_states.state = 'free';
END;;

CREATE PROCEDURE `register_voucher`(IN voucher_ char(255))
BEGIN
  UPDATE login_.voucher_states
    SET login_.voucher_states.state = 'registered'
    WHERE login_.voucher_states.voucher_ = voucher_
      AND login_.voucher_states.state = 'processing';
END;;

CREATE PROCEDURE `reset_voucher`(IN voucher_ char(255), IN user_ char(255))
BEGIN
  UPDATE login_.voucher_states
    SET login_.voucher_states.state = 'free'
    WHERE login_.voucher_states.voucher_ = voucher_
      AND (login_.voucher_states.state = 'registered' OR login_.voucher_states.state = 'processing');
  DELETE FROM login_.logins WHERE login_.logins.user = user_;
  DELETE FROM login_.vouchers WHERE login_.vouchers.voucher_ = voucher_;
END;;

CREATE PROCEDURE `set_voucher`(IN voucher_ char(255))
BEGIN
  UPDATE login_.voucher_states
    SET login_.voucher_states.state = 'processing'
    WHERE login_.voucher_states.voucher_ = voucher_
      AND login_.voucher_states.state = 'free';
END;;

CREATE PROCEDURE `update_password`(IN pass_ char(255), IN email_ char(255))
BEGIN
  DECLARE id_ int;
  SELECT id INTO id_ FROM login_.logins WHERE login_.logins.email = email_;
  UPDATE login_.logins SET login_.logins.hash_ = pass_ WHERE login_.logins.id = id_;
  UPDATE login_.forgotPsw SET login_.forgotPsw.isValid = 0 WHERE login_.forgotPsw.forgotUserEmail = email_;
END;;

DELIMITER ;


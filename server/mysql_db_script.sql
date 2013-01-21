SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

CREATE SCHEMA IF NOT EXISTS `mydb` DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci ;
USE `mydb` ;

-- -----------------------------------------------------
-- Table `mydb`.`user_table`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`user_table` ;

CREATE  TABLE IF NOT EXISTS `mydb`.`user_table` (
  `iduser` INT NOT NULL AUTO_INCREMENT ,
  `auth_type` VARCHAR(10) NULL ,
  `last_login` DATETIME NULL ,
  `numtasks` INT NULL ,
  `authtoken` VARCHAR(100) NULL ,
  `num_freeleft` INT NULL ,
  PRIMARY KEY (`iduser`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`device_table`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`device_table` ;

CREATE  TABLE IF NOT EXISTS `mydb`.`device_table` (
  `iddevice` INT NOT NULL ,
  `device_id` VARCHAR(100) NULL ,
  `user_table_iduser` INT NOT NULL ,
  PRIMARY KEY (`iddevice`) ,
  INDEX `fk_device_table_user_table` (`user_table_iduser` ASC) ,
  CONSTRAINT `fk_device_table_user_table`
    FOREIGN KEY (`user_table_iduser` )
    REFERENCES `mydb`.`user_table` (`iduser` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`task_table`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`task_table` ;

CREATE  TABLE IF NOT EXISTS `mydb`.`task_table` (
  `idtask` INT NOT NULL AUTO_INCREMENT ,
  `image_url` VARCHAR(500) NULL ,
  `rating` INT NULL ,
  `submit_time` DATETIME NULL ,
  `notify_time` DATETIME NULL ,
  `device_table_iddevice` INT NOT NULL ,
  `unique_guid` VARCHAR(200) NULL ,
  PRIMARY KEY (`idtask`) ,
  INDEX `fk_task_table_device_table1` (`device_table_iddevice` ASC) ,
  UNIQUE INDEX `unique_guid_UNIQUE` (`unique_guid` ASC) ,
  CONSTRAINT `fk_task_table_device_table1`
    FOREIGN KEY (`device_table_iddevice` )
    REFERENCES `mydb`.`device_table` (`iddevice` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`assignment_table`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`assignment_table` ;

CREATE  TABLE IF NOT EXISTS `mydb`.`assignment_table` (
  `idassignment` INT NOT NULL AUTO_INCREMENT ,
  `service_task_id` VARCHAR(200) NULL ,
  `workforce` INT NULL ,
  `worker_id` VARCHAR(200) NULL ,
  `jobresult` TEXT NULL ,
  `submit_time` DATETIME NULL ,
  `completion_time` DATETIME NULL ,
  `cost` DECIMAL(5,2) NULL ,
  `task_table_idtask` INT NOT NULL ,
  PRIMARY KEY (`idassignment`) ,
  INDEX `fk_assignment_table_task_table1` (`task_table_idtask` ASC) ,
  CONSTRAINT `fk_assignment_table_task_table1`
    FOREIGN KEY (`task_table_idtask` )
    REFERENCES `mydb`.`task_table` (`idtask` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

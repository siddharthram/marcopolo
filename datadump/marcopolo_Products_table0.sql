CREATE DATABASE  IF NOT EXISTS `marcopolo` /*!40100 DEFAULT CHARACTER SET latin1 */;
USE `marcopolo`;
-- MySQL dump 10.13  Distrib 5.6.13, for Win32 (x86)
--
-- Host: aa1fj65y0wi38vu.couokv6egrzf.us-east-1.rds.amazonaws.com    Database: marcopolo
-- ------------------------------------------------------
-- Server version	5.5.27-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `Products_table`
--

DROP TABLE IF EXISTS `Products_table`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Products_table` (
  `idProducts` int(11) NOT NULL AUTO_INCREMENT,
  `appleProductId` varchar(100) DEFAULT NULL COMMENT 'unique id for this product at apple store',
  `description` varchar(1000) DEFAULT NULL COMMENT 'description of this product. This might be shown in app.',
  `price` decimal(6,3) NOT NULL,
  `imagesLeft` int(11) NOT NULL COMMENT 'column to store the number of tasks user gets when he/she buys this product',
  `active` int(11) NOT NULL DEFAULT '0' COMMENT '0 is enabled. -1 is disabled',
  PRIMARY KEY (`idProducts`),
  UNIQUE KEY `productId_UNIQUE` (`appleProductId`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Products_table`
--

LOCK TABLES `Products_table` WRITE;
/*!40000 ALTER TABLE `Products_table` DISABLE KEYS */;
INSERT INTO `Products_table` VALUES (1,'com.ximly.product.level1.01','5 pack',4.990,5,0),(2,'com.ximly.product.level2.01','20 pack',17.990,20,0),(3,'com.ximly.product.level3.01','100 pack',79.990,100,0);
/*!40000 ALTER TABLE `Products_table` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2014-04-02 20:21:21

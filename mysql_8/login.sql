CREATE DATABASE  IF NOT EXISTS `login_` /*!40100 DEFAULT CHARACTER SET utf8 */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `login_`;
-- MySQL dump 10.13  Distrib 8.0.26, for macos11 (x86_64)
--
-- Host: localhost    Database: login
-- ------------------------------------------------------
-- Server version	8.0.26

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `device_states`
--

DROP TABLE IF EXISTS `device_states`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `device_states` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `uuid` char(255) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
  `state` enum('logged_in','playing','logged_out','deleted') CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
  `SessionID` char(255) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
  `deviceId` char(255) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  `TIME_` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `devices_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `state` (`state`),
  KEY `deviceId` (`deviceId`),
  KEY `time` (`TIME_`),
  KEY `sessionID` (`SessionID`),
  KEY `fk_devices_idx` (`devices_id`),
  CONSTRAINT `fk_devices` FOREIGN KEY (`devices_id`) REFERENCES `devices` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=45 DEFAULT CHARSET=utf8mb3 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `device_states`
--

LOCK TABLES `device_states` WRITE;
/*!40000 ALTER TABLE `device_states` DISABLE KEYS */;
INSERT INTO `device_states` VALUES (1,'97c6fd76-ed90-11e9-871a-874ce8a992e2','logged_out','83A9238837B6468F64542650D6E9E2CA.worker1','A28A4152-3F11-44D0-A373-8795E51D47F4','2021-09-08 13:46:25',1),(2,'65f63602-6ddf-11e5-8441-71caa0c5f788','logged_out','P5g0pwGCYyM_YXDQ8YQS7pvpRVaobGfX7cv_vlnA','05014760511515148066737532','2021-10-23 17:56:32',2),(3,'65f63602-6ddf-11e5-8441-71caa0c5f788','logged_out','g9Svsdnr5Nt-yQliuWyDG6mLXN8_7wEFiPuw_RuP','rrczz97refub4x54xath7yqnrhsnam9fisnt','2021-10-09 18:15:39',3),(4,'65f63602-6ddf-11e5-8441-71caa0c5f788','logged_out','_688OnyprnQJsicU21ZEErDeY36xpxtWFjmmuhxY','xv7mirzwaf40c9updi4-0ytynhr5v50v2yt5','2021-10-09 19:53:17',4),(5,'65f63602-6ddf-11e5-8441-71caa0c5f788','logged_out','LkhO5YFupQ5hyOEzx7nJjz-RMJc1J-iAzIvK7tn9','wcugzd3g910913k2g11e9i20b3p1nbwy4r5h','2021-10-10 16:09:49',5),(6,'65f63602-6ddf-11e5-8441-71caa0c5f788','logged_out','DHXtYGqIYV9rG-WfbY60Lz-Zwyi11Sz-CRPxtvVR','3eaiqi36umdbhmm5xqb2i42qaqi85v0w9l4r','2021-10-10 16:14:45',6),(7,'65f63602-6ddf-11e5-8441-71caa0c5f788','logged_out','QUck52Q7l1xwp7ovZJmkIGrFzeNV3Oj999jg8cUS','o5cc307tnyxuiog2piozlcxyfbc2m9o1ewz4','2021-10-10 16:15:03',7),(8,'65f63602-6ddf-11e5-8441-71caa0c5f788','logged_out','Bc5Pztxli_hktsq3XOUAV7vy9ybgDsZyUfiCenEW','2501015753736940460671537365900144024','2021-10-10 16:43:39',8),(9,'65f63602-6ddf-11e5-8441-71caa0c5f788','logged_out','JGExtmB1zr-W5RD0vQECMMJ8edLYIkFtr8Gom4-M','ao3m6k5xoaky7fsqsxyqslmrtqal65vsdy-t','2021-10-10 18:10:44',9),(10,'65f63602-6ddf-11e5-8441-71caa0c5f788','logged_out','8CpUNdqT9KKSZMfVBgVf-9UR8dWaongSBiuZwWnu','m843srhm--apm3e3xltr180xv--nud74vfs3','2021-10-10 20:13:18',10),(11,'65f63602-6ddf-11e5-8441-71caa0c5f788','logged_out','XqdFSakZhK8gh0tkbCeP6Y6EOgloCOGfX2uKz-Dx','amim69r13apayl4bbq632v2-v6kqurrbyc29','2021-10-12 16:09:25',11),(12,'65f63602-6ddf-11e5-8441-71caa0c5f788','logged_out','c-E9DO0zzWCIn_HF1NXpPElni9auEDvFVAXwCXvn','exnae728ikvi0ro-6m7yzmznl00283xhiorl','2021-10-12 16:13:14',12),(13,'65f63602-6ddf-11e5-8441-71caa0c5f788','logged_out','I8Wrnc8zMyu2Erp-frGpgSwrEULivNMmqOmkkbFO','kgy343up5r9e7d2zbk5-a31vb2w3nwvsri0n','2021-10-12 16:15:59',13),(14,'65f63602-6ddf-11e5-8441-71caa0c5f788','logged_out','bpzr7s33YPrdZtfcZZC0hYe9cAbBDVafp2PRZV2d','tsq8q7967-k2u5yz9gi3blzhvo42qyotg0wm','2021-10-12 16:18:31',14),(15,'65f63602-6ddf-11e5-8441-71caa0c5f788','logged_out','3eML9_ab6oSQxnhOwnhtWEE9pCFvHIGUz0JJH_RJ','i43ed0ta8cspyxp6mcggxs75vrf9h4m3fcam','2021-10-12 16:37:02',15),(16,'65f63602-6ddf-11e5-8441-71caa0c5f788','logged_out','l47gpV7J0OtDdVq6AMb6QqGbEbe4zE5tdz0NRzrd','5onra7wno5h8mwqv76l-bxw4k58nulnznpw0','2021-10-12 16:37:22',16),(17,'65f63602-6ddf-11e5-8441-71caa0c5f788','logged_out','mDD9rHLK_jYI_0myzaG2RfvIYjzCilIP8UHEpAtI','088bxazsdy1yu3y6ysug9i5luqtpx-r67mdw','2021-10-12 16:38:20',17),(18,'65f63602-6ddf-11e5-8441-71caa0c5f788','logged_out','_86x0aXSShcMNoMEKUbMYdiie0ANDB__34RVXzv4','o-0ym2u37-mf6-bnw4saxrxi9mbteq1z5-f5','2021-10-12 16:42:27',18),(19,'65f63602-6ddf-11e5-8441-71caa0c5f788','logged_out','VXlrk4CpOkkFeS58gRnLfNulG45pppnXI16qQr1C','ood0h8gbt6xruz5odp868pyudu2qkbnyty5z','2021-10-12 16:43:21',19),(20,'65f63602-6ddf-11e5-8441-71caa0c5f788','logged_out','cReun1IWJatWusWLXB2McVGtZiqQhSayRqXJUUkz','c581afsuh2sy2z3b6p-dcllwqsk9typzw-bu','2021-10-12 16:44:34',20),(21,'65f63602-6ddf-11e5-8441-71caa0c5f788','logged_out','Uxvbcw9J4qUaeM0nxb95ZxJOs7VGFUcGF8Rtqj15','g-crbsa6suwn4yn2t6od30fkczaxv8lq7b8p','2021-10-12 16:57:12',21),(22,'65f63602-6ddf-11e5-8441-71caa0c5f788','logged_out','rojFtHve00H648kaXntNR2jffSDug5waFy0DAPg9','m91mplnwp07m-fhd9p1qd-rtmg5dccbi2dxz','2021-10-12 17:45:09',22),(23,'65f63602-6ddf-11e5-8441-71caa0c5f788','logged_out','rBNgPCVFEgSA28Q6Qfooytvt4nqi3prt6PQicEuZ','a1hnt9ia651buutbh2xu7fphlor1xnd-scsn','2021-10-12 18:52:41',23),(24,'65f63602-6ddf-11e5-8441-71caa0c5f788','logged_out','cmrV_yfW0edi8oEwe1UeuknWq4AE_HBHl2-amOhm','thhdy9xz6w7f-i6mwg1d4z1bkv5pspnzxk1u','2021-10-12 18:52:42',24),(25,'65f63602-6ddf-11e5-8441-71caa0c5f788','logged_out','VDkCdHBANb4hdd5AfGJIZiTQ2kK2w4RaJd-ignas','r32eo0e9elvhc-u6uagwy6ey1dxenit9hxir','2021-10-12 18:53:32',25),(26,'65f63602-6ddf-11e5-8441-71caa0c5f788','logged_out','4GcWkaM7y74jH9HUtq22We80S6jxnvwuocAT2oTT','kqpt901gmqr1zh7u9hcha9fsom8qw4t-otzx','2021-10-12 19:01:17',26),(27,'65f63602-6ddf-11e5-8441-71caa0c5f788','logged_out','u8WUrNyMdIRuw8dX_bmDwy85JVErT-afpr5CwcD5','n2ctih9eolg32ffvlzdn6d0tzzl8pvh1kimw','2021-10-12 19:01:18',27),(28,'65f63602-6ddf-11e5-8441-71caa0c5f788','logged_out','_KmUQQE-KjQlbn_0OxVj3zb9IdJ94bnVtoNT0PPo','crydq71b5n4wwrl23s5bfw7csy73461ylayf','2021-10-12 19:14:16',28),(29,'65f63602-6ddf-11e5-8441-71caa0c5f788','logged_out','VvegM0mb6hu6RNkj1DoV4CQC4mj9GDwmqAuPw7UZ','pmevuldv9tqwvgp71h0a2-5r41ey2nv9arg7','2021-10-12 19:14:17',29),(30,'65f63602-6ddf-11e5-8441-71caa0c5f788','logged_out','jYbrIWnwXvHCBbqfS4UxYA3QVS9PGDTAmG3ivNgX','-zqf-vd9728fu7c02dkr6vq-m5c0h-77bki9','2021-10-12 19:17:41',30),(31,'65f63602-6ddf-11e5-8441-71caa0c5f788','logged_out','gvIaIhxMeLGpWKQuZXvrleOQY39ctVM0igoDIjtZ','yu0to-gc8m89cuhvvzefsbf2tb397hwz-6u-','2021-10-12 19:36:11',31),(32,'65f63602-6ddf-11e5-8441-71caa0c5f788','logged_out','vLnNozak0rhhTEaX9maZEeVXkYNyNP1i1U1mBTTj','b2qs290kfpx8v6c9yaeokwzo1adyakxkb-6y','2021-10-12 20:45:40',32),(33,'65f63602-6ddf-11e5-8441-71caa0c5f788','logged_out','mKz-iRYe8ujHyBCDlBnwtnAFT_e93eSeByX6TA-i','oaop6iwd6c20zv914afifaelw6z-slmbtolx','2021-10-13 00:46:20',33),(34,'65f63602-6ddf-11e5-8441-71caa0c5f788','logged_out','yZnKz5_s0F5Sn38pG6cqgiMFM9PF9Q3_yrfz5_E1','ooo1glz042o9hnn32yt2ui1m32z8zbbd4p6-','2021-10-13 07:45:21',34),(35,'65f63602-6ddf-11e5-8441-71caa0c5f788','logged_out','HXtys9Q2nXxhbFJU-5qMJ6ypWDsyfJgCoHvjg7tk','y5mhq6t2eko7d75wlrbtlslkqvqxpex4zg4z','2021-10-13 09:28:48',35),(36,'65f63602-6ddf-11e5-8441-71caa0c5f788','logged_out','sXrYZ9dnwAZxXZX4y1kJ33DIour7Ux42nnVySme5','05015060511515148081237532','2021-10-17 10:29:34',36),(37,'65f63602-6ddf-11e5-8441-71caa0c5f788','logged_out','g_8ClpwlNe2Ex3fnItF3pyaU-j9zQv_aH12KSQG6','12345678','2021-10-21 13:28:01',37),(38,'65f63602-6ddf-11e5-8441-71caa0c5f788','logged_out','NXDTONlIqjFxr0hpVBojEqh8vmdiYgxjaKxxidhE','25010157537369604664110537365900144024','2021-12-24 12:02:18',38),(39,'65f63602-6ddf-11e5-8441-71caa0c5f788','logged_out','iE9o3ykxPvUgD46y82YJ-qGfm05_VxcV_r0WKl97','05015260511515148081237532','2022-11-23 10:34:15',39),(40,'65f63602-6ddf-11e5-8441-71caa0c5f788','logged_out','EW3zWkpWuLF8Jj_iEu7J1nUwOrIFR6KzwJOEncuH','2501015753736105000537365900144024','2022-09-21 09:18:47',40),(41,'65f63602-6ddf-11e5-8441-71caa0c5f788','logged_out','eBcBDZv959PLg25COPL7c7FfG8YL8nGq_w_wGyca','F5758198-49E6-4FE9-99E8-F43B14D56058','2022-11-27 19:09:24',41),(42,'65f63602-6ddf-11e5-8441-71caa0c5f788','logged_out','EgX_rmoJv7MWB3L0gHOOKkd5pgcAMdzTLHk06iCZ','250101576051151616051151982151224','2022-12-12 07:07:36',42),(43,'65f63602-6ddf-11e5-8441-71caa0c5f788','logged_in','-XPghDtLqnWIJjtOKj2t2ATRe4wsL4oxsKwUKIM6','E194BD96-7F89-4992-B0A6-C461E7284007','2022-12-13 11:26:17',43),(44,'65f63602-6ddf-11e5-8441-71caa0c5f788','logged_out','N1v7tOFMZcXy1aO13v1fbR00QyWxFA3ZyPbhUUZR','05016160511515148081237532','2022-12-13 11:42:47',44);
/*!40000 ALTER TABLE `device_states` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `devices`
--

DROP TABLE IF EXISTS `devices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `devices` (
  `id` int NOT NULL AUTO_INCREMENT,
  `deviceId` char(255) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
  `uuid` char(255) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
  `TIME_` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `uuid` (`uuid`)
) ENGINE=InnoDB AUTO_INCREMENT=45 DEFAULT CHARSET=utf8mb3 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `devices`
--

LOCK TABLES `devices` WRITE;
/*!40000 ALTER TABLE `devices` DISABLE KEYS */;
INSERT INTO `devices` VALUES (1,'A28A4152-3F11-44D0-A373-8795E51D47F4','97c6fd76-ed90-11e9-871a-874ce8a992e2','2021-09-08 13:14:54'),(2,'05014760511515148066737532','65f63602-6ddf-11e5-8441-71caa0c5f788','2021-10-07 20:18:44'),(3,'rrczz97refub4x54xath7yqnrhsnam9fisnt','65f63602-6ddf-11e5-8441-71caa0c5f788','2021-10-09 18:15:37'),(4,'xv7mirzwaf40c9updi4-0ytynhr5v50v2yt5','65f63602-6ddf-11e5-8441-71caa0c5f788','2021-10-09 19:53:15'),(5,'wcugzd3g910913k2g11e9i20b3p1nbwy4r5h','65f63602-6ddf-11e5-8441-71caa0c5f788','2021-10-09 20:56:03'),(6,'3eaiqi36umdbhmm5xqb2i42qaqi85v0w9l4r','65f63602-6ddf-11e5-8441-71caa0c5f788','2021-10-09 21:00:59'),(7,'o5cc307tnyxuiog2piozlcxyfbc2m9o1ewz4','65f63602-6ddf-11e5-8441-71caa0c5f788','2021-10-09 21:01:17'),(8,'2501015753736940460671537365900144024','65f63602-6ddf-11e5-8441-71caa0c5f788','2021-10-10 16:11:45'),(9,'ao3m6k5xoaky7fsqsxyqslmrtqal65vsdy-t','65f63602-6ddf-11e5-8441-71caa0c5f788','2021-10-10 16:43:35'),(10,'m843srhm--apm3e3xltr180xv--nud74vfs3','65f63602-6ddf-11e5-8441-71caa0c5f788','2021-10-10 19:43:18'),(11,'amim69r13apayl4bbq632v2-v6kqurrbyc29','65f63602-6ddf-11e5-8441-71caa0c5f788','2021-10-12 15:39:25'),(12,'exnae728ikvi0ro-6m7yzmznl00283xhiorl','65f63602-6ddf-11e5-8441-71caa0c5f788','2021-10-12 15:43:14'),(13,'kgy343up5r9e7d2zbk5-a31vb2w3nwvsri0n','65f63602-6ddf-11e5-8441-71caa0c5f788','2021-10-12 15:45:58'),(14,'tsq8q7967-k2u5yz9gi3blzhvo42qyotg0wm','65f63602-6ddf-11e5-8441-71caa0c5f788','2021-10-12 15:48:30'),(15,'i43ed0ta8cspyxp6mcggxs75vrf9h4m3fcam','65f63602-6ddf-11e5-8441-71caa0c5f788','2021-10-12 16:07:02'),(16,'5onra7wno5h8mwqv76l-bxw4k58nulnznpw0','65f63602-6ddf-11e5-8441-71caa0c5f788','2021-10-12 16:07:22'),(17,'088bxazsdy1yu3y6ysug9i5luqtpx-r67mdw','65f63602-6ddf-11e5-8441-71caa0c5f788','2021-10-12 16:08:19'),(18,'o-0ym2u37-mf6-bnw4saxrxi9mbteq1z5-f5','65f63602-6ddf-11e5-8441-71caa0c5f788','2021-10-12 16:12:26'),(19,'ood0h8gbt6xruz5odp868pyudu2qkbnyty5z','65f63602-6ddf-11e5-8441-71caa0c5f788','2021-10-12 16:13:20'),(20,'c581afsuh2sy2z3b6p-dcllwqsk9typzw-bu','65f63602-6ddf-11e5-8441-71caa0c5f788','2021-10-12 16:14:33'),(21,'g-crbsa6suwn4yn2t6od30fkczaxv8lq7b8p','65f63602-6ddf-11e5-8441-71caa0c5f788','2021-10-12 16:27:12'),(22,'m91mplnwp07m-fhd9p1qd-rtmg5dccbi2dxz','65f63602-6ddf-11e5-8441-71caa0c5f788','2021-10-12 17:15:08'),(23,'a1hnt9ia651buutbh2xu7fphlor1xnd-scsn','65f63602-6ddf-11e5-8441-71caa0c5f788','2021-10-12 17:22:27'),(24,'thhdy9xz6w7f-i6mwg1d4z1bkv5pspnzxk1u','65f63602-6ddf-11e5-8441-71caa0c5f788','2021-10-12 17:22:28'),(25,'r32eo0e9elvhc-u6uagwy6ey1dxenit9hxir','65f63602-6ddf-11e5-8441-71caa0c5f788','2021-10-12 17:23:17'),(26,'kqpt901gmqr1zh7u9hcha9fsom8qw4t-otzx','65f63602-6ddf-11e5-8441-71caa0c5f788','2021-10-12 17:31:02'),(27,'n2ctih9eolg32ffvlzdn6d0tzzl8pvh1kimw','65f63602-6ddf-11e5-8441-71caa0c5f788','2021-10-12 17:31:03'),(28,'crydq71b5n4wwrl23s5bfw7csy73461ylayf','65f63602-6ddf-11e5-8441-71caa0c5f788','2021-10-12 17:44:02'),(29,'pmevuldv9tqwvgp71h0a2-5r41ey2nv9arg7','65f63602-6ddf-11e5-8441-71caa0c5f788','2021-10-12 17:44:03'),(30,'-zqf-vd9728fu7c02dkr6vq-m5c0h-77bki9','65f63602-6ddf-11e5-8441-71caa0c5f788','2021-10-12 17:47:26'),(31,'yu0to-gc8m89cuhvvzefsbf2tb397hwz-6u-','65f63602-6ddf-11e5-8441-71caa0c5f788','2021-10-12 19:06:11'),(32,'b2qs290kfpx8v6c9yaeokwzo1adyakxkb-6y','65f63602-6ddf-11e5-8441-71caa0c5f788','2021-10-12 19:16:15'),(33,'oaop6iwd6c20zv914afifaelw6z-slmbtolx','65f63602-6ddf-11e5-8441-71caa0c5f788','2021-10-12 19:17:28'),(34,'ooo1glz042o9hnn32yt2ui1m32z8zbbd4p6-','65f63602-6ddf-11e5-8441-71caa0c5f788','2021-10-12 19:19:12'),(35,'y5mhq6t2eko7d75wlrbtlslkqvqxpex4zg4z','65f63602-6ddf-11e5-8441-71caa0c5f788','2021-10-12 19:25:48'),(36,'05015060511515148081237532','65f63602-6ddf-11e5-8441-71caa0c5f788','2021-10-16 16:43:54'),(37,'12345678','65f63602-6ddf-11e5-8441-71caa0c5f788','2021-10-21 11:37:04'),(38,'25010157537369604664110537365900144024','65f63602-6ddf-11e5-8441-71caa0c5f788','2021-12-23 14:40:07'),(39,'05015260511515148081237532','65f63602-6ddf-11e5-8441-71caa0c5f788','2022-02-20 14:07:04'),(40,'2501015753736105000537365900144024','65f63602-6ddf-11e5-8441-71caa0c5f788','2022-09-21 07:22:48'),(41,'F5758198-49E6-4FE9-99E8-F43B14D56058','65f63602-6ddf-11e5-8441-71caa0c5f788','2022-09-21 09:05:02'),(42,'250101576051151616051151982151224','65f63602-6ddf-11e5-8441-71caa0c5f788','2022-12-11 21:43:09'),(43,'E194BD96-7F89-4992-B0A6-C461E7284007','65f63602-6ddf-11e5-8441-71caa0c5f788','2022-12-12 07:07:46'),(44,'05016160511515148081237532','65f63602-6ddf-11e5-8441-71caa0c5f788','2022-12-13 08:56:19');
/*!40000 ALTER TABLE `devices` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`sqluser`@`%`*/ /*!50003 TRIGGER `deviceId_uuid` AFTER INSERT ON `devices` FOR EACH ROW BEGIN
	   DECLARE Id_ char(255);
       DECLARE deviceId_ char(255);
       DECLARE uuid_ char(255);
	   select id, deviceId, uuid into Id_, deviceId_, uuid_ from devices where last_insert_id() = last_insert_id() ORDER by ID DESC LIMIT 1;

  INSERT INTO device_states (deviceId, state, uuid, devices_id) values (deviceId_, 'logged_in', uuid_, Id_);
  
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `forgotPsw`
--

DROP TABLE IF EXISTS `forgotPsw`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `forgotPsw` (
  `id` int NOT NULL AUTO_INCREMENT,
  `forgotUserEmail` char(255) NOT NULL,
  `forgotRequestToken` char(255) DEFAULT NULL,
  `forgotRequestTime` char(255) DEFAULT NULL,
  `isValid` tinyint(1) DEFAULT NULL,
  `TIME_` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `forgotUserEmail_UNIQUE` (`forgotUserEmail`),
  UNIQUE KEY `forgotRequestToken_UNIQUE` (`forgotRequestToken`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `forgotPsw`
--

LOCK TABLES `forgotPsw` WRITE;
/*!40000 ALTER TABLE `forgotPsw` DISABLE KEYS */;
INSERT INTO `forgotPsw` VALUES (1,'ga@ga.com','0.20107192378590993','1491772273707',0,'2017-04-09 21:11:23'),(2,'gi@gi.com','0.8017910614626399','1490129614313',0,'2017-03-21 20:55:32'),(3,'igeorge1982@gmail.com','0.465508008809302','1620060210506',0,'2021-05-03 16:46:24');
/*!40000 ALTER TABLE `forgotPsw` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`%`*/ /*!50003 TRIGGER `forgotPsw_BEFORE_INSERT` BEFORE INSERT ON `forgotpsw` FOR EACH ROW BEGIN
	SET NEW.forgotRequestToken = RAND();
    SET NEW.isValid = 1;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`%`*/ /*!50003 TRIGGER `forgotPsw_BEFORE_UPDATE` BEFORE UPDATE ON `forgotpsw` FOR EACH ROW BEGIN
	SET NEW.forgotRequestToken = RAND();
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `Last_seen`
--

DROP TABLE IF EXISTS `Last_seen`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Last_seen` (
  `id` int NOT NULL AUTO_INCREMENT,
  `deviceId` char(255) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL DEFAULT '0000',
  `Session_` mediumtext CHARACTER SET utf8 COLLATE utf8_bin,
  `TIME_` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `devices_id` int DEFAULT NULL,
  PRIMARY KEY (`id`,`deviceId`),
  KEY `deviceId` (`deviceId`),
  KEY `fk_devices_idx` (`devices_id`),
  CONSTRAINT `fk_devices2` FOREIGN KEY (`devices_id`) REFERENCES `devices` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=45 DEFAULT CHARSET=utf8mb3 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Last_seen`
--

LOCK TABLES `Last_seen` WRITE;
/*!40000 ALTER TABLE `Last_seen` DISABLE KEYS */;
INSERT INTO `Last_seen` VALUES (1,'A28A4152-3F11-44D0-A373-8795E51D47F4','1631106894317','2021-09-08 13:14:54',1),(2,'05014760511515148066737532','1635009989555','2021-10-23 17:26:29',2),(3,'rrczz97refub4x54xath7yqnrhsnam9fisnt','1633803337124','2021-10-09 18:15:37',3),(4,'xv7mirzwaf40c9updi4-0ytynhr5v50v2yt5','1633809195937','2021-10-09 19:53:15',4),(5,'wcugzd3g910913k2g11e9i20b3p1nbwy4r5h','1633812963729','2021-10-09 20:56:03',5),(6,'3eaiqi36umdbhmm5xqb2i42qaqi85v0w9l4r','1633813259905','2021-10-09 21:00:59',6),(7,'o5cc307tnyxuiog2piozlcxyfbc2m9o1ewz4','1633813277687','2021-10-09 21:01:17',7),(8,'2501015753736940460671537365900144024','1633882305043','2021-10-10 16:11:45',8),(9,'ao3m6k5xoaky7fsqsxyqslmrtqal65vsdy-t','1633884215454','2021-10-10 16:43:35',9),(10,'m843srhm--apm3e3xltr180xv--nud74vfs3','1633894998208','2021-10-10 19:43:18',10),(11,'amim69r13apayl4bbq632v2-v6kqurrbyc29','1634053165069','2021-10-12 15:39:25',11),(12,'exnae728ikvi0ro-6m7yzmznl00283xhiorl','1634053394083','2021-10-12 15:43:14',12),(13,'kgy343up5r9e7d2zbk5-a31vb2w3nwvsri0n','1634053558653','2021-10-12 15:45:58',13),(14,'tsq8q7967-k2u5yz9gi3blzhvo42qyotg0wm','1634053710744','2021-10-12 15:48:30',14),(15,'i43ed0ta8cspyxp6mcggxs75vrf9h4m3fcam','1634054822005','2021-10-12 16:07:02',15),(16,'5onra7wno5h8mwqv76l-bxw4k58nulnznpw0','1634054842049','2021-10-12 16:07:22',16),(17,'088bxazsdy1yu3y6ysug9i5luqtpx-r67mdw','1634054899794','2021-10-12 16:08:19',17),(18,'o-0ym2u37-mf6-bnw4saxrxi9mbteq1z5-f5','1634055146845','2021-10-12 16:12:26',18),(19,'ood0h8gbt6xruz5odp868pyudu2qkbnyty5z','1634055200423','2021-10-12 16:13:20',19),(20,'c581afsuh2sy2z3b6p-dcllwqsk9typzw-bu','1634055273967','2021-10-12 16:14:33',20),(21,'g-crbsa6suwn4yn2t6od30fkczaxv8lq7b8p','1634056032356','2021-10-12 16:27:12',21),(22,'m91mplnwp07m-fhd9p1qd-rtmg5dccbi2dxz','1634058908507','2021-10-12 17:15:08',22),(23,'a1hnt9ia651buutbh2xu7fphlor1xnd-scsn','1634059347677','2021-10-12 17:22:27',23),(24,'thhdy9xz6w7f-i6mwg1d4z1bkv5pspnzxk1u','1634059348723','2021-10-12 17:22:28',24),(25,'r32eo0e9elvhc-u6uagwy6ey1dxenit9hxir','1634059397958','2021-10-12 17:23:17',25),(26,'kqpt901gmqr1zh7u9hcha9fsom8qw4t-otzx','1634059862857','2021-10-12 17:31:02',26),(27,'n2ctih9eolg32ffvlzdn6d0tzzl8pvh1kimw','1634059863782','2021-10-12 17:31:03',27),(28,'crydq71b5n4wwrl23s5bfw7csy73461ylayf','1634060642245','2021-10-12 17:44:02',28),(29,'pmevuldv9tqwvgp71h0a2-5r41ey2nv9arg7','1634060643187','2021-10-12 17:44:03',29),(30,'-zqf-vd9728fu7c02dkr6vq-m5c0h-77bki9','1634060846734','2021-10-12 17:47:26',30),(31,'yu0to-gc8m89cuhvvzefsbf2tb397hwz-6u-','1634065571261','2021-10-12 19:06:11',31),(32,'b2qs290kfpx8v6c9yaeokwzo1adyakxkb-6y','1634066175704','2021-10-12 19:16:15',32),(33,'oaop6iwd6c20zv914afifaelw6z-slmbtolx','1634066247992','2021-10-12 19:17:28',33),(34,'ooo1glz042o9hnn32yt2ui1m32z8zbbd4p6-','1634066352196','2021-10-12 19:19:12',34),(35,'y5mhq6t2eko7d75wlrbtlslkqvqxpex4zg4z','1634066748363','2021-10-12 19:25:48',35),(36,'05015060511515148081237532','1634464770748','2021-10-17 09:59:30',36),(37,'12345678','1634821081387','2021-10-21 12:58:01',37),(38,'25010157537369604664110537365900144024','1640270407023','2021-12-23 14:40:07',38),(39,'05015260511515148081237532','1669197844204','2022-11-23 10:04:04',39),(40,'2501015753736105000537365900144024','1663750127281','2022-09-21 08:48:47',40),(41,'F5758198-49E6-4FE9-99E8-F43B14D56058','1669574364173','2022-11-27 18:39:24',41),(42,'250101576051151616051151982151224','1670794989850','2022-12-11 21:43:09',42),(43,'E194BD96-7F89-4992-B0A6-C461E7284007','1670930777254','2022-12-13 11:26:17',43),(44,'05016160511515148081237532','1670929859492','2022-12-13 11:10:59',44);
/*!40000 ALTER TABLE `Last_seen` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`%`*/ /*!50003 TRIGGER `tokens` AFTER INSERT ON `last_seen` FOR EACH ROW BEGIN
       DECLARE deviceId_ char(255);
       declare id_ char(255);
	   select id, deviceId into id_, deviceId_ from Last_seen where last_insert_id() = last_insert_id() ORDER by ID DESC LIMIT 1;
  
  INSERT INTO Tokens (deviceId, devices_id) values (deviceId_, id_);

  
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`%`*/ /*!50003 TRIGGER `Last_seen_AFTER_UPDATE` AFTER UPDATE ON `last_seen` FOR EACH ROW BEGIN

       DECLARE deviceId_ char(255);
	   select deviceId into deviceId_ from Last_seen where last_insert_id() = last_insert_id() ORDER by Session_ DESC LIMIT 1;
  
  UPDATE Tokens 
  SET Tokens.deviceId = deviceId_ where Tokens.deviceId = deviceId_;

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `logins`
--

DROP TABLE IF EXISTS `logins`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `logins` (
  `id` int NOT NULL AUTO_INCREMENT,
  `hash_` char(255) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `user` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
  `uuid` char(255) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
  `email` char(255) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
  `TIME_` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `profilePicture` varchar(1024) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email_UNIQUE` (`email`),
  UNIQUE KEY `uuid` (`uuid`),
  UNIQUE KEY `user_UNIQUE` (`user`),
  KEY `user` (`user`),
  KEY `hash_` (`hash_`),
  FULLTEXT KEY `user_2` (`user`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb3 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `logins`
--

LOCK TABLES `logins` WRITE;
/*!40000 ALTER TABLE `logins` DISABLE KEYS */;
INSERT INTO `logins` (`id`, `hash_`, `user`, `uuid`, `email`, `TIME_`) VALUES (2,'52fa80662e64c128f8389c9ea6c73d4c02368004bf4463491900d11aaadca39d47de1b01361f207c512cfa79f0f92c3395c67ff7928e3f5ce3e3c852b392f976','GI','97c6fd76-ed90-11e9-871a-874ce8a992e2','ildiko.gaspar.911@gmail.com','2019-10-13 08:09:41'),(5,'52fa80662e64c128f8389c9ea6c73d4c02368004bf4463491900d11aaadca39d47de1b01361f207c512cfa79f0f92c3395c67ff7928e3f5ce3e3c852b392f976','Milo','f73b72c4-1071-11ea-9359-551258859352','igeorge1982@yahoo.com','2019-11-26 17:27:05'),(9,'318672fb86ed60eb2a230a782d53f93c243d199f6f6972fee17a0ce8591ec803f0abf83335b2777b1c44792f98cf66567109c843a1c0deaa2a26b85825ca5ee7','GG','65f63602-6ddf-11e5-8441-71caa0c5f788','igeorge1982@gmail.com','2021-05-03 16:46:24'),(10,'52fa80662e64c128f8389c9ea6c73d4c02368004bf4463491900d11aaadca39d47de1b01361f207c512cfa79f0f92c3395c67ff7928e3f5ce3e3c852b392f976','Georgie','a169e3e2-a8cb-11ea-8911-07c8d9e7f826','igeorge0902@hotmail.com','2020-09-24 14:39:01'),(11,'52fa80662e64c128f8389c9ea6c73d4c02368004bf4463491900d11aaadca39d47de1b01361f207c512cfa79f0f92c3395c67ff7928e3f5ce3e3c852b392f976','Lilla','d686f5da-fe73-11ea-9233-14886e8c76ac','igeorge1982@hotmail.com','2020-09-24 14:40:06');
/*!40000 ALTER TABLE `logins` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`%`*/ /*!50003 TRIGGER `insert_guid` BEFORE INSERT ON `logins` FOR EACH ROW BEGIN 
    SET NEW.uuid = UUID();
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`%`*/ /*!50003 TRIGGER `vouchers` AFTER INSERT ON `logins` FOR EACH ROW BEGIN
       DECLARE uuid_ char(255);
	   select uuid into uuid_ from logins where last_insert_id() = last_insert_id() ORDER by ID DESC LIMIT 1;

  INSERT INTO vouchers
     (uuid) values (uuid_);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `Tokens`
--

DROP TABLE IF EXISTS `Tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Tokens` (
  `id` int NOT NULL AUTO_INCREMENT,
  `deviceId` char(255) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
  `token1` char(255) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
  `token2` char(255) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
  `TIME_` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `devices_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `token1` (`token1`),
  UNIQUE KEY `token2` (`token2`),
  KEY `token2_2` (`token2`),
  KEY `fk_devices3_idx` (`devices_id`),
  CONSTRAINT `fk_devices3` FOREIGN KEY (`devices_id`) REFERENCES `devices` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=45 DEFAULT CHARSET=utf8mb3 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Tokens`
--

LOCK TABLES `Tokens` WRITE;
/*!40000 ALTER TABLE `Tokens` DISABLE KEYS */;
INSERT INTO `Tokens` VALUES (1,'A28A4152-3F11-44D0-A373-8795E51D47F4','292d86c4-10ab-11ec-87cb-7d1d182368a0','0.7173129932184825','2021-09-08 13:46:25',1),(2,'05014760511515148066737532','8e52d3ae-342a-11ec-969d-b5090c259373','0.8171357659782617','2021-10-23 17:56:32',2),(3,'rrczz97refub4x54xath7yqnrhsnam9fisnt','e81b1242-292c-11ec-bfca-b1a31eab030a','0.042694563085860164','2021-10-09 18:15:39',3),(4,'xv7mirzwaf40c9updi4-0ytynhr5v50v2yt5','8bc04d10-293a-11ec-bfca-b1a31eab030a','0.15214010435355838','2021-10-09 19:53:17',4),(5,'wcugzd3g910913k2g11e9i20b3p1nbwy4r5h','7e914e1e-29e4-11ec-bfca-b1a31eab030a','0.7646648229702048','2021-10-10 16:09:49',5),(6,'3eaiqi36umdbhmm5xqb2i42qaqi85v0w9l4r','2ef46868-29e5-11ec-bfca-b1a31eab030a','0.11893213923921077','2021-10-10 16:14:45',6),(7,'o5cc307tnyxuiog2piozlcxyfbc2m9o1ewz4','398d3d4a-29e5-11ec-bfca-b1a31eab030a','0.12804426451031517','2021-10-10 16:15:03',7),(8,'2501015753736940460671537365900144024','389d8e40-29e9-11ec-bfca-b1a31eab030a','0.9942542491427196','2021-10-10 16:43:39',8),(9,'ao3m6k5xoaky7fsqsxyqslmrtqal65vsdy-t','62d0e3e0-29f5-11ec-bfca-b1a31eab030a','0.7144842461817751','2021-10-10 18:10:44',9),(10,'m843srhm--apm3e3xltr180xv--nud74vfs3','828a87ac-2a06-11ec-bfca-b1a31eab030a','0.6582614422387084','2021-10-10 20:13:18',10),(11,'amim69r13apayl4bbq632v2-v6kqurrbyc29','c52daf46-2b76-11ec-bfca-b1a31eab030a','0.26793297218897655','2021-10-12 16:09:25',11),(12,'exnae728ikvi0ro-6m7yzmznl00283xhiorl','4daf4f1e-2b77-11ec-bfca-b1a31eab030a','0.41634159201415405','2021-10-12 16:13:14',12),(13,'kgy343up5r9e7d2zbk5-a31vb2w3nwvsri0n','afc5928a-2b77-11ec-bfca-b1a31eab030a','0.6619211590494226','2021-10-12 16:15:59',13),(14,'tsq8q7967-k2u5yz9gi3blzhvo42qyotg0wm','0a6dcbc6-2b78-11ec-bfca-b1a31eab030a','0.418208163621098','2021-10-12 16:18:31',14),(15,'i43ed0ta8cspyxp6mcggxs75vrf9h4m3fcam','a0c9f4ee-2b7a-11ec-bfca-b1a31eab030a','0.6698005894849083','2021-10-12 16:37:02',15),(16,'5onra7wno5h8mwqv76l-bxw4k58nulnznpw0','acbbee1a-2b7a-11ec-bfca-b1a31eab030a','0.08598555911889817','2021-10-12 16:37:22',16),(17,'088bxazsdy1yu3y6ysug9i5luqtpx-r67mdw','cf380348-2b7a-11ec-bfca-b1a31eab030a','0.8887620008445922','2021-10-12 16:38:20',17),(18,'o-0ym2u37-mf6-bnw4saxrxi9mbteq1z5-f5','62680e9c-2b7b-11ec-bfca-b1a31eab030a','0.11263164981513438','2021-10-12 16:42:27',18),(19,'ood0h8gbt6xruz5odp868pyudu2qkbnyty5z','8264fb42-2b7b-11ec-bfca-b1a31eab030a','0.3280865366832228','2021-10-12 16:43:21',19),(20,'c581afsuh2sy2z3b6p-dcllwqsk9typzw-bu','ae2dd5e6-2b7b-11ec-bfca-b1a31eab030a','0.5498040072152428','2021-10-12 16:44:34',20),(21,'g-crbsa6suwn4yn2t6od30fkczaxv8lq7b8p','7243ed02-2b7d-11ec-bfca-b1a31eab030a','0.5880635823943313','2021-10-12 16:57:12',21),(22,'m91mplnwp07m-fhd9p1qd-rtmg5dccbi2dxz','249071d2-2b84-11ec-bfca-b1a31eab030a','0.7027174920800305','2021-10-12 17:45:09',22),(23,'a1hnt9ia651buutbh2xu7fphlor1xnd-scsn','94445864-2b8d-11ec-bfca-b1a31eab030a','0.8048537707001472','2021-10-12 18:52:41',23),(24,'thhdy9xz6w7f-i6mwg1d4z1bkv5pspnzxk1u','94e3d66e-2b8d-11ec-bfca-b1a31eab030a','0.2748472199541025','2021-10-12 18:52:42',24),(25,'r32eo0e9elvhc-u6uagwy6ey1dxenit9hxir','b23c7626-2b8d-11ec-bfca-b1a31eab030a','0.20195412747743924','2021-10-12 18:53:32',25),(26,'kqpt901gmqr1zh7u9hcha9fsom8qw4t-otzx','c7569662-2b8e-11ec-bfca-b1a31eab030a','0.32703446906715117','2021-10-12 19:01:17',26),(27,'n2ctih9eolg32ffvlzdn6d0tzzl8pvh1kimw','c7e38b8a-2b8e-11ec-bfca-b1a31eab030a','0.9298567780571587','2021-10-12 19:01:18',27),(28,'crydq71b5n4wwrl23s5bfw7csy73461ylayf','97e5106e-2b90-11ec-bfca-b1a31eab030a','0.10121173234769304','2021-10-12 19:14:16',28),(29,'pmevuldv9tqwvgp71h0a2-5r41ey2nv9arg7','987399e2-2b90-11ec-bfca-b1a31eab030a','0.5807238803996927','2021-10-12 19:14:17',29),(30,'-zqf-vd9728fu7c02dkr6vq-m5c0h-77bki9','11c638f4-2b91-11ec-bfca-b1a31eab030a','0.504618617244641','2021-10-12 19:17:41',30),(31,'yu0to-gc8m89cuhvvzefsbf2tb397hwz-6u-','a7db53e0-2b93-11ec-bfca-b1a31eab030a','0.04510711789606802','2021-10-12 19:36:11',31),(32,'b2qs290kfpx8v6c9yaeokwzo1adyakxkb-6y','5c59f840-2b9d-11ec-bfca-b1a31eab030a','0.7715303774657942','2021-10-12 20:45:40',32),(33,'oaop6iwd6c20zv914afifaelw6z-slmbtolx','fb73f130-2bbe-11ec-bfca-b1a31eab030a','0.7383023088223323','2021-10-13 00:46:20',33),(34,'ooo1glz042o9hnn32yt2ui1m32z8zbbd4p6-','84d23a24-2bf9-11ec-bfca-b1a31eab030a','0.1662910433172165','2021-10-13 07:45:21',34),(35,'y5mhq6t2eko7d75wlrbtlslkqvqxpex4zg4z','f861abe2-2c07-11ec-bfca-b1a31eab030a','0.25877552224209116','2021-10-13 09:28:48',35),(36,'05015060511515148081237532','1eee3e94-2f35-11ec-bfca-b1a31eab030a','0.8322698388549218','2021-10-17 10:29:34',36),(37,'12345678','b6f9125a-3272-11ec-969d-b5090c259373','0.9327848022177674','2021-10-21 13:28:01',37),(38,'25010157537369604664110537365900144024','57b724dc-64b1-11ec-8542-fd9d1db7411f','0.5673642638766805','2021-12-24 12:02:18',38),(39,'05015260511515148081237532','60a751e6-6b1a-11ed-a257-b44d630800e8','0.3732454184193587','2022-11-23 10:34:15',39),(40,'2501015753736105000537365900144024','66077ca0-398e-11ed-8ad7-c2ee61195b7f','0.3049466659361','2022-09-21 09:18:47',40),(41,'F5758198-49E6-4FE9-99E8-F43B14D56058','01cdfdf8-6e87-11ed-a257-b44d630800e8','0.7648165326237832','2022-11-27 19:09:24',41),(42,'250101576051151616051151982151224','a7f48afc-79eb-11ed-b232-9d80a8cafe97','0.14253093874317682','2022-12-12 07:07:36',42),(43,'E194BD96-7F89-4992-B0A6-C461E7284007','f5c5a58e-7ad8-11ed-b232-9d80a8cafe97','0.8011343458677962','2022-12-13 09:58:32',43),(44,'05016160511515148081237532','43e21368-7adb-11ed-b232-9d80a8cafe97','0.41403447037007146','2022-12-13 11:42:47',44);
/*!40000 ALTER TABLE `Tokens` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`%`*/ /*!50003 TRIGGER `Tokens_BEFORE_INSERT` BEFORE INSERT ON `tokens` FOR EACH ROW BEGIN
    SET NEW.token1 = UUID();
	SET NEW.token2 = RAND();
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`%`*/ /*!50003 TRIGGER `Tokens_BEFORE_UPDATE` BEFORE UPDATE ON `tokens` FOR EACH ROW BEGIN
    SET NEW.token1 = UUID();
    SET NEW.token2 = RAND();
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Temporary view structure for view `user_on_devices`
--

DROP TABLE IF EXISTS `user_on_devices`;
/*!50001 DROP VIEW IF EXISTS `user_on_devices`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `user_on_devices` AS SELECT 
 1 AS `user`,
 1 AS `uuid`,
 1 AS `email`,
 1 AS `voucher`,
 1 AS `deviceId`,
 1 AS `state`,
 1 AS `sessionID`,
 1 AS `Time`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `voucher_states`
--

DROP TABLE IF EXISTS `voucher_states`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `voucher_states` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `state` enum('free','processing','registered','expired') DEFAULT NULL,
  `voucher_` char(255) DEFAULT NULL,
  `duration_in_seconds` int unsigned DEFAULT NULL,
  `toBeActivated` tinyint(1) DEFAULT NULL,
  `isActivated` tinyint(1) NOT NULL,
  `TIME_` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `activation_token` char(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `voucher_` (`voucher_`),
  KEY `state` (`state`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `voucher_states`
--

LOCK TABLES `voucher_states` WRITE;
/*!40000 ALTER TABLE `voucher_states` DISABLE KEYS */;
INSERT INTO `voucher_states` VALUES (8,'registered','12345',NULL,0,1,'2020-06-07 14:31:52','0.5890404531630132'),(9,'registered','12346',NULL,0,1,'2019-10-13 08:08:08','0.21622941476873067'),(10,'free','12347',NULL,0,1,'2020-05-08 00:36:25',''),(11,'registered','12348',NULL,0,1,'2019-12-14 17:34:51','0.1513986430609586'),(12,'free','12349',NULL,0,1,'2019-03-05 00:04:28',NULL),(13,'free','12350',NULL,0,1,'2019-03-05 00:04:28',NULL),(14,'free','12351',NULL,0,1,'2019-03-05 00:04:28',NULL),(15,'registered','12352',NULL,1,0,'2019-11-26 17:27:05','0.3084171948101532'),(16,'registered','12353',NULL,0,1,'2020-12-18 12:10:02','0.955926410812816'),(17,'free','12354',NULL,1,0,'2019-03-05 00:04:28',''),(18,'free','12355',NULL,1,0,'2019-03-05 00:04:28',''),(19,'free','12356',NULL,1,0,'2019-03-05 00:04:28',''),(20,'free','12357',NULL,0,1,'2017-03-21 13:22:48',NULL);
/*!40000 ALTER TABLE `voucher_states` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vouchers`
--

DROP TABLE IF EXISTS `vouchers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vouchers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `voucherUuid` char(255) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  `voucher_` char(255) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  `uuid` char(255) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
  `TIME_` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uuid` (`uuid`),
  UNIQUE KEY `voucherUuid_UNIQUE` (`voucherUuid`),
  UNIQUE KEY `voucher__UNIQUE` (`voucher_`),
  KEY `uuid_2` (`uuid`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb3 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vouchers`
--

LOCK TABLES `vouchers` WRITE;
/*!40000 ALTER TABLE `vouchers` DISABLE KEYS */;
INSERT INTO `vouchers` VALUES (9,'97c76dc4-ed90-11e9-871a-874ce8a992e2','12346','97c6fd76-ed90-11e9-871a-874ce8a992e2','2019-10-13 08:08:08'),(12,'f73b7e0e-1071-11ea-9359-551258859352','12352','f73b72c4-1071-11ea-9359-551258859352','2019-11-26 17:27:05'),(14,'65f63602-6ddf-11e5-8441-71caa0c5f788','12349','65f63602-6ddf-11e5-8441-71caa0c5f788','2020-05-08 09:45:54'),(15,'a16aa5a2-a8cb-11ea-8911-07c8d9e7f826','12345','a169e3e2-a8cb-11ea-8911-07c8d9e7f826','2020-06-07 14:31:52'),(16,'d687839c-fe73-11ea-9233-14886e8c76ac','12353','d686f5da-fe73-11ea-9233-14886e8c76ac','2020-09-24 14:40:06');
/*!40000 ALTER TABLE `vouchers` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`%`*/ /*!50003 TRIGGER `insert_voucher` BEFORE INSERT ON `vouchers` FOR EACH ROW BEGIN 
    SET NEW.voucherUuid = UUID();
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Dumping routines for database 'login'
--
/*!50003 DROP PROCEDURE IF EXISTS `activate_voucher` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`sqluser`@`%` PROCEDURE `activate_voucher`(IN activationCode char(255), IN user char(255))
BEGIN

declare activationCode char(255);

select activation_Token into activationCode from login_.voucher_states
join login_.vouchers on vouchers.voucher_ = voucher_states.voucher_
join login_.logins on vouchers.uuid = logins.uuid
where login_.logins.user = user;

update login_.voucher_states 
set login_.voucher_states.isActivated = 1,
login_.voucher_states.toBeActivated = 0
where login_.voucher_states.activation_Token = activationCode;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `check_voucher` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`sqluser`@`%` PROCEDURE `check_voucher`(IN voucher_ char(255))
BEGIN
select voucher_ 
from login_.voucher_states
where login_.voucher_states.voucher_ = voucher_
AND login_.voucher_states.state = 'registered';
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `copy_token2` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`sqluser`@`%` PROCEDURE `copy_token2`(IN voucher_ char(255))
BEGIN

declare token2_ char(255);

select login_.Tokens.token2 
into token2_
from login_.devices
join login_.vouchers on login_.devices.uuid = login_.vouchers.uuid
join login_.Tokens on login_.Tokens.deviceId = login_.devices.deviceId
join login_.voucher_states on login_.voucher_states.voucher_ = vouchers.voucher_
where login_.vouchers.voucher_ = voucher_ 
order by login_.Tokens.TIME_ desc limit 1;

update login_.voucher_states 
set login_.voucher_states.activation_token = token2_
where login_.voucher_states.voucher_ = voucher_;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `delete_user` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`sqluser`@`%` PROCEDURE `delete_user`(IN user_ char(255))
BEGIN

declare uuid_ char(255);
declare voucher char(255);

select uuid into uuid_ from logins where logins.user = user_;

select login_.vouchers.voucher_ into voucher
from login_.logins
join login_.vouchers on login_.logins.uuid = login_.vouchers.uuid
where login_.vouchers.uuid = uuid_;


UPDATE login_.voucher_states 
SET login_.voucher_states.state ='free',
login_.voucher_states.activation_token=null 
WHERE login_.voucher_states.voucher_ = voucher 
AND login_.voucher_states.state = 'registered' or login_.voucher_states.state = 'processing';

delete from login_.logins where login_.logins.uuid = uuid_;
delete from login_.vouchers where login_.vouchers.uuid = uuid_;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `find_email` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`sqluser`@`%` PROCEDURE `find_email`(IN email char(255))
BEGIN
select email from login_.logins where login_.logins.email = email;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `find_email2` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`sqluser`@`%` PROCEDURE `find_email2`(IN email char(255))
BEGIN

declare email_ char(255);

select email into email_ from login_.logins where login_.logins.email = email;

select forgotRequestToken, forgotRequestTime from login_.forgotPsw 
where login_.forgotPsw.forgotUserEmail = email_ 
and login_.forgotPsw.isValid = 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `forgot_password` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`sqluser`@`%` PROCEDURE `forgot_password`(IN email char(255), IN time char(255))
BEGIN

declare forgotRequestToken_ char(255);
declare id_ int(11);

select id, forgotRequestToken into id_, forgotRequestToken_ from forgotPsw where forgotUserEmail = email;

if forgotRequestToken_ is null then

insert into forgotPsw (forgotUserEmail, forgotRequestTime) values (email, time);

else

update forgotPsw 
set forgotPsw.forgotUserEmail = email, forgotPsw.forgotRequestTime = time, forgotPsw.isValid = 1
where id = id_;

end if;

select forgotRequestToken from forgotPsw where forgotUserEmail = email;


END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_activation_vocher` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`sqluser`@`%` PROCEDURE `get_activation_vocher`(IN user char(255))
BEGIN

select voucher_states.activation_token, logins.email from voucher_states 
join vouchers on vouchers.voucher_ = voucher_states.voucher_
join logins on vouchers.uuid = logins.uuid
where logins.user = user;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_hash` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`sqluser`@`%` PROCEDURE `get_hash`(IN hash_ char(255), IN user_ char(255))
BEGIN
select hash_ 
from login_.logins
where login_.logins.hash_ = hash_ and
login_.logins.user = user_;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_processing_voucher` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`sqluser`@`%` PROCEDURE `get_processing_voucher`(IN voucher_ char(255))
BEGIN
select voucher_ 
from login_.voucher_states
where login_.voucher_states.voucher_ = voucher_
AND login_.voucher_states.state = 'processing';
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_token` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`sqluser`@`%` PROCEDURE `get_token`(IN deviceId_ char (255))
BEGIN
select token1 from Tokens where deviceId = deviceId_ order by TIME_ desc LIMIT 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_token2` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`sqluser`@`%` PROCEDURE `get_token2`(IN deviceId_ char (255))
BEGIN
select Tokens.token2, Last_seen.Session_ from Tokens join Last_seen on Tokens.deviceId = Last_seen.deviceId where Tokens.deviceId = deviceId_ order by Tokens.TIME_ desc LIMIT 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_uuid` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`sqluser`@`%` PROCEDURE `get_uuid`(IN user_ char (255))
BEGIN
select uuid from logins where user = user_;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_voucher` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`sqluser`@`%` PROCEDURE `get_voucher`(IN voucher_ char(255))
BEGIN
select voucher_ 
from login_.voucher_states
where login_.voucher_states.voucher_ = voucher_
AND login_.voucher_states.state = 'free';
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `insert_device` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`sqluser`@`%` PROCEDURE `insert_device`(IN deviceId_ char(255), IN user_ varchar(255))
BEGIN

declare uuid_ char(255);

select uuid into uuid_ from logins
where logins.user = user_ ;


insert into devices (deviceId, uuid) values (deviceId_,uuid_);

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `insert_device_` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`sqluser`@`%` PROCEDURE `insert_device_`(IN deviceId_ char(255), IN user_ varchar(255))
BEGIN

declare uuid_ char(255);
declare devices_ char(255);
#declare id_ int(11);
#declare idS_ int(11);

select uuid into uuid_ from logins
where logins.user = user_ ;

#join devices with logins table to check device for user
#select id into id_ from devices_states where deviceId = deviceId_;
select deviceId into devices_ from devices where devices.deviceId = deviceId_ and devices.uuid = uuid_;

if deviceId_ != devices_ or devices_ is null then
insert into devices (deviceId, uuid) values (deviceId_,uuid_);

else

update device_states 
set device_states.state = 'logged_in' 
where device_states.deviceId = deviceId_
and device_states.uuid = uuid_;

end if;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `insert_sessionCreated` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`sqluser`@`%` PROCEDURE `insert_sessionCreated`(IN deviceId_ char(255), IN sessionCreated_ long, IN sessionID_ char(255))
BEGIN

declare devices_ char(255);
declare id_ int(11);
declare idS_ int(11);

select id, deviceId into id_, devices_ from Last_seen where deviceId = deviceId_;
select id into idS_ from device_states where deviceId = deviceId_ order by TIME_ desc LIMIT 1;

if deviceId_ != devices_ or devices_ is null then

insert into Last_seen (deviceId, Session_, devices_id) values (deviceId_,sessionCreated_, idS_);
update device_states set SessionID = sessionID_ where device_states.deviceId = deviceId_ and device_states.id = idS_;

else 

update Last_seen 
set Last_seen.Session_ = sessionCreated_ 
where Last_seen.deviceId = deviceId_ and Last_seen.id= id_;

update device_states set SessionID = sessionID_ 
where device_states.deviceId = deviceId_ and device_states.id = idS_;

end if;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `insert_voucher` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`sqluser`@`%` PROCEDURE `insert_voucher`(IN voucher char(255), IN user_ varchar(255), IN pass char(255))
BEGIN

declare uuid_ char(255);

select uuid into uuid_ from logins
where logins.user = user_ and logins.hash_ = pass;

update vouchers 
join logins on vouchers.uuid = logins.uuid
set vouchers.voucher_ = voucher
where vouchers.uuid = uuid_;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `isActivated` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`sqluser`@`%` PROCEDURE `isActivated`(IN user_ varchar(255))
BEGIN

select a.isActivated AS state 
from voucher_states a 
left join  vouchers b on a.voucher_ = b.voucher_ 
left join logins c on c.uuid = b.uuid
where c.user = user_;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `logout_device` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`sqluser`@`%` PROCEDURE `logout_device`(IN sessionID_ char(255))
BEGIN
	
    declare deviceId_ char(255);

	update device_states 
	set device_states.state = 'logged_out' 
	where device_states.sessionID = sessionID_;
    
    select deviceId into deviceId_ from device_states
	where device_states.sessionID = sessionID_;
    
    ##comment out if it causes issues in TomCat cluster env
    update Tokens
    set Tokens.token1 = 0 and Tokens.token2 = 0 
	where Tokens.deviceId = deviceId_;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `register_voucher` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`sqluser`@`%` PROCEDURE `register_voucher`(IN voucher_ char(255))
BEGIN
UPDATE login_.voucher_states 
SET login_.voucher_states.state ='registered' 
WHERE login_.voucher_states.voucher_ = voucher_ 
AND login_.voucher_states.state = 'processing';
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `reset_voucher` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`sqluser`@`%` PROCEDURE `reset_voucher`(IN voucher_ char(255), IN user_ varchar(255))
BEGIN
UPDATE login_.voucher_states 
SET login_.voucher_states.state ='free'
WHERE login_.voucher_states.voucher_ = voucher_ 
AND login_.voucher_states.state = 'registered' or login_.voucher_states.state = 'processing';

DELETE FROM login_.logins WHERE login_.logins.user = user_;
DELETE FROM login_.vouchers WHERE login_.vouchers.voucher_ = voucher_;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `set_voucher` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`sqluser`@`%` PROCEDURE `set_voucher`(IN voucher_ char(255))
BEGIN
UPDATE login_.voucher_states 
SET login_.voucher_states.state ='processing' 
WHERE login_.voucher_states.voucher_ = voucher_ 
AND login_.voucher_states.state = 'free';
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `update_password` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`sqluser`@`%` PROCEDURE `update_password`(IN pass_ char(255), IN email_ char(255))
BEGIN

declare id_ int(11);

select id into id_ from login_.logins where login_.logins.email = email_;

update login_.logins 
set login_.logins.hash_ = pass_ 
where login_.logins.id = id_;

update login_.forgotPsw 
set login_.forgotPsw.isValid = 0 
where login_.forgotPsw.forgotUserEmail = email_;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Final view structure for view `user_on_devices`
--

/*!50001 DROP VIEW IF EXISTS `user_on_devices`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `user_on_devices` AS select `logins`.`user` AS `user`,`logins`.`uuid` AS `uuid`,`logins`.`email` AS `email`,`vouchers`.`voucher_` AS `voucher`,`device_states`.`deviceId` AS `deviceId`,`device_states`.`state` AS `state`,`device_states`.`SessionID` AS `sessionID`,`device_states`.`TIME_` AS `Time` from ((`logins` join `vouchers` on((`logins`.`uuid` = `vouchers`.`uuid`))) join `device_states` on((`logins`.`uuid` = `device_states`.`uuid`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2022-12-14  9:38:22

DROP DATABASE IF EXISTS `cfboom_test`;

CREATE DATABASE `cfboom_test` /*!40100 DEFAULT CHARACTER SET utf8mb4 */;

USE `cfboom_test`;

--
-- Table structure for table `All_Types`
--

DROP TABLE IF EXISTS `All_Types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `All_Types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `blob` blob,
  `binary` binary(3) DEFAULT NULL,
  `longblob` longblob,
  `mediumblob` mediumblob,
  `tinyblob` tinyblob,
  `varbinary` varbinary(3) DEFAULT NULL,
  `date` date DEFAULT NULL,
  `datetime` datetime DEFAULT NULL,
  `time` time DEFAULT NULL,
  `timestamp` timestamp NULL DEFAULT NULL,
  `year` year(4) DEFAULT NULL,
  `bigint` bigint(20) DEFAULT NULL,
  `decimal` decimal(5,2) DEFAULT NULL,
  `double` double DEFAULT NULL,
  `float` float DEFAULT NULL,
  `int` int(11) DEFAULT NULL,
  `mediumint` mediumint(9) DEFAULT NULL,
  `real` double DEFAULT NULL,
  `smallint` smallint(6) DEFAULT NULL,
  `tinyint` tinyint(4) DEFAULT NULL,
  `char` char(1) DEFAULT NULL,
  `nvarchar` varchar(3) CHARACTER SET utf8 DEFAULT NULL,
  `varchar` varchar(45) DEFAULT NULL,
  `longtext` longtext,
  `mediumtext` mediumtext,
  `text` text,
  `tinytext` tinytext,
  `bit` bit(1) DEFAULT NULL,
  `enum` enum('A','B') DEFAULT NULL,
  `set` set('A','B') DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `All_Types`
--

LOCK TABLES `All_Types` WRITE;
/*!40000 ALTER TABLE `All_Types` DISABLE KEYS */;
INSERT INTO `All_Types` VALUES (1,'lkjsfodijfs','uud','oiwueroi','uybbvyrbv','plokmjn','okq','2016-09-17','2016-09-18 05:02:31','22:56:10','2016-09-18 05:02:31',2016,8746373827474374,23.47,192.338,3.22228,1277383,238732,2327.28394832,1232,127,'a','def','d','     This has leading and trailing spaces        ','asdflkj','asdflkj','asdflkj',b'0','A','B'),(2,'oiwueroi','8y5','mnxvmnb','ygcuvsdjhsjhds','qaxscdwd','0c3','2016-09-18','2016-09-18 05:04:20','21:33:10','2016-09-18 05:04:20',2016,874677327474374,62.53,98.1255,4.27874,8798762,12345,234.1837463,7927,12,'f','jir','d','lkjasd','asdflkj','asdflkj','asdflkj',b'1','A','B'),(3,NULL,NULL,NULL,NULL,NULL,NULL,'2016-09-20',NULL,NULL,NULL,2016,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'b',NULL,NULL,NULL,NULL,NULL,NULL,b'0','B','A');
/*!40000 ALTER TABLE `All_Types` ENABLE KEYS */;
UNLOCK TABLES;

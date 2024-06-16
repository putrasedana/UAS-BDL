-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jun 16, 2024 at 04:09 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `restaurant_reservation_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `customer`
--

CREATE TABLE `customer` (
  `customer_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `phone_number` varchar(15) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Stand-in structure for view `customers_with_multiple_reservations`
-- (See below for the actual view)
--
CREATE TABLE `customers_with_multiple_reservations` (
`customer_id` int(11)
,`customer_name` varchar(100)
,`total_reservations` bigint(21)
);

-- --------------------------------------------------------

--
-- Table structure for table `payment`
--

CREATE TABLE `payment` (
  `payment_id` int(11) NOT NULL,
  `reservation_id` int(11) DEFAULT NULL,
  `payment_date` date NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `payment_method` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Triggers `payment`
--
DELIMITER $$
CREATE TRIGGER `update_total_payments_after_insert` AFTER INSERT ON `payment` FOR EACH ROW BEGIN
    DECLARE total DECIMAL(10, 2);
    
    SELECT SUM(amount) INTO total
    FROM payment
    WHERE reservation_id = NEW.reservation_id;
    
    UPDATE reservation
    SET total_payment = total
    WHERE reservation_id = NEW.reservation_id;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `reservation`
--

CREATE TABLE `reservation` (
  `reservation_id` int(11) NOT NULL,
  `customer_id` int(11) DEFAULT NULL,
  `restaurant_id` int(11) DEFAULT NULL,
  `table_id` int(11) DEFAULT NULL,
  `reservation_date` date NOT NULL,
  `reservation_time` time NOT NULL,
  `number_of_people` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Triggers `reservation`
--
DELIMITER $$
CREATE TRIGGER `update_table_capacity_after_reservation` AFTER INSERT ON `reservation` FOR EACH ROW BEGIN
    UPDATE restaurant_table
    SET capacity = capacity - NEW.number_of_people
    WHERE table_id = NEW.table_id;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `reservation_details`
-- (See below for the actual view)
--
CREATE TABLE `reservation_details` (
`reservation_id` int(11)
,`customer_name` varchar(100)
,`customer_email` varchar(100)
,`restaurant_name` varchar(100)
,`table_number` int(11)
,`reservation_date` date
,`reservation_time` time
,`number_of_people` int(11)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `reservation_payment_details`
-- (See below for the actual view)
--
CREATE TABLE `reservation_payment_details` (
`reservation_id` int(11)
,`customer_name` varchar(100)
,`restaurant_name` varchar(100)
,`table_number` int(11)
,`reservation_date` date
,`reservation_time` time
,`number_of_people` int(11)
,`total_payment` decimal(32,2)
);

-- --------------------------------------------------------

--
-- Table structure for table `restaurant`
--

CREATE TABLE `restaurant` (
  `restaurant_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `address` varchar(255) NOT NULL,
  `phone_number` varchar(15) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `restaurant_table`
--

CREATE TABLE `restaurant_table` (
  `table_id` int(11) NOT NULL,
  `restaurant_id` int(11) DEFAULT NULL,
  `table_number` int(11) NOT NULL,
  `capacity` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure for view `customers_with_multiple_reservations`
--
DROP TABLE IF EXISTS `customers_with_multiple_reservations`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `customers_with_multiple_reservations`  AS SELECT `c`.`customer_id` AS `customer_id`, `c`.`name` AS `customer_name`, count(`r`.`reservation_id`) AS `total_reservations` FROM (`customer` `c` left join `reservation` `r` on(`c`.`customer_id` = `r`.`customer_id`)) WHERE `c`.`name` like '%John%' GROUP BY `c`.`customer_id`, `c`.`name` HAVING count(`r`.`reservation_id`) > 1 ;

-- --------------------------------------------------------

--
-- Structure for view `reservation_details`
--
DROP TABLE IF EXISTS `reservation_details`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `reservation_details`  AS SELECT `r`.`reservation_id` AS `reservation_id`, `c`.`name` AS `customer_name`, `c`.`email` AS `customer_email`, `rest`.`name` AS `restaurant_name`, `rt`.`table_number` AS `table_number`, `r`.`reservation_date` AS `reservation_date`, `r`.`reservation_time` AS `reservation_time`, `r`.`number_of_people` AS `number_of_people` FROM (((`reservation` `r` join `customer` `c` on(`r`.`customer_id` = `c`.`customer_id`)) join `restaurant` `rest` on(`r`.`restaurant_id` = `rest`.`restaurant_id`)) join `restaurant_table` `rt` on(`r`.`table_id` = `rt`.`table_id`)) ;

-- --------------------------------------------------------

--
-- Structure for view `reservation_payment_details`
--
DROP TABLE IF EXISTS `reservation_payment_details`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `reservation_payment_details`  AS SELECT `r`.`reservation_id` AS `reservation_id`, `c`.`name` AS `customer_name`, `rest`.`name` AS `restaurant_name`, `rt`.`table_number` AS `table_number`, `r`.`reservation_date` AS `reservation_date`, `r`.`reservation_time` AS `reservation_time`, `r`.`number_of_people` AS `number_of_people`, `p`.`total_payment` AS `total_payment` FROM ((((`reservation` `r` join `customer` `c` on(`r`.`customer_id` = `c`.`customer_id`)) join `restaurant` `rest` on(`r`.`restaurant_id` = `rest`.`restaurant_id`)) join `restaurant_table` `rt` on(`r`.`table_id` = `rt`.`table_id`)) left join (select `payment`.`reservation_id` AS `reservation_id`,sum(`payment`.`amount`) AS `total_payment` from `payment` group by `payment`.`reservation_id`) `p` on(`r`.`reservation_id` = `p`.`reservation_id`)) ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `customer`
--
ALTER TABLE `customer`
  ADD PRIMARY KEY (`customer_id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `idx_customer_name` (`name`),
  ADD KEY `idx_customer_id` (`customer_id`);

--
-- Indexes for table `payment`
--
ALTER TABLE `payment`
  ADD PRIMARY KEY (`payment_id`),
  ADD KEY `idx_payment_reservation_id` (`reservation_id`);

--
-- Indexes for table `reservation`
--
ALTER TABLE `reservation`
  ADD PRIMARY KEY (`reservation_id`),
  ADD KEY `restaurant_id` (`restaurant_id`),
  ADD KEY `table_id` (`table_id`),
  ADD KEY `idx_reservation_customer_id` (`customer_id`),
  ADD KEY `idx_reservation_date` (`reservation_date`),
  ADD KEY `idx_reservation_time` (`reservation_time`);

--
-- Indexes for table `restaurant`
--
ALTER TABLE `restaurant`
  ADD PRIMARY KEY (`restaurant_id`),
  ADD KEY `idx_restaurant_id` (`restaurant_id`);

--
-- Indexes for table `restaurant_table`
--
ALTER TABLE `restaurant_table`
  ADD PRIMARY KEY (`table_id`),
  ADD KEY `restaurant_id` (`restaurant_id`),
  ADD KEY `idx_table_id` (`table_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `customer`
--
ALTER TABLE `customer`
  MODIFY `customer_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `payment`
--
ALTER TABLE `payment`
  MODIFY `payment_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `reservation`
--
ALTER TABLE `reservation`
  MODIFY `reservation_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `restaurant`
--
ALTER TABLE `restaurant`
  MODIFY `restaurant_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `restaurant_table`
--
ALTER TABLE `restaurant_table`
  MODIFY `table_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `payment`
--
ALTER TABLE `payment`
  ADD CONSTRAINT `payment_ibfk_1` FOREIGN KEY (`reservation_id`) REFERENCES `reservation` (`reservation_id`);

--
-- Constraints for table `reservation`
--
ALTER TABLE `reservation`
  ADD CONSTRAINT `reservation_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`),
  ADD CONSTRAINT `reservation_ibfk_2` FOREIGN KEY (`restaurant_id`) REFERENCES `restaurant` (`restaurant_id`),
  ADD CONSTRAINT `reservation_ibfk_3` FOREIGN KEY (`table_id`) REFERENCES `restaurant_table` (`table_id`);

--
-- Constraints for table `restaurant_table`
--
ALTER TABLE `restaurant_table`
  ADD CONSTRAINT `restaurant_table_ibfk_1` FOREIGN KEY (`restaurant_id`) REFERENCES `restaurant` (`restaurant_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

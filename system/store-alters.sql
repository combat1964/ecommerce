-- version: 2.1.0
-- version: 2.1.1
ALTER TABLE `shopping_cart_session` ADD COLUMN `discount_tax_rate` enum('0','1', '2', '3') COLLATE utf8_unicode_ci DEFAULT '0' AFTER `gateway`;
ALTER TABLE `shopping_cart_session` ADD COLUMN `shipping_tax` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT 'Shipping Tax' AFTER `sub_total`;
ALTER TABLE `shopping_cart_session` ADD COLUMN `discount_tax` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT 'Discount Tax' AFTER `shipping_tax`;
ALTER TABLE `shopping_cart_session` ADD COLUMN `sub_total_tax` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT 'Sub total Tax' AFTER `discount_tax`;
ALTER TABLE `shopping_quote` ADD COLUMN `creator_id` int(10) unsigned DEFAULT '0' AFTER `edited_by`;
-- version: 2.1.2
-- version: 2.2.0
CREATE TABLE IF NOT EXISTS `shopping_filtering_attributes` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Attribute ID',
  `name` varchar(200) COLLATE utf8_unicode_ci NOT NULL COMMENT 'Attribute Name',
  `label` tinytext COLLATE utf8_unicode_ci NOT NULL COMMENT 'Attribute Label',
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE IF NOT EXISTS  `shopping_filtering_widget_settings` (
  `filter_id` varchar(32) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL COMMENT 'Filter ID',
  `settings` text CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL COMMENT 'Widget Settings',
  PRIMARY KEY (`filter_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE IF NOT EXISTS  `shopping_filtering_tags_has_attributes` (
  `tag_id` int(10) unsigned NOT NULL,
  `attribute_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`tag_id`,`attribute_id`),
  KEY `attribute_id` (`attribute_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE IF NOT EXISTS `shopping_filtering_values` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `product_id` int(10) unsigned NOT NULL COMMENT 'Product ID',
  `attribute_id` int(10) unsigned NOT NULL COMMENT 'Attribute ID',
  `value` tinytext COLLATE utf8_unicode_ci NOT NULL COMMENT 'Attribute Value',
  PRIMARY KEY (`id`),
  KEY `attribute_id` (`attribute_id`),
  KEY `product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
-- version: 2.2.1
ALTER TABLE `shopping_quote` ADD COLUMN `internal_note` text COLLATE utf8_unicode_ci AFTER `disclaimer`;
-- version: 2.2.2
CREATE TABLE IF NOT EXISTS `shopping_import_orders` (
  `real_order_id` int(10) unsigned NOT NULL,
  `import_order_id` VARCHAR(255) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`real_order_id`,`import_order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
-- version: 2.2.3
ALTER TABLE `shopping_filtering_values` ADD UNIQUE (`attribute_id`, `product_id`);
-- version: 2.3.0
CREATE TABLE IF NOT EXISTS `shopping_pickup_location_category` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(200) COLLATE utf8_unicode_ci NOT NULL,
  `img` varchar(300) COLLATE utf8_unicode_ci NULL,
  `external_category` varchar(200) COLLATE utf8_unicode_ci NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
CREATE TABLE IF NOT EXISTS `shopping_pickup_location` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `address1` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `address2` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT NULL,
  `zip` varchar(10) COLLATE utf8_unicode_ci NOT NULL,
  `country` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `city` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `working_hours` TEXT COLLATE utf8_unicode_ci NOT NULL,
  `phone` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `location_category_id` int(10) unsigned NOT NULL,
  `lat` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `lng` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `notes` text 	COLLATE utf8_unicode_ci DEFAULT NULL,
  `weight` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  INDEX `country` (`country`),
  INDEX `city` (`city`),
  INDEX `country_city` (`city`, `country`),
  FOREIGN KEY (`location_category_id`)
        REFERENCES `shopping_pickup_location_category`(`id`)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
CREATE TABLE IF NOT EXISTS `shopping_pickup_location_config` (
  `id` int(10) unsigned NOT NULL,
  `amount_type_limit` enum('up to','over','eachover') COLLATE utf8_unicode_ci DEFAULT NULL,
  `amount_limit` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
CREATE TABLE IF NOT EXISTS `shopping_pickup_location_zones` (
  `config_id` int(10) unsigned NOT NULL,
  `pickup_location_category_id` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `amount_location_category` decimal(10,2) DEFAULT NULL,
  `config_zone_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`config_id`, `config_zone_id`),
  FOREIGN KEY (`config_id`)
        REFERENCES `shopping_pickup_location_config`(`id`)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
CREATE TABLE IF NOT EXISTS `shopping_pickup_location_cart` (
  `cart_id` int(10) unsigned NOT NULL,
  `name` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `address1` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `address2` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT NULL,
  `zip` varchar(10) COLLATE utf8_unicode_ci NOT NULL,
  `country` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `city` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `working_hours` TEXT COLLATE utf8_unicode_ci NOT NULL,
  `phone` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `location_category_id` int(10) unsigned NOT NULL,
  `lat` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `lng` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`cart_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
UPDATE `template_type` SET `title` = 'Checkout' WHERE `id` = 'typecheckout';
UPDATE `template_type` SET `title` = 'Product' WHERE `id` = 'typeproduct';
ALTER TABLE `shopping_customer_address` ADD `mobilecountrycode` VARCHAR( 2 ) NULL DEFAULT NULL COMMENT 'Contains mobile phone country code';
INSERT INTO `plugin` (`name`, `status`, `tags`, `version`) VALUES ('toastauth', 1, '', '2.2.0');
INSERT INTO `plugin` (`name`, `status`, `tags`, `version`) VALUES ('delivery', 1, '', '2.2.0');
DROP TABLE IF EXISTS `plugin_toastauth_settings`;
CREATE TABLE `plugin_toastauth_settings` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `settings` text COLLATE utf8_unicode_ci NOT NULL,
  `status` tinyint(1) unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO `plugin_toastauth_settings` (`id`, `name`, `settings`, `status`) VALUES
  (null,        'facebook',     'a:6:{s:9:\"client_id\";s:0:\"\";s:13:\"client_secret\";s:0:\"\";s:12:\"redirect_uri\";s:0:\"\";s:5:\"scope\";s:5:\"email\";s:8:\"auth_url\";s:37:\"https://www.facebook.com/dialog/oauth\";s:9:\"token_url\";s:45:\"https://graph.facebook.com/oauth/access_token\";}',        0),
  (null,        'google',       'a:8:{s:9:\"client_id\";s:0:\"\";s:13:\"client_secret\";s:0:\"\";s:12:\"redirect_uri\";s:0:\"\";s:5:\"scope\";s:5:\"email\";s:8:\"auth_url\";s:41:\"https://accounts.google.com/o/oauth2/auth\";s:9:\"token_url\";s:42:\"https://accounts.google.com/o/oauth2/token\";s:10:\"grant_type\";s:18:\"authorization_code\";s:13:\"response_type\";s:4:\"code\";}',   0),
  (null,        'linkedin',     'a:8:{s:13:\"response_type\";s:4:\"code\";s:9:\"client_id\";s:0:\"\";s:13:\"client_secret\";s:0:\"\";s:5:\"scope\";s:29:\"r_basicprofile r_emailaddress\";s:12:\"redirect_uri\";s:60:\"http://auth.com/plugin/toastauth/run/login/provider/linkedin\";s:10:\"grant_type\";s:18:\"authorization_code\";s:9:\"token_url\";s:47:\"https://www.linkedin.com/uas/oauth2/accessToken\";s:8:\"auth_url\";s:49:\"https://www.linkedin.com/uas/oauth2/authorization\";}',        0);


UPDATE `plugin` SET `version`='2.4.0' WHERE `name`='shopping';
UPDATE `shopping_config` SET `value`='2.4.0' WHERE `name`='version';

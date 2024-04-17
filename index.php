<?php


/**
 * Redirect request to home to the real front.
 */

$uri = $_SERVER['REQUEST_URI'];
$env = parse_ini_file(".env");
if ($uri == '/' && !empty($env) && !empty($env['FRONT_URL'])) {
  header('Location: ' . $env['FRONT_URL'], true, 301);
  die();
}



/**
 * Front to the WordPress application. This file doesn't do anything, but loads
 * wp-blog-header.php which does and tells WordPress to load the theme.
 *
 * @package WordPress
 */

/**
 * Tells WordPress to load the WordPress theme and output it.
 *
 * @var bool
 */
define( 'WP_USE_THEMES', true );

/** Loads the WordPress Environment and Template */
require __DIR__ . '/wp-blog-header.php';

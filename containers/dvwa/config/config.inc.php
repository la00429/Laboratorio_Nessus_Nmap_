<?php

# If you are having problems connecting to the MySQL database and all of the below variables
# are correct, try changing the 'db_server' variable from localhost to 127.0.0.1. Fixes a
# known issue where Vista users cannot connect to MYSQL databases.

$_DVWA[ 'db_server' ]   = 'localhost';
$_DVWA[ 'db_database' ] = 'dvwa';
$_DVWA[ 'db_user' ]     = 'dvwa';
$_DVWA[ 'db_password' ] = 'p@ssw0rd';

# Only used with PostgreSQL/PGSQL database selection.
$_DVWA[ 'db_port '] = '3306';

# ReCAPTCHA settings
# Get your keys from https://www.google.com/recaptcha/admin/create
$_DVWA[ 'recaptcha_public_key' ]  = '';
$_DVWA[ 'recaptcha_private_key' ] = '';

# Default security level
# Value = 0: Display all errors, warnings and notices
# Value = 1: Display only errors and warnings
# Value = 2: Display only errors
# Value = 3: Display nothing
$_DVWA[ 'default_security_level' ] = 'low';

# Default PHPIDS status
# Value = 1: PHPIDS is enabled
# Value = 0: PHPIDS is disabled
$_DVWA[ 'default_phpids_level' ] = 'disabled';

# Verbose PHPIDS logging
# Value = 1: Log all events
# Value = 0: Log only significant events
$_DVWA[ 'default_phpids_verbose' ] = 'false';

?>

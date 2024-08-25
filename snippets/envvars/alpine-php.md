{%- set phpmajmin    = phpmajmin | default('81') -%}
| PHPDIR                      | /etc/php{{ phpmajmin }}                 | Root directory for `php` config files.
| PHPCONFDIR                  | /etc/php{{ phpmajmin }}/conf.d          | Directory for `php` config snippets.
| PHP_MAX_EXECUTION_TIME      | 30                                      | `php.ini` value for `max_execution_time`. (Only set if file does not exist)
| PHP_MAX_FILE_UPLOADS        | 20                                      | `php.ini` value for `max_file_uploads`. (Only set if file does not exist)
| PHP_MEMORY_LIMIT            | 128M                                    | `php.ini` value for `memory_limit`. (Only set if file does not exist)
| PHP_POST_MAX_SIZE           | 16M                                     | `php.ini` value for `post_max_size`. (Only set if file does not exist)
| PHP_UPLOAD_MAX_FILESIZE     | 16M                                     | `php.ini` value for `upload_max_filesize`. (Only set if file does not exist)
| PHP_OPCACHE_ENABLE_CLI      | 0                                       | `php.ini` value for `opcache.enable_cli`. (Only set if file does not exist, since `php v8.2.22`)
| PHP_ADD_DEFAULT_PHPINFO     | unset                                   | If set to `true` and no php scripts exist inside `WEBDIR`, a default `phpinfo.php` is copied into it. Useful for testing. (since `php v8.2.22`, previously `PHP_SKIP_DEFAULT_PHPINFO`, enabled by default)
| PHP_PERMFIX_WEBDIR          | unset                                   | If set to `true`, ensures files inside `$WEBDIR` are owned/accessible by `S6_USER`. (since `php v8.2.22`)
| PHPFPMCONF                  | /etc/php{{ phpmajmin }}/php-fpm.conf    | `php-fpm` main config file.
| PHPFPMDIR                   | /etc/php{{ phpmajmin }}/php-fpm.d       | Directory for `php-fpm` config snippets.
| PHPFPMSOCK                  | /var/run/php-fpm.sock                   | `php-fpm` socket file location.
| PHPFPM_ARGS                 | -F                                      | Customizable arguments passed to `php-fpm` service at runtime.
| PHPFPM_ERROR_LOG            | /proc/self/fd/2                         | `php-fpm.conf` value for `error_log`. (Only set if file does not exist)
| PHPFPM_LOG_LEVEL            | error                                   | `php-fpm.conf` value for `log_level`. (Only set if file does not exist, since `php v8.2.22`)
| PHPFPM_CATCH_WORKERS_OUTPUT | no                                      | `php-fpm.d/www.conf` value for `catch_workers_output`. (Only set if file does not exist, since `php v8.2.22`)
| PHPFPM_CLEAR_ENV            | yes                                     | `php-fpm.d/www.conf` value for `clear_env`. (Only set if file does not exist, since `php v8.2.22`)
| PHPFPM_PM                   | dynamic                                 | `php-fpm.d/www.conf` value for `pm`. (Only set if file does not exist, since `php v8.2.22`)
| PHPFPM_PM_MAX_CHILDREN      | 5                                       | `php-fpm.d/www.conf` value for `pm.max_children`. (Only set if file does not exist, since `php v8.2.22`)
| PHPFPM_PM_MAX_REQUESTS      | 500                                     | `php-fpm.d/www.conf` value for `pm.max_requests`. (Only set if file does not exist, since `php v8.2.22`)
| PHPFPM_PM_MAX_SPARE_SERVERS | 3                                       | `php-fpm.d/www.conf` value for `pm.max_spare_servers`. (Only set if file does not exist, since `php v8.2.22`)
| PHPFPM_PM_MIN_SPARE_SERVERS | 1                                       | `php-fpm.d/www.conf` value for `pm.min_spare_servers`. (Only set if file does not exist, since `php v8.2.22`)
| PHPFPM_PM_START_SERVERS     | 2                                       | `php-fpm.d/www.conf` value for `pm.start_servers`. (Only set if file does not exist, since `php v8.2.22`)

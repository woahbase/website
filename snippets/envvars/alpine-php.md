{%- set phpmajmin    = phpmajmin | default('81') -%}
| PHPDIR                      | /etc/php{{ phpmajmin }}                 | Root directory for `php` config files.
| PHPCONFDIR                  | /etc/php{{ phpmajmin }}/conf.d          | Directory for `php` config snippets.
| PHP_MAX_EXECUTION_TIME      | 30                                      | `php.ini` value for `max_execution_time`. (Only set if file does not exist)
| PHP_MAX_FILE_UPLOADS        | 20                                      | `php.ini` value for `max_file_uploads`. (Only set if file does not exist)
| PHP_MEMORY_LIMIT            | 128M                                    | `php.ini` value for `memory_limit`. (Only set if file does not exist)
| PHP_POST_MAX_SIZE           | 16M                                     | `php.ini` value for `post_max_size`. (Only set if file does not exist)
| PHP_UPLOAD_MAX_FILESIZE     | 16M                                     | `php.ini` value for `upload_max_filesize`. (Only set if file does not exist)
| PHP_SKIP_DEFAULT_PHPINFO    | unset                                   | If no php scripts exist inside `WEBDIR`, a default `phpinfo.php` is copied into it. Useful for testing, but in other cases, setting this to `true` skips that task.
| PHPFPMCONF                  | /etc/php{{ phpmajmin }}/php-fpm.conf    | `php-fpm` main config file.
| PHPFPMDIR                   | /etc/php{{ phpmajmin }}/php-fpm.d       | Directory for `php-fpm` config snippets.
| PHPFPMSOCK                  | /var/run/php-fpm.sock                   | `php-fpm` socket file location.
| PHPFPM_ARGS                 | -F                                      | Customizable arguments passed to `php-fpm` service at runtime.
| PHPFPM_ERROR_LOG            | /proc/self/fd/2                         | `php-fpm.conf` value for `error_log`. (Only set if file does not exist)

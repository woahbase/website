| ROOTDIR                  | /config                                 | Root directory for `nginx` configs or webserver files.
| NGINXDIR                 | /config/nginx                           | Default directory for `nginx` configurations.
| CONFSDIR                 | /config/nginx/conf.d                    | For shared configuration snippets.
| SITESDIR                 | /config/nginx/http.d                    | For webserver host configuration files.
| STREAMSDIR               | /config/nginx/stream.d                  | For `stream` configuration files. (Optional, requires stream module to be enabled in configurations).
| NGINX_NO_HTTP            | unset                                   | Set to 'true' to disable default http(80) conf file, has no effect if custom site-confs exist.
| NGINX_NO_HTTPS           | unset                                   | Set to 'true' to disable default https(443) conf file, and default self-signed certificate generation on first run.
| KEYDIR                   | /config/keys                            | Default certificate/privatekey location.
| PKEYFILE                 | /config/keys/private.key                | Default path to privatekey. (Make sure site-confs reflect the same)
| CERTFILE                 | /config/keys/certificate.crt            | Default path to certificate. (Make sure site-confs reflect the same)
| SSLSUBJECT               | see [here](alpine-nginx.md#ssl-subject) | Default SSL Subject for self-signed certificate generation on first run.
| NGINX_NO_CERTGEN         | unset                                   | Set to 'true' to disable default self-signed certificate generation on first run.
| HTPASSWDFILE             | /config/keys/.htpasswd                  | Default path to .htpasswd. (Make sure site-confs reflect the same)
| WEBADMIN                 | admin                                   | Default admin user in .htpasswd. (Not changed if file already exists)
| PASSWORD                 | insecurebydefault                       | Default admin user password in .htpasswd.
| NGINX_NO_HTPASSWD        | unset                                   | Set to 'true' to disable default htpasswd generation on first run.
| NGINX_SKIP_FASTCGI_PARAM | unset                                   | If set to `true`, skip appending custom `fastcgi_param` configuration. (since `nginx v1.26.2`)
| WEBDIR                   | /config/www                             | For serving files, e.g. either static HTML or dynamic scripts i.e. with PHP.
| NGINX_ADD_DEFAULT_INDEX  | unset                                   | If set to `true` and no files exist inside `WEBDIR`, a static `index.html` is copied into it. Useful for testing. (since `nginx v1.26.2`, previously `NGINX_SKIP_DEFAULT_INDEX`, enabled by default)
| NGINX_PERMFIX_WEBDIR     | unset                                   | If set to `true`, ensures files inside `$WEBDIR` are owned/accessible by `S6_USER`. (since `nginx v1.26.2`)

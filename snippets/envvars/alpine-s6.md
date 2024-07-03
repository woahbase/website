{%- set user    = s6_user | default('alpine') -%}
{%- set homedir = s6_userhome | default('/home/' + user) -%}
| S6_NEEDED_PACKAGES | empty string  | **Space**-separated list of extra APK packages to install on start. E.g. `"curl git tzdata"`
| PUID               | 1000          | Id of `S6_USER`.
| PGID               | 100           | Group id of `S6_USER`.
| S6_USER            | {{ user }}    | (Preset) Default non-root user for services to drop privileges to.
| S6_USERHOME        | {{ homedir }} | (Preset) HOME directory for `S6_USER`.

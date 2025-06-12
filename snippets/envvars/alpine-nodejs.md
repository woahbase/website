| S6_NPM_PACKAGES        | empty string | **Space**-separated list of packages to install globally with `npm`.
| S6_NPM_PROJECTDIR      | unset        | If specified, runs `npm install` in this dir as a pre-task at runtime.
| S6_NPM_SKIP_INSTALL    | unset        | Deprecated {{ m.sincev('22.15.1', name='alpine-nodejs') }}. Unset `S6_NPM_PROJECTDIR` instead. Skips running install task inside `S6_NPM_PROJECTDIR`.
| S6_NPM_LOCAL_PACKAGES  | empty string | **Space**-separated list of packages to install locally with `npm` inside `S6_NPM_PROJECTDIR`.
| S6_YARN_PACKAGES       | empty string | **Space**-separated list of packages to install globally with `yarn`.
| S6_YARN_PROJECTDIR     | unset        | If specified, runs `yarn install` in this directory as a pre-task at runtime.
| S6_YARN_SKIP_INSTALL   | unset        | Deprecated {{ m.sincev('22.15.1', name='alpine-nodejs') }}. Unset `S6_YARN_PROJECTDIR` instead. Skips running install task inside `S6_YARN_PROJECTDIR`.
| S6_YARN_LOCAL_PACKAGES | empty string | **Space**-separated list of packages to install locally with `yarn` inside `S6_YARN_PROJECTDIR`.
| S6_PNPM_PACKAGES       | empty string | **Space**-separated list of packages to install globally with `pnpm`. {{ m.sincev('22.15.1', name='alpine-nodejs') }}
| S6_PNPM_PROJECTDIR     | unset        | If specified, runs `pnpm install` in this directory as a pre-task at runtime. {{ m.sincev('22.15.1', name='alpine-nodejs') }}
| S6_PNPM_LOCAL_PACKAGES | empty string | **Space**-separated list of packages to install locally with `pnpm` inside `S6_PNPM_PROJECTDIR`. {{ m.sincev('22.15.1', name='alpine-nodejs') }}

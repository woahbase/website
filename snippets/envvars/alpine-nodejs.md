| S6_NPM_PACKAGES        | empty string | **Space**-separated list of packages to install globally with `npm`.
| S6_NPM_PROJECTDIR      | unset        | If specified, runs `npm install` in this dir as a pre-task at runtime.
| S6_NPM_SKIP_INSTALL    | unset        | Skips running install task inside `S6_NPM_PROJECTDIR`.
| S6_NPM_LOCAL_PACKAGES  | empty string | **Space**-separated list of packages to install locally with `npm` inside `S6_NPM_PROJECTDIR`.
| S6_YARN_PACKAGES       | empty string | **Space**-separated list of packages to install globally with `yarn`.
| S6_YARN_PROJECTDIR     | unset        | If specified, runs `yarn install` in this directory as a pre-task at runtime.
| S6_YARN_SKIP_INSTALL   | unset        | Skips running install task inside `S6_YARN_PROJECTDIR`.
| S6_YARN_LOCAL_PACKAGES | empty string | **Space**-separated list of packages to install locally with `yarn` inside `S6_YARN_PROJECTDIR`.

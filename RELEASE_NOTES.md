# RELEASE NOTES

(NOTE:  Version numbers are defined in the Makefile here...)

## v1.2.0.1

* Forked by WattIQ
* Updated dependabot flagged dependencies
* Moved to Go 1.22 for build
* Added Codefresh build pipeline, added build args in Dockerfile to set version and other variables at build time for logging
* Removed .dockerignore which was preventing the Docker build from working at all
* Final container is scratch container with static binary

Note - going to use a fourth patch level version for situations where WattIQ does not modify actual code, so that if the original project releases changes, we can keep the major/minor in sync.


## v1.2.0

Original Vaporio release - we were using this from a public Docker repo
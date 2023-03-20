#!/usr/bin/env bash

version=$1
fnm install $version
fnm exec --using=$version node test.js
fnm exec --using=$version node --es_staging test.js
fnm exec --using=$version node --harmony test.js
fnm uninstall $version  # Don't fill the disk with node installs.

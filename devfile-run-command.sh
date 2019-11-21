#!/bin/bash
set -x
set -eo pipefail

cd "$(eval echo $DEVFILE_RUN_WORKDIR)"
exec $(eval echo $DEVFILE_RUN_COMMAND)
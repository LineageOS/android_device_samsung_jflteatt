#!/bin/sh

set -e

export DEVICE=jflteatt
export DEVICE_UNIFIED=jfltei337
export VENDOR=samsung
./../jf-common/extract-files.sh $@

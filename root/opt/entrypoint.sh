#!/bin/bash
source /opt/nss.sh
exec /sbin/tini -- "$@"

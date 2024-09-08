#!/usr/bin/env bash

set -oue pipefail

rpm-ostree kargs --append="mem_sleep_default=deep"

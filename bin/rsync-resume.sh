#!/bin/bash

rsync -avz --compress-level=9 -P --append-verify "$@"

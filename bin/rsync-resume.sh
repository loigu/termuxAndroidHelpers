#!/bin/bash

rsync -avz -P --append-verify "$@"

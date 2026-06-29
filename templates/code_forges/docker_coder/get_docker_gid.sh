#!/bin/bash

## Get ID of docker group for env variable
getent group docker | cut -d: -f3

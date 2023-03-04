#!/bin/bash

echo ""
echo "Exporting requirements"
echo ""

poetry export -f requirements.txt --output requirements.txt --without-hashes

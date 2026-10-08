#!/bin/sh
# The products API returns the seeded catalogue.
set -e
out=$(curl -fsS http://store:3000/api/products)
echo "$out" | grep -q '"name"'

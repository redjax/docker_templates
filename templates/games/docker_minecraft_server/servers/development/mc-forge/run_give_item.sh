#!/bin/bash

container_name="mc-server"

read -r -p "Give to which player (no @ symbol)? " player
echo

read -r -p "Item ID (check wiki): " item_id
echo

read -r -p "Quantity: " item_quant
echo

echo ""
echo "Giving $player $item_quant $item_id"
echo ""

docker compose exec -it $container_name mc-send-to-console give $player $item_id $item_quant

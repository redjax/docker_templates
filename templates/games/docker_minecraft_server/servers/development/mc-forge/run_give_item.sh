#!/bin/bash

container_name="mc-server"

read -p "Give to which player (no @ symbol)? " player
read -p "Item ID (check wiki): " item_id
read -p "Quantity: " item_quant

echo ""
echo "Giving $player $item_quant $item_id"
echo ""


docker compose exec -it $container_name mc-send-to-console give $player $item_id $item_quant


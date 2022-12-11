#!/bin/bash

declare -a default_dirs=("data" "drone/db" "ssh")

for dir in "${default_dirs[@]}"
do
    if [[ ! -d "$dir" ]]; then

        echo "Creating $dir"
        mkdir -pv $dir
    
    fi
done

if [[ ! -f ".env" ]]; then
    echo ""
    echo "Copying .env.example -> .env"
    echo ""

    cp .env.example .env
fi

if [[ ! -f "./drone/db/database.sqlite" ]]; then
    echo ""
    echo "Creating Drone db"
    echo ""

    python3 create_drone_db.py

    if [[ -f "database.sqlite" ]]; then
        echo ""
        echo "Moving database file to drone/db"
        echo ""

        mv database.sqlite drone/db
    else
        echo ""
        echo "[ERROR]: Database file 'database.sqlite' not found. Is Python installed?"
    fi
fi

echo ""
echo "----------------------->"
echo "Generating Drone secret"
echo "<-----------------------"
echo ""

drone_secret=$(openssl rand -hex 16)

echo "[Drone Secret]"
echo "============================================"
echo $drone_secret
echo "============================================"

echo ""
echo "!! ============================================================= !!"
echo "[       Warning: this secret will not be visible again.           ]"
echo "[    Edit '.env' file now, paste this key into 'DRONE_SECRET'     ]"
echo "!! ============================================================= !!"
echo "+ ----------------------------------------------------------------+"
echo "+   To generate a new key later, run $ openssl rand -hex 16    +"
echo "+ ----------------------------------------------------------------+"
echo ""
echo "$> Press enter once you've updated '.env' using instructions above"
read -p "$>"

clear
exit 0

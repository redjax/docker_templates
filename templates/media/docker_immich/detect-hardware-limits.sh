#!/usr/bin/env bash

#########################################
# Detects CPU cores and RAM, and prints #
# recommended Docker container limits   #
#########################################

## Detect number of CPU cores
CPU_CORES=$(nproc)

## Detect total RAM in MB (Linux)
TOTAL_RAM_MB=$(free -m | awk '/^Mem:/ {print $2}')

## Helper function to calculate percentage of a value
function calc_percent() {
  local value=$1
  local percent=$2
  echo $((value * percent / 100))
}

echo
echo "[ Detected hardware ]"
echo "[-] CPU cores: $CPU_CORES"
echo "[-] Total RAM: ${TOTAL_RAM_MB}MB"
echo ""

echo "[ Recommended Docker resource limits ]"
echo "Based on the detected hardware, below are 3 profiles you can pick from when setting Immich's hardware limits."
echo "The machine learning container can run way with your system's resources, so it's advisable to set a limit."
echo "Note that the higher you go, the more likely you are to pin system resources and experience slowness & degredation."
echo "The tradeoff here is lower usage=slower operations, less system load, while higher usage=faster operations, higher system load."
echo
echo "After deciding on a profile, set the env vars for that profile in your environment or the Immich .env file."
echo

## Low usage (~15% of resources)
LOW_CPU=$(awk "BEGIN {printf \"%.2f\", $CPU_CORES * 0.15}")
LOW_MEM=$(calc_percent "$TOTAL_RAM_MB" 15)
echo "[+] Low usage (15% of available resources)"
echo "IMMICH_ML_CPU_LIMIT=${LOW_CPU}"
echo "IMMICH_ML_MEMORY_LIMIT=${LOW_MEM}m"
echo ""

## Medium usage (~30% of resources)
MED_CPU=$(awk "BEGIN {printf \"%.2f\", $CPU_CORES * 0.30}")
MED_MEM=$(calc_percent "$TOTAL_RAM_MB" 30)
echo "[+] Medium usage (30% of available resources)"
echo "IMMICH_ML_CPU_LIMIT=${MED_CPU}"
echo "IMMICH_ML_MEMORY_LIMIT=${MED_MEM}m"
echo ""

## Medium-High usage (~60% of resources)
MED_HIGH_CPU=$(awk "BEGIN {printf \"%.2f\", $CPU_CORES * 0.60}")
MED_HIGH_MEM=$(calc_percent "$TOTAL_RAM_MB" 60)
echo "[+] Medium-High usage (60% of available resources)"
echo "IMMICH_ML_CPU_LIMIT=${MED_HIGH_CPU}"
echo "IMMICH_ML_MEMORY_LIMIT=${MED_HIGH_MEM}m"
echo ""

## High usage (~80% of resources)
HIGH_CPU=$(awk "BEGIN {printf \"%.2f\", $CPU_CORES * 0.80}")
HIGH_MEM=$(calc_percent "$TOTAL_RAM_MB" 80)
echo "[+] High usage (80% of available resources)"
echo "IMMICH_ML_CPU_LIMIT=${HIGH_CPU}"
echo "IMMICH_ML_MEMORY_LIMIT=${HIGH_MEM}m"

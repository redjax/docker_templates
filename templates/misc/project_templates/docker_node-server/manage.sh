#!/bin/bash

CONTAINER_NAME="node_server"
CONTAINER_ID=$(docker ps -qf "name=${CONTAINER_NAME}")

# docker exec -it $CONTAINER_ID $1

function DOCKER_COMMAND () {

  docker exec -it $CONTAINER_ID $1

}

function INSTALL_NODE_DEP () {

  # DOCKER_COMMAND "yarn add "$1
  echo "Docker command: npm i $2 $1"
  DOCKER_COMMAND "npm i $2 $1"

}

function REMOVE_NODE_DEP () {

  # DOCKER_COMMAND "yarn remove "$1
  DOCKER_COMMAND "npm rm $2 $1"

}

function RUN_NODE_COMMAND () {

  DOCKER_COMMAND $1

}

function PRINT_HELP () {


  separator_line="---------------------------------------------------------------"

  echo ""
  echo " ----------"
  echo "[ Help Menu ]"
  echo " ----------"
  echo ""

  echo "Function: Print help menu"
  echo "Flags: -h, --help"
  echo "Example: ./manage.sh -h"
  echo ""

  echo $separator_line
  echo ""

  echo "Function: Run command in container"
  echo "Flags: -c, --command"
  echo "Example: ./manage.sh -c 'npm start'"
  echo ""

  echo $separator_line
  echo ""

  echo "Function: Install/add Node dependency"
  echo "  HINT: Order of flags does matter. script, flag, [module], [env save]"
  echo "    Example: ./manage.sh i express -D"
  echo ""
  echo "Flags: -i/i, -a, --install, --add"
  echo ""
  echo "Pass save commands (-S, --save/-D, --save-dev) to update package.json"
  echo "  Default: -S (--save)"
  echo ""
  echo "Example: ./manage.sh -i body-parser"
  echo ""
  echo "Install multiple modules at once:"
  echo "  ./manage.sh i 'module1 module-2' -D"
  echo ""

  echo $separator_line
  echo ""

  echo "Function: Uninstall/remove Node dependency"
  echo "  HINT: Order of flags does matter. script, flag, [module], [env save]"
  echo "    Example: ./manage.sh i express -D"
  echo ""
  echo "Flags: -u, -r/r/rm, --uninstall, --remove"
  echo ""
  echo "Pass save commands (-S, --save/-D, --save-dev) to update package.json"
  echo "  Default: -S (--save)"
  echo ""
  echo "Example: ./manage.sh -r body-parser"
  echo ""
  echo "Uninstall multiple modules at once:"
  echo "  ./manage.sh rm 'module1 module-2' -D"
  echo ""

}

# Variable to hold save flag (-S, --save/-D, --save-dev)
save_mode=""

case $3 in
  "" | "--save" | "-S")
    save_mode="-S"
  ;;
  "--save-dev" | "-D")
    save_mode="-D"
  ;;
esac

case $1 in
  "-i"| "i" | "-a" | "--install" | "--add")
    INSTALL_NODE_DEP $2 $save_mode
  ;;
  "-u" | "-r" | " r" | "rm" | "--uninstall" | "--remove")
    REMOVE_NODE_DEP $2 $save_mode
  ;;
  "-h" | "--help")
    PRINT_HELP
  ;;
  "-c" | "--command")
    RUN_NODE_COMMAND $2
  ;;
  "*" | "")
    echo ""
    echo "Invalid flag, or no flag detected. Printing help menu."
    echo ""
    PRINT_HELP
  ;;
esac

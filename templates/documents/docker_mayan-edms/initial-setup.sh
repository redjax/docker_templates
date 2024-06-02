THIS_DIR=${PWD}

GITLAB_BASE_URL="https://gitlab.com/mayan-edms/mayan-edms/-/raw/master/docker"
COMPOSE_FILE_NAME="docker-compose.yml"
ENV_FILE_NAME="env_file"
ENV_NAME=".env"
GITLAB_COMPOSE_URL=$GITLAB_BASE_URL/$COMPOSE_FILE_NAME
GITLAB_ENV_FILE_URL=$GITLAB_BASE_URL/$ENV_FILE_NAME
GITLAB_ENV_URL=$GITLAB_BASE_URL/$ENV_NAME

declare -a DOCKER_FILES=( $GITLAB_COMPOSE_URL $GITLAB_ENV_FILE_URL $GITLAB_ENV_URL )
declare -a CHECK_FILES=( $COMPOSE_FILE_NAME $ENV_FILE_NAME $ENV_NAME )

function CURL_FILE () {

  curl $1 -O

}

function DIR_SETUP () {

  declare -a DIRS=( $THIS_DIR"/redis" $THIS_DIR"/db" $THIS_DIR"/media" )

  for DIR in "${DIRS[@]}"
  do
    if [[ ! -d $DIR ]];
    then
      mkdir -pv $DIR
    elif [[ -d $DIR ]];
    then
      echo ""
      echo $DIR" exists. Skipping."
      echo ""
    fi
  done

}

DIR_SETUP

for F in "${CHECK_FILES[@]}"
do
  if [[ ! -f $F ]]; then
    echo ""
    echo "Curling "$F
    echo ""

    CURL_FILE $GITLAB_BASE_URL/$F

  elif [[ -f $F ]]; then
    echo ""
    echo $F "Already exists. Skipping."
    echo ""
  fi
done

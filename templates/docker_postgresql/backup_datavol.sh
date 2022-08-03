#!/bin/bash

this_dir=${PWD}

backup_container_image="busybox"

docker_proj_name="docker_postgresql"
backup_dir="$this_dir/backup"

pg_container="postgres"
pgdata_vol_name="postgres_data"
pgdata_container_path="/var/lib/postgresql/data"

pgadmin_container="pgadmin"
pgadmindata_vol_name="pgadmin_data"
pgadmindata_container_path="/var/lib/pgadmin"

pg_backup_dir="$backup_dir/$pgdata_vol_name/"
pgadmin_backup_dir="$backup_dir/$pgadmindata_vol_name/"

function check_dirs_exist() {

    declare -a dirs=("$backup_dir" "$pg_backup_dir" "$pgadmin_backup_dir")

    for dir in "${dirs[@]}"; do
        if [[ ! -d $dir ]]; then
            echo "$dir does not exist. Creating."

            mkdir -pv $dir
        fi
    done
}

function backup_container_data() {
    # $1=container name

    case $1 in
    "postgres")
        source_container=$pg_container
        backup_dir=$pg_backup_dir
        container_path=$pgdata_container_path
        ;;
    "pgadmin")
        source_container=$pgadmin_container
        backup_dir=$pgadmin_backup_dir
        container_path=$pgadmindata_container_path
        ;;
    "*")
        echo "Invalid container: $1"

        exit
        ;;
    esac

    echo "[Debug] source_container: $source_container"

    docker_cmd="docker run --rm --volumes-from $source_container -v $backup_dir:/backup $backup_container_image tar czvf /backup/postgres_data_backup.tar.gz $container_path"

    echo ""
    echo "Stopping $source_container"
    docker compose stop $source_container

    echo ""
    echo "Running Docker command:"
    echo "$docker_cmd"
    echo ""

    exec $docker_cmd &
    wait

    echo ""
    echo "Restarting container"
    echo ""
    docker compose restart $source_container

}

function full_backup() {

    echo ""
    echo "Backup: $pg_container"
    echo ""
    backup_container_data $pg_container

    echo ""
    echo "Backup $pgadmin_container"
    echo ""
    backup_container_data $pgadmin_container

}

function restore_container_data() {
    # $1=container name

    case $1 in
    "postgres")
        target_container=$pg_container
        backup_dir=$pg_backup_dir
        container_path=$pgdata_container_path
        ;;
    "pgadmin")
        target_container=$pgadmin_container
        backup_dir=$pgadmin_backup_dir
        container_path=$pgadmindata_container_path
        ;;
    "*")
        echo "Invalid container: $1"

        exit
        ;;
    esac

    echo "[Debug] target_container: $target_container"

    docker_cmd="docker run --rm --volumes-from $target_container -v $backup_dir:/backup $backup_container_image tar czvf /backup/postgres_data_backup.tar.gz $container_path --strip 1"

    echo ""
    echo "Stopping $target_container"
    docker compose stop $target_container

    echo ""
    echo "Running Docker command:"
    echo "$docker_cmd"
    echo ""

    exec $docker_cmd &
    wait

    echo ""
    echo "Restarting container"
    echo ""
    docker compose restart $target_container

}

function pg_db_backup() {

    dump_name="dump_$(date +%Y-%m-%d_%H_%M_%S).sql"
    docker exec -t $pg_container pg_dumpall -c -U postgres >"$pg_backup_dir/$dump_name"

    echo "TODO: Implement backup trim here"
}

function pg_db_restore() {

    for file in $pg_backup_dir*.sql; do
        filename="$(basename ${file})"
        echo "Backup: $filename"
    done
}

function full_restore() {

    echo ""
    echo "Restore: $pg_container"
    echo ""
    restore_container_data $pg_container

    echo ""
    echo "Restore: $pgadmin_container"
    echo ""
    restore_container_data $pgadmin_container

}

function main() {

    echo "[DEBUG] Check if backup directories exist"
    check_dirs_exist

    case $1 in
    "-b" | "--backup")
        read -p "(F)ull backup, or (S)ingle container? " backup_choice

        case $backup_choice in
        "f" | "F")
            full_backup
            ;;
        "s" | "S")
            echo ""
            read -p "(P)ostgres or (A)dmin? " single_backup_choice
            echo ""

            case $single_backup_choice in
            "p" | "P")
                container_choice="postgres"
                backup_container_data $container_choice
                ;;
            "a" | "A")
                container_choice="pgadmin"
                backup_container_data $container_choice
                ;;
            *)
                echo "Invalid: $single_backup_choice"
                ;;
            esac
            ;;
        *)
            echo ""
            echo "Invalid: $backup_choice. Please choose 'F' or 'S'."
            echo ""
            ;;
        esac
        ;;
    "-r" | "--restore")
        read -p "(F)ull restore, or (S)ingle container? " restore_choice

        case $restore_choice in
        "f" | "F")
            full_restore
            ;;
        "s" | "S")
            echo ""
            read -p "(P)ostgres or (A)dmin? " single_restore_choice
            echo ""

            case $single_restore_choice in
            "p" | "P")
                container_choice="postgres"
                restore_container_data $container_choice
                ;;
            "a" | "A")
                container_choice="pgadmin"
                restore_container_data $container_choice
                ;;
            *)
                echo "Invalid: $single_restore_choice"
                ;;
            esac
            ;;
        esac
        ;;
    esac

    # echo ""
    # echo "Backing up containers"

    # # full_backup
    # full_restore

}

main $1
# pg_db_backup

# pg_db_restore

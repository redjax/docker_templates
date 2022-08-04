#!/bin/bash

this_dir=${PWD}

backup_container_image="busybox"
backup_retention="3"

docker_proj_name="docker_postgresql"
backup_dir="$this_dir/backup"

pg_container="postgres"
pg_container_user="postgres"
pgdata_vol_name="postgres_data"
pgdata_container_path="/var/lib/postgresql/data"

pgadmin_container="pgadmin"
pgadmindata_vol_name="pgadmin_data"
pgadmindata_container_path="/var/lib/pgadmin"

pg_backup_dir="$backup_dir/$pgdata_vol_name"
pgadmin_backup_dir="$backup_dir/$pgadmindata_vol_name"

function check_dirs_exist() {

    declare -a dirs=("$backup_dir" "$pg_backup_dir/" "$pgadmin_backup_dir/")

    for dir in "${dirs[@]}"; do
        if [[ ! -d $dir ]]; then
            echo "$dir does not exist. Creating."

            mkdir -pv $dir
        fi
    done
}

function trim_backup() {

    loop_count=0
    file_count=$(ls $pg_backup_dir/ | wc -l)

    echo ""
    echo "Found $file_count file(s)"
    echo ""

    if [[ $file_count -ge $backup_retention ]]; then
        echo "Trimming backups"

        while [ $file_count -gt $backup_retention ]; do
            # Get file, remove oldest
            stat --printf='%Y %n\0' $pg_backup_dir/*.sql | sort -z | sed -zn '1s/[^ ]\{1,\} //p' | xargs -0 rm

            file_count=$(ls $pg_backup_dir/ | wc -l)
        done
    fi

}

function backup_container_data() {
    # $1=container name

    case $1 in
    "postgres")
        source_container=$pg_container
        backup_dir="$pg_backup_dir/"
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

    trim_backup

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
        backup_dir="$pg_backup_dir/"
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

    echo "Backing up $pg_container db dump to $pg_backup_dir/$dump_name"

    dump_name="dump_$(date +%Y-%m-%d_%H_%M_%S).sql"
    docker exec -t $pg_container pg_dumpall -c -U postgres >"$pg_backup_dir/$dump_name"

    trim_backup
}

function pg_db_restore() {

    # for file in $pg_backup_dir*.sql; do
    #     filename="$(basename ${file})"
    #     echo "Backup: $filename"
    # done

    ## Build numbered list of files for user to select from
    #    https://askubuntu.com/a/682104
    unset options i
    # Read input from find command, null-delimeted
    while IFS= read -r -d $'\0' file; do

        # Get filename from path
        #   https://stackoverflow.com/a/965072
        filename="${file##*/}"

        # Add find files to array "options," increment i
        options[i++]="$filename"

        # Finish loop, run find command & feed into IFS
    done < <(find $pg_backup_dir/ -maxdepth 1 -type f -name "*.sql" -print0)

    ## Select menu (from link above)
    select opt in "${options[@]}" "(Q)uit"; do

        case $opt in
        *.sql)
            echo ""
            echo "[DEBUG] Backup selected: $opt"
            echo ""
            echo "Restoring backup to $pg_container"

            echo ""
            echo "Bringing down stack temporarily"
            echo ""
            docker compose down

            sleep 10

            echo ""
            echo "Restarting $pg_container"

            docker compose -f docker-compose.yml run --rm --name $pg_container -e POSTGRES_HOST_AUTH_METHOD='trust' -d $pg_container
            # cat $file | docker exec -i $pg_container psql -U postgres
            cat $file | docker compose exec -d -i $pg_container psql -U $pg_container_user

            echo ""
            echo "Restarting container to unset POSTGRES_HOST_AUTH_METHOD=true env var."
            echo ""
            docker stop $pg_container

            docker compose up -d --force-recreate
            ;;

        "q" | "Q")
            echo "Stopping script."
            break
            ;;
        *)
            echo "Invalid option: $opt. Select using option number, not name (i.e. 1)."
            ;;
        esac
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

## Leave help menu function at bottom
function print_help() {

    echo ""
    echo "-b/--backup"
    echo "  -> Start backup selection"
    echo "     -> Selections:"
    echo "          f/F: Full backup"
    echo "            Backup all container volumes & databases"
    echo ""
    echo "          s/S: Start backup selection"
    echo "            -> Options: (P)ostgres, pg(A)dmin"
    echo ""
    echo "-r/--restore"
    echo "  -> Start restore selection"
    echo "     -> Selections:"
    echo "          f/F: Full restore"
    echo "            Restore all container volumes & databases"
    echo ""
    echo "          s/S: Start restore selection"
    echo "            -> Options: (P)ostgres, pg(A)dmin"
    echo ""
    echo "-tb/--trim-backups"
    echo "  -> Trim postgres db backup dir, starting with oldest,"
    echo "     retaining num backups defined in $'backup_retention' var declared at top of script.."
    echo ""
    echo ""
    echo "-h/--help"
    echo "  -> Print help menu"
    echo ""
    echo ""

}

function main() {

    echo "[DEBUG] Check if backup directories exist"
    check_dirs_exist

    echo "Arg: $1"

    case $1 in
    "-b" | "--backup")
        read -p "(F)ull backup, or (S)ingle container? " backup_choice

        case $backup_choice in
        "f" | "F")
            full_backup
            ;;
        "s" | "S")
            echo ""
            read -p "(P)ostgres or pg(A)dmin? " single_backup_choice
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
            read -p "(P)ostgres or pg(A)dmin? " single_restore_choice
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
    "-tb" | "--trim-backups")
        echo "Trimming backups"
        trim_backup
        ;;
    "-h" | "--help")
        print_help
        ;;
    *)
        print_help
        echo "------------"
        echo "Invalid: $1"
        ;;
    esac

}

main $1
# pg_db_backup

# pg_db_restore

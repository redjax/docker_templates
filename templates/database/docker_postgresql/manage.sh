#!/usr/bin/env bash

this_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

## Image to use for temporary backup container
backup_container_image="busybox"
## Number of db dumps & script backups to keep
backup_retention="3"

## Name of docker project, which is prepended to volume names
docker_proj_name="docker_postgresql"
## Top level backup directory
backup_dir="$this_dir/backup"

## Postgres container name
pg_container="postgres"
## Postgres container user. Must match value in .env
pg_container_user="postgres"
## Name of postgres data volume
pgdata_vol_name="postgres_data"
## Path in postgres container to data dir
pgdata_container_path="/var/lib/postgresql/data"

## Name of pgadmin container
pgadmin_container="pgadmin"
## Name of pgadmin data volume
pgadmindata_vol_name="pgadmin_data"
## Path in pgadmin container to data dir
pgadmindata_container_path="/var/lib/pgadmin"
pgadmin_scripts_container_path="/var/lib/pgadmin/storage"

## Path to postgres data backup on host
pg_backup_dir="$backup_dir/$pgdata_vol_name"
pg_db_backup_dir="$pg_backup_dir/db_dumps"
## Path to pgadmin data backup on host
pgadmin_backup_dir="$backup_dir/$pgadmindata_vol_name"

function check_dirs_exist() {
    ## Ensure directories needed for script exist

    declare -a dirs=("$backup_dir" "$pg_backup_dir/" "$pgadmin_backup_dir/" "$pg_db_backup_dir" "$pgadmin_backup_dir/scripts")

    ## Loop over 'dirs' array
    for dir in "${dirs[@]}"; do
        # Check if dir exists
        if [[ ! -d $dir ]]; then
            echo "$dir does not exist. Creating."

            ## Create  $dir
            mkdir -pv $dir
        fi
    done
}

function trim_backup() {
    ## Delete oldest db backup, retaining num in $'pg_db_backup_retention' var at top of script

    declare -a backup_trim_dirs=("$pg_db_backup_dir" "$pgadmin_backup_dir/scripts")

    for dir in "${backup_trim_dirs[@]}"; do

        echo "[DEBUG] Dir in trim FOR loop: $dir"

        if [[ $dir == "$pg_db_backup_dir" ]]; then

            echo "[DEBUG] DIR: $dir"

            ## Initialize loop counter
            pg_db_loop_count=0
            ## Get count of files in pg_backup_dir
            pg_db_file_count=$(ls $dir/ | wc -l)

            echo ""
            echo "Found $pg_db_file_count file(s) in $dir"
            echo ""

            ## If number of files in backup dir is greater than or equal to retention value
            if [[ $pg_db_file_count -ge $backup_retention ]]; then
                echo "Trimming backups from $dir"

                ## Loop until number of files is less than retention num
                while [ $pg_db_file_count -gt $backup_retention ]; do

                    ## Get pg_db files, remove oldest
                    stat --printf='%Y %n\0' $dir/*.sql | sort -z | sed -zn '1s/[^ ]\{1,\} //p' | xargs -0 rm

                    ## Re-set file_count after file deletion
                    pg_db_file_count=$(ls $pg_db_backup_dir/ | wc -l)
                done
            fi
        else
            echo "[DEBUG] DIR: $dir"
            ## Initialize loop counter
            pga_script_loop_count=0
            ## Get count of files in pg_backup_dir
            pga_script_file_count=$(ls $dir/ | wc -l)

            echo ""
            echo "Found $pga_script_file_count file(s) in $dir"
            echo ""

            ## If number of files in backup dir is greater than or equal to retention value
            if [[ $pga_script_file_count -ge $backup_retention ]]; then
                echo "[DEBUG] pgAdmin scripts count: $pga_script_file_count"

                echo "Trimming backups from $dir"

                while [[ $pga_script_file_count -gt $backup_retention ]]; do
                    ## Get pga script files, remove oldest
                    stat --printf='%Y %n\0' $dir/* | sort -z | sed -zn '1s/[^ ]\{1,\} //p' | xargs -0 rm

                    ## Re-set file_count after file deletion
                    pga_script_file_count=$(ls $pg_db_backup_dir/ | wc -l)
                done
            fi
        fi
    done

}

function backup_container_data() {
    ## $1=container name

    case $1 in
    "postgres")
        ## Set postgres backup variables
        source_container=$pg_container
        backup_dir="$pg_backup_dir/"
        container_path=$pgdata_container_path
        ;;
    "pgadmin")
        ## Set pgadmin backup variables
        source_container=$pgadmin_container
        backup_dir=$pgadmin_backup_dir
        container_path=$pgadmindata_container_path
        ;;
    "*")
        echo "Invalid container: $1"

        exit
        ;;
    esac

    echo "[DEBUG] source_container: $source_container"

    ## Backup command
    docker_cmd="docker run --rm --volumes-from $source_container -v $backup_dir:/backup $backup_container_image tar czvf /backup/postgres_data_backup.tar.gz $container_path"

    echo ""
    echo "Stopping $source_container"
    ## Stop container
    docker compose stop $source_container

    echo ""
    echo "Running Docker command:"
    echo "$docker_cmd"
    echo ""

    ## Run docker backup using intermediary $'backup_container_image'
    exec $docker_cmd &
    wait

    echo ""
    echo "Restarting container"
    echo ""

    ## Restart container after backup
    docker compose restart $source_container

}

function pg_backup_select() {

    read -p "Backup (V)olume data or (D)atabase dump? " pg_backup_choice

    case $pg_backup_choice in
    "v" | "V")
        echo ""
        echo "Backing up $container_choice data volume"
        echo ""

        backup_container_data $container_choice
        ;;
    "d" | "D")
        echo ""
        echo "Backing up $container_choice databases"
        echo ""

        pg_db_backup
        ;;
    "*")
        echo ""
        echo "Invalid choice: $pg_backup_choice"
        break
        ;;
    esac

}

function pga_backup_select() {

    read -p "Backup (V)olume data or (S)cripts? " pg_backup_choice

    case $pg_backup_choice in
    "v" | "V")
        echo ""
        echo "Backing up pgAdmin data volume"
        echo ""

        backup_container_data "pgadmin"
        ;;
    "d" | "D")
        echo ""
        echo "Backing up pgAdmin databases"
        echo ""

        pg_db_backup
        ;;
    "s" | "S")
        echo ""
        echo "Backing up pgAdmin scripts"
        echo ""

        pgadmin_scripts_backup
        ;;
    "*")
        echo ""
        echo "Invalid choice: $pg_backup_choice"
        break
        ;;
    esac

}

function pgadmin_scripts_backup() {

    ## Temporary dir to store scripts before tar
    backup_tmp="backup_tmp"
    echo ""
    echo "Copying scripts out of pgadmin:$pgadmin_scripts_container_path"
    echo ""

    docker cp pgadmin:$pgadmin_scripts_container_path $pgadmin_backup_dir/scripts

    echo ""
    echo "Creating $pgadmin_backup_dir/scripts/$backup_tmp to store scripts"
    echo ""

    if [[ ! -d "$pgadmin_backup_dir/scripts/backup_tmp" ]]; then
        mkdir -pv "$pgadmin_backup_dir/scripts/$backup_tmp"
    fi

    echo ""
    echo "Moving all files from $pgadmin_backup_dir/scripts to $pgadmin_backup_dir/scripts/$backup_tmp"
    echo ""

    mv $pgadmin_backup_dir/scripts/* $pgadmin_backup_dir/scripts/$backup_tmp/

    echo ""
    echo "Creating archive of $pgadmin_backup_dir/scripts/$backup_tmp"
    echo ""

    tar czvf "$pgadmin_backup_dir/scripts/pgadmin_scripts_$(date +%Y-%m-%d_%H_%M_%S).tar.gz" "$pgadmin_backup_dir/scripts/$backup_tmp"

    echo ""
    echo "Removing $pgadmin_backup_dir/scripts/$backup_tmp"
    echo ""

    if [[ -d "$pgadmin_backup_dir/scripts/$backup_tmp" ]]; then
        rm -r "$pgadmin_backup_dir/scripts/$backup_tmp"
    fi

    # echo ""
    # echo "Trimming backups"
    # echo ""

    # trim_backup

}

function full_backup() {
    ## Run all backup jobs

    echo ""
    echo "Backup: $pg_container"
    echo ""
    ## Backup postgres data
    backup_container_data $pg_container

    ## Trim backups
    trim_backup

    echo ""
    echo "Backup $pgadmin_container"
    echo ""
    ## Backup pgadmin data
    backup_container_data $pgadmin_container

}

function restore_container_data() {
    ## $1=container name

    case $1 in
    "postgres")
        ## Set postgres backup variables
        target_container=$pg_container
        backup_dir="$pg_backup_dir/"
        container_path=$pgdata_container_path

        pg_db_restore
        ;;
    "pgadmin")
        ## Set pgadmin backup variables
        target_container=$pgadmin_container
        backup_dir=$pgadmin_backup_dir
        container_path=$pgadmindata_container_path

        echo "pgadmin restore not implemented."
        break
        ;;
    "*")
        echo "Invalid container: $1"

        exit
        ;;
    esac

}

function pg_db_backup() {
    ## Backup postgres databases
    echo "Backing up $pg_container db dump to $pg_db_backup_dir/$dump_name"

    ## Prepare backup name
    dump_name="dump_$(date +%Y-%m-%d_%H_%M_%S).sql"
    ## Run docker backup command
    docker exec -t $pg_container pg_dumpall -c -U postgres >"$pg_db_backup_dir/$dump_name" &
    wait

    ## Trim backups
    trim_backup
}

function pg_restore_select() {

    echo ""
    read -p "(Pg): Postgres or (pgA) pgAdmin? " single_restore_choice
    echo ""

    case $single_restore_choice in
    "pg" | "PG" | "Pg" | "pG")
        container_choice="postgres"

        read -p "Restore Postgres (V)olume data or (D)atabase dump? " pg_restore_choice

        case $pg_restore_choice in
        "v" | "V")
            echo ""
            echo "Restoring up $container_choice data volume"
            echo ""

            restore_container_data $container_choice
            ;;
        "d" | "D")
            echo ""
            echo "Restoring up $container_choice databases"
            echo ""

            pg_db_restore
            ;;
        "*")
            echo ""
            echo "Invalid choice: $pg_restore_choice"
            break
            ;;
        esac
        ;;
    "pga" | "PGA" | "PGa" | "Pga" | "PgA" | "pgA")
        container_choice="pgadmin"
        restore_container_data $container_choice

        restore_container_data $pgadmin_container
        ;;
    *)
        echo "Invalid: $single_restore_choice"
        ;;
    esac

}

function pg_db_restore() {
    ## Restore postgres backup dump

    ## Build numbered list of files for user to select from
    #    https://askubuntu.com/a/682104
    unset options i
    # Read input from find command, null-delimeted
    while IFS= read -r -d $'\0' file; do

        ## Get filename from path
        #   https://stackoverflow.com/a/965072
        filename="${file##*/}"

        ## Add find files to array "options," increment i
        options[i++]="$filename"

        ## Finish loop, run find command & feed into IFS
    done < <(find $pg_db_backup_dir/ -maxdepth 1 -type f -name "*.sql" -print0)

    ## Select menu (from link above)
    select opt in "${options[@]}" "(Q)uit"; do

        backup_full_path="$pg_db_backup_dir/$opt"
        # echo "[DEBUG] file: $backup_full_path, inside select statement"

        case $opt in
        *.sql)
            # echo ""
            # echo "[DEBUG] Backup selected: $opt"
            echo ""
            echo "Restoring backup to $pg_container"

            echo ""
            echo "Bringing down stack temporarily"
            echo ""
            ## Bring docker stack down
            docker compose down &
            wait

            # sleep 10

            echo ""
            echo "Restarting $pg_container"
            echo ""
            ## Restart container with env var POSTGRES_HOST_AUTH_METHOD='trust'
            docker compose -f docker-compose.yml run --rm --name $pg_container -e POSTGRES_HOST_AUTH_METHOD='trust' -d $pg_container &
            wait

            ## Cat contents of dump into psql command
            # cat $file | docker exec -i $pg_container psql -U postgres
            # cat $file | docker compose exec -d -i $pg_container psql -U $pg_container_user

            ## Copy backup contents into container
            docker_cp_cmd="docker cp $backup_full_path $pg_container:/backup/$opt"

            # echo "[DEBUG] Docker cp command: $docker_cp_cmd"

            echo ""
            echo "Copying $opt into $pg_container:/backup"
            echo ""

            eval $docker_cp_cmd &
            wait

            ## Restore db
            cat $backup_full_path | docker exec -i $pg_container psql -U $pg_container_user

            echo ""
            echo "Restarting container to unset POSTGRES_HOST_AUTH_METHOD=true env var."
            echo ""
            docker stop $pg_container

            docker compose up -d --force-recreate

            break
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
    echo "     retaining num backups defined in $'pg_db_backup_retention' var declared at top of script.."
    echo ""
    echo "-bpgdb/--backup-postgresdb"
    echo "  -> Shortcut to postgres DB backup"
    echo ""
    echo "-bpgv/--backup-postgresvol"
    echo "   -> Shortcut to postgres data volume backup"
    echo ""
    echo "-bpav"/"--backup-pgadminvol"
    echo "  -> Shortcut to pgadmin data volume backup"
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

                pg_backup_select
                ;;

            "a" | "A")
                container_choice="pgadmin"
                ## backup_container_data $container_choice
                pga_backup_select
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
            pg_restore_select
            ;;
        "*")
            echo "Invalid choice: $restore_choice"
            ;;
        esac
        ;;
    "-tb" | "--trim-backups")
        echo "Trimming backups"
        trim_backup
        ;;
    "-bpgdb" | --"backup-postgresdb")
        pg_db_backup
        ;;
    "-bpgv | --backup-postgresvol")
        backup_container_data $pg_container
        ;;
    "-bpav" | "--backup-pgadminvol")
        backup_container_data $pgadmin_container
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

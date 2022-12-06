#!/bin/bash

# Script for creating backups to dropbox.
# Usage: backup-to-dropbox.sh -f /my/folder/to/backup  -n my_backup_name -p password123

function help() {
    echo "Usage: backup-to-dropbox [ -f ] The folder to backup
	[ -n ] name of the created archive
	[ -d ] the dropbox path where to upload
	[ -h ]"
    echo ""
    echo ""
    echo "Example: sh backup-to-dropbox.sh -f /my/folder/to/backup -f /another/folder-to-backup -n my_backup_name -d /path/in/dropbox"
    echo ""
    echo ""
    echo "Requires also DROPBOX_ACCESS_TOKEN and ARCHIVE_PASSWORD env variables to be present"
    exit 2
}

if [[ ! -v DROPBOX_ACCESS_TOKEN ]]; then
    echo "DROPBOX_ACCESS_TOKEN is not set"
    exit 1
fi

if [[ ! -v ARCHIVE_PASSWORD ]]; then
    echo "ARCHIVE_PASSWORD is not set"
    exit 1
fi

BACKUP_NAME=""
DROPBOX_DESTINATION=""
FOLDER=()

# Parse command-line arguments
while getopts ":n:d:f:h:" opt; do
    case $opt in
        n)
            BACKUP_NAME=$OPTARG
            ;;
        d)
            DROPBOX_DESTINATION=$OPTARG
            ;;
        f)
            FOLDER+=("$OPTARG")
            ;;
        h)
            help
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
    esac
done

# Validate required arguments
if [ -z "$FOLDER" ]; then
    echo "Error: required argument -f is missing. Use the -h option for usage information."
    exit 1
fi
if [ -z "$BACKUP_NAME" ]; then
    echo "Error: required argument -n is missing. Use the -h option for usage information."
    exit 1
fi
if [ -z "$DROPBOX_DESTINATION" ]; then
    echo "Error: required argument -d is missing. Use the -h option for usage information."
    exit 1
fi

function upload_backup() {
    tar -zcvf "$BACKUP_NAME".tar.gz "${FOLDER[@]}"

    openssl enc -aes-256-cbc -pbkdf2 -salt \
        -in "$BACKUP_NAME".tar.gz \
        -out "$BACKUP_NAME".tar.gz.enc \
        -k "$PASSWORD" -pass pass:

    NEW_BACKUP="${BACKUP_NAME}_$(date -I)".tar.gz.enc
    mv "$BACKUP_NAME".tar.gz.enc "$NEW_BACKUP"
    rm "$BACKUP_NAME".tar.gz

    curl -X POST "https://content.dropboxapi.com/2/files/upload" \
        -H "Authorization: Bearer $DROPBOX_ACCESS_TOKEN" \
        -H "Content-Type: application/octet-stream" \
        --data-binary @"$NEW_BACKUP" \
        --header "Dropbox-API-Arg: {\"path\": \"$DROPBOX_DESTINATION/$NEW_BACKUP\"}"
    echo ""
    echo ""

    rm "$NEW_BACKUP"
    echo "$NEW_BACKUP uploaded successfully"
}

function delete_old_backups() {
    BACKUPS=$(curl -X POST https://api.dropboxapi.com/2/files/list_folder \
        --header "Authorization: Bearer $DROPBOX_ACCESS_TOKEN" \
        --header "Content-Type: application/json" \
        --data "{\"path\": \"$DROPBOX_DESTINATION\"}" |
        jq '.entries | map({ "name": .name, "time": .client_modified })')

    ONE_WEEK_AGO=$(date -Iseconds -d "7 days ago")

    INDEX=0
    while [ $INDEX -lt "$(echo "$BACKUPS" | jq '. | length')" ]; do
        BACKUP=$(echo "$BACKUPS" | jq ".[$INDEX]")

        NAME=$(echo "$BACKUP" | jq -r '.name')
        TIME=$(echo "$BACKUP" | jq -r '.time')
        if [[ "$TIME" < "$ONE_WEEK_AGO" ]]; then
            echo "Deleting $NAME $TIME as it's older than 7 days"
            curl -X POST https://api.dropboxapi.com/2/files/delete \
                --header "Authorization: Bearer $DROPBOX_ACCESS_TOKEN" \
                --header "Content-Type: application/json" \
                --data "{\"path\": \"$DROPBOX_DESTINATION/$NAME\"}"
            echo ""
        fi
        INDEX=$((INDEX + 1))
    done
}

upload_backup
echo "Starting to delete old backups"
delete_old_backups
echo "Finished backup process"
exit 0

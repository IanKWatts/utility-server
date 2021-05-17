#!/bin/sh
#
# github_backup.sh
#
#     put the repo archive file in S3 using the 'aws' CLI
# -------------------------------------------------------

BUCKET=github-backups
BASEDIR=/tmp/github-backups

LOGDIR="${BASEDIR}/logs"
DATE=`date "+%Y-%m-%d"`
LOGFILE="${LOGDIR}/github_backup_${DATE}"

# Create a directory for logs
# ---------------------------
if [ ! -d $LOGDIR ]; then echo "Creating log dir $LOGDIR"; mkdir -p $LOGDIR; fi
if [ ! -f ${LOGFILE} ]; then touch ${LOGFILE}; fi

function log() {
  echo $1
  echo $1 >> ${LOGFILE}
}

log "Executing $0"

# Make backups for each repo listed in the repo file
# --------------------------------------------------
for entry in `grep -v ^# github_backup-repos.txt`; do

  ORG=`echo $entry  | cut -f 1 -d ":"`
  REPO=`echo $entry | cut -f 2 -d ":"`
  MODE=`echo $entry | cut -f 3 -d ":"`
  TYPE=`echo $entry | cut -f 4 -d ":"`

  log "Starting backups for ${ORG}/${REPO}"

  if [ ! -d $BASEDIR/$ORG ]; then mkdir $BASEDIR/$ORG; fi

    log "$ORG / $REPO"

    COMPRESSED_FILE="${repo}.tar.gz"

    # Set the backup mode
    # -------------------
    case "$MODE" in
      all) 

    # Back up the repo
    # ----------------
    #github-backup $ORG --token $TOKEN --organization --output-directory $BASEDIR --private --repositories --repository $REPO
    echo "ORG: $ORG"
    echo "REPO: $REPO"
    echo "MODE: $MODE"
    echo "TYPE: $TYPE"

    # Tar and compress the repo
    # -------------------------
    log "-  compressing backup"
    #tar czfp $COMPRESSED_FILE $repo

    # Send the file to the off-site storage
    # -------------------------------------
    log "-  copying $COMPRESSED_FILE to storage"
    #aws s3api put-object --bucket $BUCKET --key $COMPRESSED_FILE --body $COMPRESSED_FILE

    log ""
    
done

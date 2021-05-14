#!/bin/sh
#
# github_backup.sh
#
# Back up GitHub repositories and copy them to an S3 bucket.
# * repos to back up are defined in a ConfigMap
# * S3 creds are in a Secret
# ----------------------------------------------------------

BUCKET=github-backup
BASEDIR=/tmp/github-backups

DATE=`date "+%Y-%m-%d"`
LOGDIR="${BASEDIR}/logs"
LOGFILE="${LOGDIR}/github_backup_${DATE}"

# Ensure that our directories exist
# ---------------------------------
if [ ! -d $BASEDIR ]; then mkdir -p $BASEDIR; fi
if [ ! -d $LOGDIR ]; then mkdir -p $LOGDIR; fi

# Read the repo list and S3 credentials
# -------------------------------------
source /etc/github-repos-to-back-up/github-repos-to-back-up.sh
S3_ID=`cat /etc/github-backups-s3-creds/id`
S3_SECRET=`cat /etc/github-backups-s3-creds/secret`

log() {
  echo $1
  echo $1 >> ${LOGFILE}
}

do_backup() {
  ITEM=$1
  TYPE=$2

  OWNER_REPO=`echo $ITEM | cut -d ":" -f 1`
  MODE=`echo $ITEM | cut -d ":" -f 2`
  OWNER=`echo $OWNER_REPO | cut -d "/" -f 1`
  REPO=`echo $OWNER_REPO | cut -d "/" -f 2`
  THIS_BACKUP_DIR="${BACKUP_DIR}/${OWNER}"
  if [ ! -d $THIS_BACKUP_DIR ]; then mkdir -p $THIS_BACKUP_DIR; fi
  if [ ! -d ${THIS_BACKUP_DIR}/tmp ]; then mkdir -p ${THIS_BACKUP_DIR}/tmp; fi

  if [ "$TYPE" == "user" ]; then TYPEARG=""; else TYPEARG="--organization"; fi
  if [ "$MODE" == "full" ]; then QUALIFIER="--all"; else QUALIFIER="--repositories"; MODE="partial"; fi

  log "Starting $MODE backup of $REPO"

  # Make the backup
  # ---------------
  echo "github-backup -t \$TOKEN $OWNER $TYPEARG --output-directory $THIS_BACKUP_DIR $QUALIFIER --private --repository $REPO $INCREMENTAL"

  # Tar and compress the repo
  # -------------------------
  log "-  compressing backup"
  COMPRESSED_FILE="${REPO}.tar.gz"
  COMPRESSED_FILE_PATH="${THIS_BACKUP_DIR}/tmp/${COMPRESSED_FILE}"
  cd $THIS_BACKUP_DIR
  #tar czfp $BACKUP_DIR/tmp/$COMPRESSED_FILE $REPO

  # Send the file to the off-site storage
  # -------------------------------------
  log "-  copying $COMPRESSED_FILE to storage"
  #aws s3api put-object --bucket $BUCKET --key $COMPRESSED_FILE --body $COMPRESSED_FILE_PATH

  # Remove the archive file
  # -----------------------
  #rm $COMPRESSED_FILE_PATH

  log ""
}

for ITEM in ${ORG_REPOS_TO_BACK_UP[@]}; do
  do_backup "$ITEM" "org"
done

for ITEM in ${USER_REPOS_TO_BACK_UP[@]}; do
  do_backup "$ITEM" "user"
done


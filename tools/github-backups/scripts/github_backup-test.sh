#!/bin/sh
#
# github_backup.sh
#
# For the given GitHub orgs:
#   get a list of all repos in each org - for each repo:
#     get an updated copy
#     tar/compress the repo
#     put the repo archive file in S3 using the 'aws' CLI
# -------------------------------------------------------

ORGS=( bcgov-c BCDevOps )
TOKEN=
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

# Make backups for each org
# -------------------------
for org in ${ORGS[@]}; do

  log "Starting backups for org: $org"

  if [ ! -d $BASEDIR/$org ]; then mkdir $BASEDIR/$org; fi
  cd $BASEDIR/$org

  # Get a list of repos in this org; we'll back up each one
  # -------------------------------------------------------
  #REPOS=( `curl -s --header "Authorization: token $TOKEN" https//api.github.com/orgs/$org/repos | jq ".[].full_name" - | sed 's/"//g'` )
  REPOS=( platform-gitops-gen platform-registry-services )
  log "Found ${#REPOS[@]} repos in $org"

  for repo in ${REPOS[@]}; do

    log "$org / $repo"

    COMPRESSED_FILE="${repo}.tar.gz"

    # If we don't already have this repo locally, clone it
    # ----------------------------------------------------
    #if [ ! -d $repo ]; then
    #  log "  cloning repo"
    #  git clone --mirror https://github.com/${repo}.git

    # otherwise, update the local copy
    # --------------------------------
    #else
    #  log "  updating repo"
    #  cd $repo
    #  git fetch origin
    #  cd ..
    #fi

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

  log ""

done

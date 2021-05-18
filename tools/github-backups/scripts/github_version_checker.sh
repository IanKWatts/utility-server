#!/bin/sh
#
# github-version-checker.sh
#
# Check for updates to third-party software that we use and send out a 
# notification when a new version is released.
# --------------------------------------------------------------------


# Array of GitHub projects to check for version
#   The part before the colon is the GitHub repo
#   The part after the colon is the local app name, used in the Deployment link
# -----------------------------------------------------------------------------
PROJECTS=( palantir/policy-bot:policy palantir/bulldozer:bulldozer )
BASEDIR=/tmp/tools
TRACKERDIR="${BASEDIR}/github-version-checker"

if [ ! -d $BASEDIR ]; then mkdir $BASEDIR; fi
if [ ! -d $TRACKERDIR ]; then mkdir $TRACKERDIR; fi

for PROJECT in ${PROJECTS[@]}; do

  REPO=`echo $PROJECT | cut -d ":" -f 1`
  LOCAL_APP_NAME=`echo $PROJECT | cut -d ":" -f 2`
  echo "Checking $REPO"

  # Establish the filename for tracking the version of this repo
  # ------------------------------------------------------------
  FILENAME=`echo $REPO | sed 's/\//_/'`
  REPO_FILE="$TRACKERDIR/$FILENAME"

  # Get the previous version from the file, if we have run this test before
  # -----------------------------------------------------------------------
  if [ ! -f $REPO_FILE ] || [ -z $REPO_FILE ]; then
    LAST_VERSION="n/a"
    echo "$REPO_FILE does not exist.  Creating it..."
    touch $REPO_FILE
  else
    LAST_VERSION=`cat $REPO_FILE`
  fi

  # Get the current version
  # -----------------------
  CURRENT_VERSION=`curl -s https://api.github.com/repos/${REPO}/releases/latest | jq ".name"`
  echo "$CURRENT_VERSION" > $REPO_FILE

  if [ "$LAST_VERSION" != "$CURRENT_VERSION" ]; then
    echo "$REPO has been updated from $LAST_VERSION to $CURRENT_VERSION"
    echo "For redeployment, go to: https://console.apps.silver.devops.gov.bc.ca/k8s/ns/gitops-tools/deployments/${LOCAL_APP_NAME}"
  else
    echo "No change ($CURRENT_VERSION)"
  fi

  echo ""
  
done

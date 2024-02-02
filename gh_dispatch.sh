#!/bin/bash

REPO="test-actions-12121/action_called"

get_workflow_status() {
  local id=$1
  status=$(gh run list -R test-actions-12121/action_called  --json databaseId,status | jq -r --arg id "$id" '.[] | select(.databaseId==($id|tonumber)) | .status')
  echo $status
}

gh workflow run -r main -R $REPO called_workflow.yml -f imageName=abcd -f imageTag=V20240125
sleep 5 # sleep for workflow to be queued.
workflow_id=$(gh run list -R $REPO --json databaseId | jq '.[].databaseId' | head -1)
url=$(gh run list -R $REPO --json databaseId,url | jq -r --arg id "$workflow_id" '.[] | select(.databaseId==($id|tonumber)) | .url' )
echo Check the live status here: $url
echo Waiting for workflow to finish
while [ "$(get_workflow_status $workflow_id)" != "completed" ]; do
  echo -ne '.'
  sleep 1
done
echo
conclusion=$(gh run list -R test-actions-12121/action_called  --json databaseId,name,status,conclusion,startedAt,url | jq -r --arg id "$workflow_id" '.[] | select(.databaseId==($id|tonumber)) | .conclusion')
if [ "$conclusion" != "success" ]; then
  exit 1
fi

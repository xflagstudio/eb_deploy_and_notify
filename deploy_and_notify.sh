#!/bin/bash
set -ex

export SHA1=`echo ${CIRCLE_SHA1} | cut -c1-7`
export ENV=`echo $1 | rev | cut -d \- -f1 | rev`

: ${CHANNEL:=#test}

eb deploy $1 -v

if [ $? -eq 0 ]; then
    export SL_COLOR="good"
    export SL_TEXT="Success: Deployed ${CIRCLE_BRANCH} (<${CIRCLE_COMPARE_URL}|${SHA1}>) by ${CIRCLE_USERNAME} !!"
    export SL_ICON="https://www.cloudbees.com/sites/default/files/eleasticbeanstalk_square.png"
else
    export SL_COLOR="danger"
    export SL_TEXT="Failure: Deploying ${CIRCLE_BRANCH} (<${CIRCLE_COMPARE_URL}|${SHA1}>) by ${CIRCLE_USERNAME} !!"
    export SL_ICON="https://www.cloudbees.com/sites/default/files/eleasticbeanstalk_square.png"
fi

curl -X POST --data-urlencode 'payload={"username": "Elastic Beanstalk", "icon_url": "'"$SL_ICON"'", "channel": "$CHANNEL", "attachments": [{ "color": "'"$SL_COLOR"'", "text": "'"$SL_TEXT"'", "mrkdwn_in": ["text"] }] }' https://hooks.slack.com/services/${SLACK_HOOK}
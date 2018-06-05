#!/bin/bash
set -x

export SHA1=`echo ${CIRCLE_SHA1} | cut -c1-7`
export ENV=`echo $1 | rev | cut -d \- -f1 | rev`

function dd_mute() {
    if [[ ${DD_MUTE_ID+x} ]]; then
        echo "muting DD monitor id: ${DD_MUTE_ID}"
        curl -X POST "https://app.datadoghq.com/api/v1/monitor/${DD_MUTE_ID}/mute?api_key=${DD_API_KEY}&application_key=${DD_APP_KEY}"
    fi
}

function dd_unmute() {
    if [[ ${DD_MUTE_ID+x} ]]; then
        echo "un-muting DD monitor id: ${DD_MUTE_ID}"
        curl -X POST "https://app.datadoghq.com/api/v1/monitor/${DD_MUTE_ID}/unmute?api_key=${DD_API_KEY}&application_key=${DD_APP_KEY}"
    fi
}

function notify() {
    if [[ ${ROLLBAR_ACCESS_TOKEN+x} ]]; then
        echo "notifying rollbar"
        curl https://api.rollbar.com/api/1/deploy/ -F access_token=$ROLLBAR_ACCESS_TOKEN -F environment=$ENV -F revision=$CIRCLE_SHA1 -F local_username=$CIRCLE_USERNAME -F comment="$CIRCLE_BUILD_URL"
    fi
}

dd_mute

eb deploy $1 -v --timeout 15

if [ $? -eq 0 ]; then
    export SL_COLOR="good"
    export SL_TEXT="Success: Deployed ${CIRCLE_BRANCH} (<${CIRCLE_COMPARE_URL}|${SHA1}>) by ${CIRCLE_USERNAME} !!"
    export SL_ICON="https://www.cloudbees.com/sites/default/files/eleasticbeanstalk_square.png"
    export EXIT=0
    notify
else
    export SL_COLOR="danger"
    export SL_TEXT="Failure: Deploying ${CIRCLE_BRANCH} (<${CIRCLE_COMPARE_URL}|${SHA1}>) by ${CIRCLE_USERNAME} !!"
    export SL_ICON="https://www.cloudbees.com/sites/default/files/eleasticbeanstalk_square.png"
    export EXIT=1
fi

if [[ ${SLACK_HOOK+x} ]]; then
    curl -X POST --data-urlencode 'payload={"username": "Elastic Beanstalk ('"$CIRCLE_PROJECT_REPONAME"')", "icon_url": "'"$SL_ICON"'", "channel": "'"${CHANNEL:-#test}"'", "attachments": [{ "color": "'"$SL_COLOR"'", "text": "'"$SL_TEXT"'", "mrkdwn_in": ["text"] }] }' https://hooks.slack.com/services/${SLACK_HOOK}
fi

dd_unmute

exit $EXIT

# What

Elastic Beanstalkデプロイ＆通知スクリプト（CircleCI用）

- EB deploy
- slack通知
- Datadog監視一時中断
- rollbarデプロイ通知

# How

```.circleci/config.yml
      - run:
          name: Install awstools & deploy script
          command: |
            apk add --no-cache python py-pip
            pip install awscli==1.15.19 awsebcli==3.12.4
            wget https://git.io/xflag-eb_deploy_and_notify -O ~/eb_deploy_and_notify.sh
            chmod +x ~/eb_deploy_and_notify.sh
      - run:
          name: deploy
          shell: /bin/bash
          command: |
            set -e
            source ~/venv/bin/activate
            eb --version
            EB_ENV=`eb list | grep '*' | awk '{print $2}'`
            echo "${CIRCLE_BRANCH}" ; echo "${EB_ENV}"
            ~/eb_deploy_and_notify.sh ${EB_ENV}
```

# Notes

`SLACK_HOOK` の部分に注意 - `https://hooks.slack.com/services/${SLACK_HOOK}`

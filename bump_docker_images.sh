#!/bin/bash

OLD_VERSION="${1?: Please define an old version}"
NEW_VERSION="${2?: Please define a new version}"

MAJOR_VERSION="$(echo "$NEW_VERSION" | cut -d'.' -f1)"

docker tag relintdockerhubpushbot/cf-deployment-concourse-tasks:latest relintdockerhubpushbot/cf-deployment-concourse-tasks:$NEW_VERSION
docker tag relintdockerhubpushbot/cf-deployment-concourse-tasks:latest relintdockerhubpushbot/cf-deployment-concourse-tasks:$MAJOR_VERSION

docker push relintdockerhubpushbot/cf-deployment-concourse-tasks:$NEW_VERSION
docker push relintdockerhubpushbot/cf-deployment-concourse-tasks:$MAJOR_VERSION

perl -pi -e "s/$OLD_VERSION/$NEW_VERSION/g" **/task.yml
git add */task.yml

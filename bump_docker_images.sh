#!/bin/bash

OLD_VERSION="${1?: Please define an old version}"
NEW_VERSION="${2?: Please define a new version}"

MAJOR_VERSION="$(echo "$NEW_VERSION" | cut -d'.' -f1)"

docker tag cloudfoundry/cf-deployment-concourse-tasks:latest cloudfoundry/cf-deployment-concourse-tasks:$NEW_VERSION
docker tag cloudfoundry/cf-deployment-concourse-tasks:latest cloudfoundry/cf-deployment-concourse-tasks:$MAJOR_VERSION

docker push cloudfoundry/cf-deployment-concourse-tasks:$NEW_VERSION
docker push cloudfoundry/cf-deployment-concourse-tasks:$MAJOR_VERSION

perl -pi -e "s/$OLD_VERSION/$NEW_VERSION/g" **/task.yml
git add */task.yml

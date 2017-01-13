# cf-deployment-concourse-tasks
This repo contains concourse tasks for use with [cf-deployment][cf-deployment-repo].
Each task is in its own directory.
A task will generally be composed of a task.yml to be referenced in pipelines,
a supporting task.bash (or .rb, .go, etc.) file,
and a Dockerfile.
The Dockerfile is built and pushed to Dockerhub regularly
along with many other images
in CI maintained by the CF Release Integration team [here][runtime-ci-build-docker-images].

It should be clear how to use each task
from the task.yml
and the description below.
If you find that it is not,
please contact the Release Integration team
in our [Slack channel dedicated to supporting users of `cf-deployment`][cf-deployment-slack-channel].
Alternatively, you can [open an issue][issues-page].


## Tasks

### bosh-upload-stemcell
This takes `cf-deployment`
and bosh targeting information as inputs.
It determines which stemcell version to upload
by reading from `cf-deployment`.
`INFRASTRUCTURE` needs to be set to
`aws`, `google`, or `bosh-lite`.
Other IaaSs are not supported by this task.

[cf-deployment-repo]: https://github.com/cloudfoundry/cf-deployment
[runtime-ci-build-docker-images]: https://runtime.ci.cf-app.com/teams/main/pipelines/build-docker-images
[cf-deployment-slack-channel]: https://cloudfoundry.slack.com/messages/cf-deployment/
[issues-page]: https://github.com/cloudfoundry/cf-deployment-concourse-tasks/issues

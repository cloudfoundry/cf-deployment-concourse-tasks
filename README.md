# cf-deployment-concourse-tasks

<The way this document looks in the raw
is intentional.
For a discussion of the intention,
Please see
https://github.com/JesseTAlford/texts/blob/master/the-art-of-markdown.md>

This repo contains concourse tasks for use with [cf-deployment][cf-deployment-repo].
Each task is in its own directory.
A task will generally be composed of a task.yml to be referenced in pipelines,
a supporting task file, and a Dockerfile.
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
Tasks are listed here alphabetically,
along with a brief description
meant to be used alongside the `task.yml` within each task directory
to understand the task's
purpose, interface, and options.

### bbl-destroy
#### Inputs
#### Outputs
#### Parameters

### bbl-up
#### Inputs
#### Outputs
#### Parameters

### bosh-deploy
#### Inputs
#### Outputs
#### Parameters

### bosh-deploy-with-created-release

This task creates and applies an additional operations file to `cf-deployment.yml`,
which causes BOSH to
create, upload, and use a dev release
from the provided release folder
in place of the version specified in `cf-deployment.yml`.
This is useful for testing an upstream component.

#### Inputs

* `bbl-state`: Resource containing the BOSH director's `bbl-state.json`
* `cf-deployment`: Resource containing a cf-deployment manifest
* `cf-deployment-concourse-tasks`: This repo
* `ops-files`: Resource containing operations files which are to be applied to this deployment
* `release`: The repository of the BOSH release under test
* `vars-store`: Resource containing the BOSH deployment's vars-store yaml file

#### Outputs

* `updated-vars-store`: A directory for containing the updated vars-store yaml file as a git commit

#### Parameters
* `BBL_STATE_DIR`:
  * description: Base path to the directory containing the `bbl-state.json` file.
  The default behavior will look for a `bbl-state.json` file at the root of the `bbl-state` input
* `MANIFEST_FILE`:
  * required
  * default: `cf-deployment.yml`
  * description: File path to the `cf-deployment.yml` manifest
* `OPS_FILES`:
  * default: `opsfiles/gcp.yml`
  * description: A quoted space-separated list of operations file to be applied to this deployment.
* `SYSTEM_DOMAIN`:
  * required
  * description: The CF system base domain e.g. `my-cf.com`
* `VARS_STORE_PATH`:
  * required
  * default: `deployment-vars.yml`
  * description: File path to the BOSH deployment vars-store yaml file

### bosh-upload-stemcell
This takes `cf-deployment`
and BOSH targeting information as inputs.
It determines which stemcell version to upload
by reading from `cf-deployment`.
`INFRASTRUCTURE` needs to be set to
`aws`, `google`, or `bosh-lite`.
Other IaaSs are not supported by this task.

#### Inputs
#### Outputs
#### Parameters

### update-integration-configs
#### Inputs
#### Outputs
#### Parameters

[cf-deployment-repo]: https://github.com/cloudfoundry/cf-deployment
[runtime-ci-build-docker-images]: https://runtime.ci.cf-app.com/teams/main/pipelines/build-docker-images
[cf-deployment-slack-channel]: https://cloudfoundry.slack.com/messages/cf-deployment/
[issues-page]: https://github.com/cloudfoundry/cf-deployment-concourse-tasks/issues
[deploy-with-created-lines]: https://github.com/cloudfoundry/cf-deployment-concourse-tasks/blob/master/bosh-deploy-with-created-release/task#L49-L55

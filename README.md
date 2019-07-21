# cf-deployment-concourse-tasks
This repo contains concourse tasks for use with [cf-deployment][cf-deployment-repo].
If you are trying to deploy to IAAS, you may wish to check the [Deployment Guide][deployment-guide].
Each task is in its own directory.
A task will generally be composed of a task.yml to be referenced in pipelines,
a supporting task file, and a Dockerfile.
The Dockerfile is built and pushed to Dockerhub regularly
in CI maintained by the CF Release Integration team [here][runtime-ci-build-docker-images].

It should be clear how to use each task
from the task.yml
and the description below.
If you find that it is not,
please contact the Release Integration team
in our [Slack channel dedicated to supporting users of `cf-deployment`][cf-deployment-slack-channel].
Alternatively, you can [open an issue][issues-page].

### Versioning of this repo
Development updates to the repo are made to the `master` branch,
so untested or backwards incompatible changes may be present there.
Once changes have been tested and all stories accepted,
we add new version tags such as `v1.6` to the approprate commit.

We use a bare-bones type of [semantic versioning](http://semver.org/) for this repo.
Backwards incompatible changes warrant a major version bump (e.g. `v1.6` to `v2.0`),
while other changes will simply add a minor version bump (e.g. `v2.0` to `v2.1`).

In Concourse, you can pretty easily lock to a major version,
meaning that your pipeline will take minor (i.e. backwards compatible) changes only.
Here's an example from our [nats release pipeline](https://github.com/cloudfoundry/runtime-ci/blob/5e4d8a384c9e9fc7ddc052cd8c21503d40d29851/pipelines/nats-release.yml#L91-L96):
```
- name: cf-deployment-concourse-tasks
  type: git
  source:
    branch: master
    uri: https://github.com/cloudfoundry/cf-deployment-concourse-tasks.git
    tag_filter: v3.*
```

When you're ready to take the backwards _incompatible_ changes,
you can take any necessary manual steps to upgrade,
and then change the major version in your pipeline configuration.


## Tasks
Tasks are listed here alphabetically,
along with a brief description
meant to be used alongside the `task.yml` within each task directory
to understand the tasks'
purpose, interface, and options.
Each title is also a link
to the appropriate task.yml.

### [bbl-destroy][bbl-destroy-task-yaml]
This destroys the director
and infrastructure
created by [bbl](https://github.com/cloudfoundry/bosh-bootloader).
Debug output
is written to
bbl_destroy.txt
to help debug failures
in this task.

### [bbl-up][bbl-up-task-yaml]
This uses [bbl](https://github.com/cloudfoundry/bosh-bootloader)
to create your infrastructure
and deploy a BOSH director.
Debug output
is written to
`bbl_plan.txt` and
`bbl_up.txt`
to help debug failures
in this task.
This task requires
a certificate and key
(unless you are `bbl`ing up a bosh-lite environment)
which can be generated using
the commands specified [here][deployment-guide-on-certificates].

### [bosh-cleanup][bosh-cleanup-task-yaml]
This performs a BOSH cleanup
which is necessary
from time to time
to avoid
running out of space.

### [bosh-delete-deployment][bosh-delete-deployment-task-yaml]
This deletes a BOSH deployment.
If you want to delete all of the available BOSH deployments you can set the `DELETE_ALL_DEPLOYMENTS` flag to `true`.

### [bosh-deploy][bosh-deploy-task-yaml]
This performs a BOSH upload-stemcell and BOSH deployment.
Optionally, operations files may be applied
to the deployment manifest.

It's also configurable to
regenerate deployment credentials
on each deployment
though this is not the default behavior.
This is helpful for testing
changes to variable generation,
but is only expected to work
with fresh deployments.
This also automatically uploads the stemcells present in deployment.
If you're deploying to **bosh-lite** environment you need to set the
`BOSH_LITE` flag to `true` so the task uploads the correct stemcell(s).

### [bosh-deploy-with-created-release][bosh-deploy-with-created-release-task-yaml]
This creates and applies an
additional operations file to `cf-deployment.yml`,
which causes BOSH to
create, upload, and use a dev release
from the provided release folder
in place of the version specified in `cf-deployment.yml`.
This is useful for testing an upstream component.
Otherwise identical to the `bosh-deploy` task above.

### [bosh-deploy-with-updated-release-submodule](bosh-deploy-with-updated-release-submodule/task.yml)
This takes as input
a concourse resource
for the submodule version bumped
when creating a dev release
from the provided release folder.
Otherwise identical to the `bosh-deploy-with-created-release` task above.

### [bosh-upload-release][bosh-upload-release-task-yaml]
This uploads a single release to the BOSH director.

### [bosh-upload-stemcells][bosh-upload-stemcells-task-yaml]
This uploads stemcell(s) associated with the manifest and/or ops files provided.
This task can be used to upload stemcells within jobs that do not contain a bosh-deploy* task (which handles uploading stemcells as well as executing the bosh deployment). 

### [collect-ops-files][collect-ops-files]
This collects
two sets of operations files.
The first set is the "base" set,
to which the second ("new") set is added.

If there is a name conflict,
the operations file
from the second ("new") set
wins.

### [run-cats][run-cats-task-yaml]
This runs [CF Acceptance Tests](https://github.com/cloudfoundry/cf-acceptance-tests)
against a CF environment specified by the CATs integration file.

### [run-cats-with-provided-cli][run-cats-with-provided-cli-task-yaml]
This runs [CF Acceptance Tests](https://github.com/cloudfoundry/cf-acceptance-tests)
with the provided CF CLI binary.

### [run-errand][run-errand-yaml]
This runs a bosh errand
with the provided deployment and errand name.

### [set-feature-flags][set-feature-flags-task-yaml]
This will
toggle
the specified feature-flags
based on their boolean values.

### [update-integration-configs][update-integration-configs-task-yaml]
This updates integration files
to be consumed by CATs and RATs
with credentials drawn from
CredHub.

### [open-asgs-for-bosh-instance-group][open-asgs-for-bosh-instance-group-task-yaml]
This opens Application Security Groups for BOSH
instance groups.

[bbl-destroy-task-yaml]: bbl-destroy/task.yml
[bbl-up-task-yaml]: bbl-up/task.yml
[bosh-cleanup-task-yaml]: bosh-cleanup/task.yml
[bosh-deploy-task-yaml]: bosh-deploy/task.yml
[bosh-deploy-with-created-release-task-yaml]: bosh-deploy-with-created-release/task.yml
[bosh-delete-deployment-task-yaml]: bosh-delete-deployment/task.yml
[bosh-upload-release-task-yaml]: bosh-upload-release/task.yml
[bosh-upload-stemcells-task-yaml]: bosh-upload-stemcells/task.yml
[bosh-upload-stemcell-from-cf-deployment-task-yaml]: bosh-upload-stemcell-from-cf-deployment/task.yml
[cf-deployment-repo]: https://github.com/cloudfoundry/cf-deployment
[cf-deployment-slack-channel]: https://cloudfoundry.slack.com/messages/cf-deployment/
[collect-ops-files]: collect-ops-files/task.yml
[deploy-with-created-lines]: bosh-deploy-with-created-release/task#L49-L55
[deployment-guide]: https://github.com/cloudfoundry/cf-deployment/blob/develop/deployment-guide.md
[deployment-guide-on-certificates]: https://github.com/cloudfoundry/cf-deployment/blob/develop/deployment-guide.md#on-certificates
[issues-page]: https://github.com/cloudfoundry/cf-deployment-concourse-tasks/issues
[run-cats-task-yaml]: run-cats/task.yml
[run-cats-with-provided-cli-task-yaml]: run-cats-with-provided-cli/task.yml
[run-errand-yaml]: run-errand/task.yml
[runtime-ci-build-docker-images]: https://runtime.ci.cf-app.com/teams/main/pipelines/build-docker-images?groups=cf-deployment-concourse-tasks
[set-feature-flags-task-yaml]: set-feature-flags/task.yml
[update-integration-configs-task-yaml]: update-integration-configs/task.yml
[open-asgs-for-bosh-instance-group-task-yaml]:  open-asgs-for-bosh-instance-group/task.yml

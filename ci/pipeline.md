# cf-deployment-concourse-tasks

## Context 
Changes to the tasks are actually tested by having our cf-d pipeline consume cf-dt/master so we get to see problems early.

notify-bbl-updates; this job notifies the team if/when bbl (and in this pipeline we are interested in bbl cli) changes occur.
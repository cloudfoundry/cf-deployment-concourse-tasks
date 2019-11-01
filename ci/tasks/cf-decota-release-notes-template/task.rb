#!/usr/bin/env ruby

require 'hashdiff'
require_relative './binary_changes.rb'
require_relative './task_updates.rb'
require_relative './renderer.rb'

template = Renderer.new.render(
  binary_updates: BinaryUpdates.new(
  'cf-deployment-concourse-tasks-latest-release/dockerfiles/cf-deployment-concourse-tasks/Dockerfile',
  'cf-deployment-concourse-tasks/dockerfiles/cf-deployment-concourse-tasks/Dockerfile'
  ),
  task_updates: TaskUpdates.new(
    'cf-deployment-concourse-tasks-latest-release',
    'cf-deployment-concourse-tasks'
  )
)

puts template

output_folder = 'release-notes-template'
File.write("#{output_folder}/template", template)

version = File.read("release-version/version")
File.write("#{output_folder}/name", "v#{version}")

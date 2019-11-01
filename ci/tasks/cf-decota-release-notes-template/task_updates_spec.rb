require 'rspec'
require_relative './task_updates.rb'

describe 'TaskUpdates' do
  subject { TaskUpdates.new('latest-release', 'master') }

  before(:all) do
    @current_work_dir = Dir.pwd
    @tmp_work_dir = Dir.mktmpdir('test-cf-deployment-concourse-tasks')

    Dir.chdir(@tmp_work_dir)
    FileUtils.mkdir_p('master/new-task')
    FileUtils.mkdir_p('master/updated-task')
    FileUtils.mkdir_p('latest-release/updated-task')
    FileUtils.mkdir_p('latest-release/deleted-task')
  end

  after(:all) do
    Dir.chdir(@current_work_dir)
    FileUtils.rm_rf(@tmp_work_dir) if File.exist?(@tmp_work_dir)
  end

  context 'when there are tasks in the lop-level directory' do
    before do
      File.open('master/updated-task/task.yml', 'w')
      File.open('latest-release/updated-task/task.yml', 'w')
    end

    context 'and only task.yml docker image tag version has changed' do
      before do
        File.open('master/updated-task/task.yml', 'w') do |f|
          f.write(task_yml_content("2.2.2"))
        end
        File.open('latest-release/updated-task/task.yml', 'w') do |f|
          f.write(task_yml_content("1.1.1"))
        end
      end

      def task_yml_content(tag_version)
<<-HEREDOC
---
platform: linux
image_resource:
  type: docker-image
  source:
    repository: relintdockerhubpushbot/cf-deployment-concourse-tasks
    tag: v#{tag_version}
inputs:
- name: cf-deployment-concourse-tasks
run:
  path: cf-deployment-concourse-tasks/bbl-destroy/task
params:
  BBL_STATE_DIR: bbl-state
HEREDOC
      end

      it 'returns a map with no changes' do
        expect(subject.new_tasks).to be_empty
        expect(subject.deleted_tasks).to be_empty
        expect(subject.updated_tasks).to be_empty
      end
    end

    context 'and there valid changes to the task' do
      before do
        File.open('master/new-task/task.yml', 'w')
        File.open('latest-release/deleted-task/task.yml', 'w')
        File.open('latest-release/updated-task/task.sh', 'w')
      end

      it 'returns a map with three lists of changes' do
        expect(subject.new_tasks).to contain_exactly('new-task')
        expect(subject.deleted_tasks).to contain_exactly('deleted-task')
        expect(subject.updated_tasks).to contain_exactly('updated-task')
      end
    end
  end
end

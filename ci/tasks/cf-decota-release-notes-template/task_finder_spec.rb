require 'rspec'
require_relative './task_finder.rb'

describe 'TaskFinder' do
  subject { TaskFinder.find_tasks('test-cf-deployment-concourse-tasks') }

  before(:all) do
    @current_work_dir = Dir.pwd
    @tmp_work_dir = Dir.mktmpdir('test-cf-deployment-concourse-tasks')

    Dir.chdir(@tmp_work_dir)
    FileUtils.mkdir_p('test-cf-deployment-concourse-tasks/task1')
    FileUtils.mkdir_p('test-cf-deployment-concourse-tasks/task2')
    FileUtils.mkdir_p('test-cf-deployment-concourse-tasks/dockerfiles')
  end

  after(:all) do
    Dir.chdir(@current_work_dir)
    FileUtils.rm_rf(@tmp_work_dir) if File.exist?(@tmp_work_dir)
  end

  context 'when there are tasks in the lop-level directory' do
    before do
      File.open('test-cf-deployment-concourse-tasks/task1/task.yml', 'w')
      File.open('test-cf-deployment-concourse-tasks/task2/task.yml', 'w')
      File.open('test-cf-deployment-concourse-tasks/dockerfiles/Dockerfile', 'w')
      File.open('test-cf-deployment-concourse-tasks/README.md', 'w')
    end

    it 'returns the file names of the tasks without any additional path' do
      expect(subject).to contain_exactly 'task1', 'task2'
    end
  end
end

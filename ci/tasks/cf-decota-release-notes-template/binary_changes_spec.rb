require 'tmpdir'
require 'rspec'
require 'fileutils'
require_relative './binary_changes.rb'

describe 'BinaryUpdates' do
  before(:all) do
    @current_work_dir = Dir.pwd
    @tmp_work_dir = Dir.mktmpdir('cf-deployment-concourse-tasks-test')

    Dir.chdir(@tmp_work_dir)
  end

  after(:all) do
    Dir.chdir(@current_work_dir)
    FileUtils.rm_rf(@tmp_work_dir) if File.exists?(@tmp_work_dir)
  end

  let(:ru) { BinaryUpdates.new }

  describe 'load_from_file' do
    before(:all) do
      FileUtils.mkdir_p('cf-deployment-concourse-tasks-latest-release/dockerfiles/cf-deployment-concourse-tasks/')
      FileUtils.mkdir_p('cf-deployment-concourse-tasks/dockerfiles/cf-deployment-concourse-tasks/')
    end

    subject(:updates) do
      BinaryUpdates.new(
        "cf-deployment-concourse-tasks-latest-release/#{filename}",
        "cf-deployment-concourse-tasks/#{filename}"
      )
    end

    before do
      File.open(File.join('cf-deployment-concourse-tasks-latest-release', filename), 'w') do |f|
        f.write(file_contents_latest_release)
      end

      File.open(File.join('cf-deployment-concourse-tasks', filename), 'w') do |f|
        f.write(file_contents_current)
      end
    end

    let(:filename) { 'dockerfiles/cf-deployment-concourse-tasks/Dockerfile' }
    let(:file_contents_latest_release) do
<<-HEREDOC
ENV JQ_VERSION 1.5
ENV go_version 1.11.1
ENV cf_cli_version 6.40.0
ENV bosh_cli_version 5.3.1
ENV bbl_version 6.10.18
ENV terraform_version 0.11.10
ENV credhub_cli_version 2.1.0
ENV git_crypt_version 0.6.0
HEREDOC
    end

    let(:file_contents_current) do
<<-HEREDOC
ENV JQ_VERSION 1.6
ENV go_version 1.12.5
ENV cf_cli_version 6.43.0
ENV bosh_cli_version 5.5.1
ENV bbl_version 8.0.0
ENV terraform_version 0.12.0
ENV credhub_cli_version 2.4.0
ENV git_crypt_version 0.6.0
HEREDOC
    end

    it 'reads the given file in the two inputs, and returns the binary updates' do
      expect(updates.count).to eq 7

      go_release_update = updates.get_update_by_name('go')

      expect(go_release_update.old_version).to eq '1.11.1'
      expect(go_release_update.new_version).to eq '1.12.5'

      cf_cli_release_update = updates.get_update_by_name('cf_cli')

      expect(cf_cli_release_update.old_version).to eq '6.40.0'
      expect(cf_cli_release_update.new_version).to eq '6.43.0'

      bosh_cli_release_update = updates.get_update_by_name('bosh_cli')

      expect(bosh_cli_release_update.old_version).to eq '5.3.1'
      expect(bosh_cli_release_update.new_version).to eq '5.5.1'

      bbl_update = updates.get_update_by_name('bbl')

      expect(bbl_update.old_version).to eq '6.10.18'
      expect(bbl_update.new_version).to eq '8.0.0'

      terraform_update = updates.get_update_by_name('terraform')

      expect(terraform_update.old_version).to eq '0.11.10'
      expect(terraform_update.new_version).to eq '0.12.0'

      credhub_cli_update = updates.get_update_by_name('credhub_cli')

      expect(credhub_cli_update.old_version).to eq '2.1.0'
      expect(credhub_cli_update.new_version).to eq '2.4.0'

      jq_update = updates.get_update_by_name('jq')

      expect(jq_update.old_version).to eq '1.5'
      expect(jq_update.new_version).to eq '1.6'
    end

    context 'when the old version of the file is empty' do
      let(:file_contents_latest_release) { "" }
      context 'and the new version is not empty' do
        let(:file_contents_current) do
<<-HEREDOC
ENV go_version 1.12.5
HEREDOC
        end

        it 'views the newly-introduced binary as additive updates' do
          binary_update = updates.get_update_by_name('go')
          expect(binary_update.old_version).to eq nil
          expect(binary_update.new_version).to eq "1.12.5"
        end
      end

      context 'and the new version is empty' do
        let(:file_contents_current) { "" }

        it 'includes no information about the binary' do
          expect(updates.get_update_by_name('go')).to be_nil
        end
      end
    end

    context 'when the new version of the file is empty' do
      let(:file_contents_current) { "" }
      context 'and the old version is not empty' do
        let(:file_contents_latest_release) do
<<-HEREDOC
ENV go_version 1.12.5
HEREDOC
        end

        it 'views the removed binary as negative updates' do
          binary_update = updates.get_update_by_name('go')
          expect(binary_update.old_version).to eq "1.12.5"
          expect(binary_update.new_version).to eq nil
        end
      end

      context 'and the new version is empty' do
        let(:file_contents_latest_release) { "" }

        it 'includes no information about the binary' do
          expect(updates.get_update_by_name('go')).to be_nil
        end
      end
    end
  end
end

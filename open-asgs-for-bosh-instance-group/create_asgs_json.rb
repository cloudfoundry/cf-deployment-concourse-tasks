#!/usr/bin/ruby -w
# frozen_string_literal: true

require 'json'
require 'open3'

PRIVATE_IP_REGEX = /^10\./.freeze

def write_asgs_json(instance_group_ips, destination_file)
  asgs = []

  instance_group_ips.each do |ip|
    asgs << { protocol: 'tcp', destination: ip, ports: '1-65535' }
  end

  File.open(destination_file, 'w') do |f|
    f.write(asgs.to_json)
  end
end

def get_ips_from_bosh_output(instance_group_name)
  instance_ips = []

  stdout, stderr, exitcode = Open3.capture3('\bosh is --json')

  raise "'bosh is --json' returned an error: #{stdout}\n#{stderr}" if exitcode != 0

  instances = JSON.parse(stdout)['Tables'].first['Rows']
  instance_ips = get_instance_ips(instances, instance_group_name)

  raise 'No IPs detected' if instance_ips.empty?

  instance_ips
end

def get_instance_ips(instances, instance_group_name)
  filtered_instances = instances.select do |is|
    is['instance'].include? instance_group_name
  end

  filtered_instances.flat_map { |is| is['ips'].split.grep PRIVATE_IP_REGEX }
end

raise 'BOSH_DEPLOYMENT is required, but not set' unless ENV['BOSH_DEPLOYMENT']

instance_name, destination_file = ARGV

instance_group_ips = get_ips_from_bosh_output(instance_name)
write_asgs_json(instance_group_ips, destination_file)

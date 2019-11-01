require 'hashdiff'

class HashDiffChange
  attr_accessor :value

  OPERATION = 0
  VALUE = 2

  def initialize(hash_diff)
    @operation = hash_diff[OPERATION]
    @value = hash_diff[VALUE]
  end

  def isAddition?
    @operation == '+'
  end

  def isDeletion?
    @operation == '-'
  end
end

class BinaryUpdate
  attr_accessor :old_version, :new_version
end

class BinaryUpdates
  NAME_INDEX = 0
  VERSION_INDEX = 1

  def initialize(latest_path, master_path)
    @updates = {}

    binary_current_list = collect_binaries(master_path)
    binary_latest_release_list = collect_binaries(latest_path)
    diff_list = HashDiff.diff(binary_latest_release_list, binary_current_list)
    change_list = diff_list.map { |diff| HashDiffChange.new(diff) }
    change_list.each do |change|
      update_binary_changes(change)
    end
  end

  def get_update_by_name(binary_name)
    @updates[binary_name]
  end

  def count
    @updates.count
  end

  def each
    @updates.sort.each do |binary_name, binary_update|
      yield binary_name, binary_update
    end
  end

  def merge!(updates2)
    updates2.each do |binary_name, binary_update|
      @updates[binary_name] = binary_update
    end
  end

  private

  def collect_binaries(dockerfile_path)
    binaries = `grep -i 'ENV .*_version' #{dockerfile_path} | awk '{print tolower($0)}' | awk 'gsub("_version", "")' | awk '{print $2 ":" $3}'`
    binaries.split("\n").map do |b|
      {
        "name" => b.split(":")[NAME_INDEX],
        "version" => b.split(":")[VERSION_INDEX]
      }
    end
  end

  def update_binary_changes(change)
    if !change.isAddition? && !change.isDeletion?
      return
    end

    name = change.value['name']
    version = change.value['version']

    binary_update = @updates[name] || BinaryUpdate.new

    if change.isAddition?
      binary_update.new_version = version
    elsif change.isDeletion?
      binary_update.old_version = version
    end

    @updates[name] = binary_update
  end
end

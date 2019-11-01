class Renderer
  def render(binary_updates:, task_updates:)
    binaries_table = render_table(binary_updates)

<<-HEREDOC
## Notices
### :point_right: New Tasks :point_left:
#{render_tasks(task_updates.new_tasks)}

### :point_right: Updated Tasks :point_left:
#{render_tasks(task_updates.updated_tasks)}

### :point_right: Deleted Tasks :point_left:
#{render_tasks(task_updates.deleted_tasks)}

## Binary Updates
#{binaries_table}
HEREDOC
  end

  private

  def render_table(binary_updates)
    header = <<-HEADER
| Binary | Old Version | New Version |
| ------- | ----------- | ----------- |
HEADER

    table = ""
    binary_updates.each do |binary_name, binary_update|
      table << "| #{binary_name} | #{render_version(binary_update, 'old')} | #{render_version(binary_update, 'new')} |\n"
    end
    "#{header}#{table}"
  end

  def render_version(binary_update, type)
    return binary_update.send(type + '_version')
  end

  def render_tasks(tasks)
    if tasks.nil?
      return ""
    end

    tasks.sort.map do |task|
      "-**`#{task}`**"
    end.join("\n")
  end
end

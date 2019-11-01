class TaskFinder
  def self.find_tasks(repo_dir)
    tasks = Dir.glob(
      File.join(repo_dir, '*', 'task.yml')
    )
    task_list = tasks.select { |fd| File.file?(fd) }
    task_list.map { |task| task.gsub!("#{repo_dir}/", '').gsub!("/task.yml", '') }
  end
end

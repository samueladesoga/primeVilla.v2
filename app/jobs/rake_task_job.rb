class RakeTaskJob < ApplicationJob
  queue_as :default

  def perform(task_name)
    unless Rake::Task.task_defined?(task_name)
      Rails.application.load_tasks
    end

    Rake::Task[task_name].reenable
    Rake::Task[task_name].invoke
  end
end
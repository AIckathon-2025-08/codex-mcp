require 'standalone_migrations'
require 'fileutils'

# Configure database path
task :configure_db do
  db_path = ENV['CODEX_DB_PATH'] || File.join(Dir.home, '.codex', 'state.sqlite3')
  db_dir = File.dirname(db_path)

  FileUtils.mkdir_p(db_dir) unless File.directory?(db_dir)
  ENV['DATABASE_URL'] = "sqlite3://#{db_path}"

  puts "📦 Using database: #{db_path}"
end

# Load migration tasks
StandaloneMigrations::Tasks.load_tasks

# Make db tasks depend on configure
Rake::Task.tasks.each do |task|
  if task.name.start_with?('db:') && task.name != 'configure_db'
    task.enhance(['configure_db'])
  end
end

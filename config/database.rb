require 'active_record'
require 'logger'
require 'fileutils'

# Get database path from environment
DB_PATH = ENV['CODEX_DB_PATH'] || File.join(Dir.home, '.codex', 'state.sqlite3')

# Ensure directory exists
FileUtils.mkdir_p(File.dirname(DB_PATH))

# Setup logger
db_logger = Logger.new($stdout)
db_logger.level = Logger::INFO

# Establish connection
ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: DB_PATH,
  pool: 5,
  timeout: 5000
)

ActiveRecord::Base.logger = db_logger

puts "🗄️  Database connected: #{DB_PATH}"

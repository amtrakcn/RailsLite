require 'sqlite3'

class DBConnection
  def self.open(db_file_name)
    # if ENV["DATABASE_TYPE"] == "sqlite3"
      @db = SQLite3::Database.new(db_file_name)
    # elsif ENV["DATABASE_TYPE"] == "postgres"
      # @db = Postgres::Database.new(db_file_name)
    # end
    
    @db.results_as_hash = true
    @db.type_translation = true
    @db
  end

  def self.execute(*args)
    @db.execute(*args)
  end

  def self.last_insert_row_id
    @db.last_insert_row_id
  end

  private
  def initialize(db_file_name)
  end
end

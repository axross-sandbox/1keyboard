# Initializing database script
# Run this ruby script before start app.rb
require 'sqlite3'

=begin
- master.sqlite3
  - users
    - id INTEGER
    - name TEXT
    - image_url TEXT
    - github_url TEXT
    - color TEXT
    - fontsize INTEGER
    - created INTEGER
- databases/[channel].sqlite3
  - members
    - id INTEGER
    - user_id INTEGER
    - hash TEXT
  - codes
    - id INTEGER
    - code TEXT
    - created INTEGER
  - chats
    - id INTEGER
    - message TEXT
    - user_id INTEGER
    - created INTEGER
=end

def sqlite(dbname)
  db = SQLite3::Database.new dbname + '.sqlite3'
  yield db
  db.close
end

if File.exist? 'master.sqlite3'
  File.delete 'master.sqlite3'
  puts '  # master.sqlite3が既に存在したので削除しました'
end

sqlite 'master' do |db|
  db.execute(<<-SQL
    CREATE TABLE users (
      id INTEGER UNIQUE NOT NULL,
      name TEXT NOT NULL,
      image_url TEXT NOT NULL,
      github_url TEXT NOT NULL,
      color TEXT NOT NULL,
      fontsize INTEGER NOT NULL,
      created INTEGER NOT NULL
    );
  SQL
  )
end

if !Dir.exist? 'databases'
  Dir.mkdir 'databases'
  puts '  # databasesフォルダがなかったので作成しました'
end

Dir.chdir 'databases' do
  3.times do |i|
    dbname = (i + 1).to_s

    if File.exist? dbname + '.sqlite3'
      File.delete dbname + '.sqlite3'
      puts '  # ' + dbname + '.sqlite3が既に存在したので削除しました'
    end

    sqlite dbname do |db|
      db.execute(<<-SQL
        CREATE TABLE members (
          id INTEGER PRIMARY KEY,
          user_id INTEGER NOT NULL,
          hash TEXT
        );
        SQL
      )

      db.execute(<<-SQL
        CREATE TABLE codes (
          id INTEGER PRIMARY KEY,
          code TEXT NOT NULL,
          created INTEGER NOT NULL
        );
        SQL
      )

      db.execute(<<-SQL
        CREATE TABLE messages (
          id INTEGER PRIMARY KEY,
          message TEXT NOT NULL,
          user_id INTEGER NOT NULL,
          created INTEGER NOT NULL
        );
        SQL
      )
    end

    puts '  # ' + dbname + '.sqlite3を作成しました'
  end
end

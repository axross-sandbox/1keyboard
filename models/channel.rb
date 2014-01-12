class Channel
  attr_reader :name
  private_class_method :new

  def sqlite
    db = SQLite3::Database.new 'databases/' + @name + '.sqlite3'
    db.results_as_hash = true
    yield db
    db.close
  end

  def self.init(channel)
    channel = channel.to_s
    dbfile = 'databases/' + channel + '.sqlite3'

    if !channel.empty?
      if File.exist? dbfile
        new channel
      else
        nil
      end
    else
      nil
    end
  end

  def initialize(channel)
    @name = channel.to_s
  end

  def code=(code)
    code = code.to_s

    sqlite do |db|
      db.execute(
        'INSERT INTO codes(code, created) VALUES(?, ?);',
        [code, Time.now.to_i]
      )
    end
  end

  def code
    code = ''

    sqlite do |db|
      db.execute(
        'SELECT code FROM codes ORDER BY id DESC LIMIT 1;'
      ) do |row|
        code = row['code'].to_s
      end
    end

    code
  end

  def get_messages(count)
    count = count.to_i
    messages = []

    sqlite do |db|
      db.execute(
        'SELECT message, user_id, created FROM messages ORDER BY id DESC LIMIT ?;',
        [count]
      ) do |row|
        user = User.init(row['user_id'])
        if user
          row['name'] = user.name
          row['image_url'] = user.image_url
          row['github_url'] = user.github_url
          row['color'] = user.color
          row['fontsize'] = user.fontsize
          row['created'] = Time.at(row['created'].to_i)
          row['time'] = Time.at(row['created'].to_i).strftime('%H:%M:%S')

          messages.push row
        end
      end
    end

    messages
  end

  def post_message(user_id, message)
    user_id = user_id.to_i
    message = message.to_s

    if User.exist?(user_id) && !message.empty?
      sqlite do |db|
        db.execute(
          'INSERT INTO messages(message, user_id, created) VALUES(?, ?, ?);',
          [message, user_id, Time.now.to_i]
        )
      end
    else
      false
    end
  end

  def get_user_by_hash(hash)
    user_id = 0

    sqlite do |db|
      db.execute(
        'SELECT user_id, COUNT(id) AS count FROM members WHERE hash = ? LIMIT 1;',
        [hash.to_s]
      ) do |row|
        if row['count'] == 1
          user_id = row['user_id'].to_i
        end
      end
    end

    if User.exist? user_id
      user_id
    else
      false
    end
  end

  def search_member(hash)
    hash = hash.to_s
    user_id = 0

    sqlite do |db|
      db.execute(
        'SELECT user_id, COUNT(id) AS count FROM members WHERE hash = ? LIMIT 1;',
        [hash]
      ) do |row|
        if row['count'] == 1
          user_id = row['user_id'].to_i
        end
      end
    end

    user_id
  end

  def add_member(user_id, hash)
    user_id = user_id.to_i
    hash = hash.to_s

    if User.exist?(user_id) && hash.length >= 16
      sqlite do |db|
        db.execute(
          'INSERT INTO members(user_id, hash) VALUES(?, ?);',
          [user_id, hash]
        )
      end

      true
    else
      false
    end
  end

  def remove_member(hash)
    hash = hash.to_s

    sqlite do |db|
      db.execute(
        'DELETE FROM members WHERE hash = ?;',
        [hash]
      )
    end
  end
end

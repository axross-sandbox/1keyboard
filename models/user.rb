require 'openssl'

class User
  attr_reader(:id, :name, :image_url, :github_url, :color, :fontsize, :created)
  private_class_method :new

  def name=(name)
    @name = name.to_s
  end

  def image_url=(image_url)
    @image_url = image_url.to_s
  end

  def github_url=(github_url)
    @github_url = github_url.to_s
  end

  def color=(color)
    @color = color.to_s
  end

  def fontsize=(fontsize)
    @fontsize = fontsize.to_i
  end

  # check and create instance
  def self.init(id)
    if User.exist?(id)
      new id
    else
      nil
    end
  end

  # get user info
  def initialize(id)
    User.sqlite do |db|
      db.execute(
        'SELECT id, name, image_url, github_url, color, fontsize,   created, COUNT(name) AS count FROM users WHERE id = ? LIMIT 1;',
        [id]
      ) do |row|
        @id = row['id'].to_i
        @name = row['name'].to_s
        @image_url = row['image_url'].to_s
        @github_url = row['github_url'].to_s
        @color = row['color'].to_s
        @fontsize = row['fontsize'].to_i
        @created = Time.at(row['created'])
      end
    end
  end

  # update user info
  def update
    User.sqlite do |db|
      db.execute(
        'UPDATE users SET name = ?, image_url = ?, github_url = ?, color = ?, fontsize = ? WHERE id = ?;',
        [@name, @image_url, @github_url, @color, @fontsize, @id]
      )
    end
    true
  end

  # regist user
  def self.insert(id, name, image_url, github_url)
    if id.to_i > 0 && !name.to_s.empty? && !image_url.to_s.empty? && !github_url.to_s.empty?
      User.sqlite do |db|
        db.execute(
          'INSERT INTO users(id, name, image_url, github_url, color, fontsize, created) VALUES(?, ?, ?, ?, ?, ?, ?);',
          [id.to_i, name.to_s, image_url.to_s, github_url.to_s, USER_COLORS.sample.to_s, 16, Time.now.to_i]
        )
      end

      new id
    else
      false
    end
  end

  # check exist id
  def self.exist?(id)
    id = id.to_i
    exist = false
    self.sqlite do |db|
      db.execute(
        'SELECT COUNT(name) AS count FROM users WHERE id = ? LIMIT 1;',
        [id]
      ) do |row|
        exist = true if row['count'].to_i > 0
      end
    end

    exist
  end

  # id -> trip
  def self.encrypt(id)
    cip = OpenSSL::Cipher::Cipher.new('aes256')
    cip.encrypt
    cip.pkcs5_keyivgen(SOLT_WORD)
    ((cip.update(id.to_s) + cip.final).unpack("H*"))[0]
  rescue
    false
  end

  # trip -> id
  def self.decrypt(trip)
    cip = OpenSSL::Cipher::Cipher.new('aes256')
    cip.decrypt
    cip.pkcs5_keyivgen(SOLT_WORD)
    (cip.update(Array.new([trip.to_s]).pack("H*")) + cip.final).to_i
  rescue
    false
  end

  # sqlite3 wrapper method
  def self.sqlite
      db = SQLite3::Database.new 'master.sqlite3'
      db.results_as_hash = true
      yield db
      db.close
  end
end

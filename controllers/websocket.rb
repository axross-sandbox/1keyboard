set websocketio: { port: WEBSOCKET_PORT }
set rocketio: { websocket: true, comet: false }
io = Sinatra::RocketIO

# クライアントが接続された
io.on :connected do |data, client|
  id = User.decrypt(data['trip'])
  hash = client.session.to_s
  channel = client.channel.to_s
  ch = Channel.init(channel)

  if ch
    user = User.init id
    ch.add_member(id, hash)

    if user
      io.push(:ready, {
        name: user.name,
        image_url: user.image_url,
        color: user.color
      }, { to: client.session })

    else
      io.push(:errored, {}, { to: hash, channel: channel })
    end
  else
    io.push(:errored, {}, { to: hash, channel: channel })
  end
end

# クライアントが切断された
io.on :disconnect do |client|
  hash = client.session.to_s
  channel = client.channel.to_s
  ch = Channel.init(client.channel.to_s)

  ch.remove_member(hash)
  io.push(:quit, {}, { channel: channel })
end

# メッセージが送信された
io.on :message do |data, client|
  message = data['message'].to_s if !data['message'].nil?
  hash = client.session.to_s
  channel = client.channel.to_s
  ch = Channel.init(channel)

  if ch
    id = ch.get_user_by_hash hash
    user = User.init id
    if user
      ch.post_message(id, message)

      io.push(:message, {
        image_url: user.image_url,
        message: message,
        name: user.name,
        posted: Time.now.strftime("%H:%M:%S"),
        color: user.color
      }, { channel: channel })
    else
      io.push(:errored, {}, { to: hash, channel: channel })
    end
  else
    io.push(:errored, {}, { to: hash, channel: channel })
  end
end

# コードの編集が開始された
io.on :code_start do |data, client|
  hash = client.session.to_s
  channel = client.channel.to_s
  ch = Channel.init(channel)

  if ch
    id = ch.get_user_by_hash hash
    user = User.init id
    if user
      io.push(:code_started, {
        name: user.name,
        image_url: user.image_url,
        color: user.color
      }, { channel: channel })
    end
  else
    io.push(:errored, {}, { to: hash, channel: channel })
  end
end

# コードの編集が終了された
io.on :code_finish do |data, client|
  code = data['code'].to_s
  hash = client.session.to_s
  channel = client.channel.to_s
  ch = Channel.init(channel)

  if ch
    id = ch.get_user_by_hash hash
    if id
      io.push(:code_finished, {
        code: code
      })

      ch.code = code
    end
  end
end

# コードが編集(キー入力)された
io.on :code_change do |data, client|
  hash = client.session.to_s
  channel = client.channel.to_s
  ch = Channel.init(channel)

  if ch
    id = ch.get_user_by_hash hash
    if id
      io.push(:code_changed, {
        code: data['code'].to_s
      })
    end
  end
end

io.on :fontsize do |data, client|
  fontsize = data['fontsize'].to_i.ceil if !data['fontsize'].nil? && data['fontsize'].to_i.ceil >= 6
  hash = client.session.to_s
  channel = client.channel.to_s
  ch = Channel.init(channel)

  if ch
    id = ch.get_user_by_hash hash
    user = User.init id
    if user
      user.fontsize = fontsize
      user.update
    else
      io.push(:errored, {}, { to: hash, channel: channel })
    end
  else
    io.push(:errored, {}, { to: hash, channel: channel })
  end
end

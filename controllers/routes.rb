get '/app.css' do
  scss :app
end

get '/' do
  id = session['id'].to_i if !session['id'].nil?

  if session['id'].to_i > 0
    # セッションがある
    @user = User.init(session['id'].to_i)

    if @user
      @trip = User.encrypt @user.id

      erb :index_logined
    else
      erb :index_logouted
    end
  else
    # セッションがない
    erb :index_logouted
  end
end

get '/channel/:ch_name' do
  id = session['id'].to_i if !session['id'].nil?

  if session['id'].to_i > 0
    # セッションがある
    @user = User.init(id)

    if @user
      channel = Channel.init params[:ch_name]

      if channel
        @channel = channel.name
        @trip = User.encrypt @user.id
        @code = channel.code
        @messages = channel.get_messages 50

        erb :app
      else
        'そんなチャンネルねーよ'
      end
    else
      'そんなユーザーねーよ'
    end
  else
    'セッションがねーよ'
  end
end

=begin
get '/test' do
  user = User.init(4289883)
  p user

  trip = User.encrypt(4289883)
  p trip

  id = User.decrypt('40a830492dc7f61da6d2ee9fd3c6032f')
  p id

  channel = Channel.init(1)
  p channel
  channel.post_message(4289883, 'Hello world!')
end
=end

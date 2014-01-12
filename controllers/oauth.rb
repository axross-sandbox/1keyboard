require 'omniauth'
require 'omniauth-github'

use OmniAuth::Builder do
  provider :github,
    GITHUB_APP_ID,
    GITHUB_APP_SECRET,
    request_path: '/login',
    callback_path: '/login/callback'
end

# get '/login' in omniauth

get '/login/callback' do
  auth = request.env['omniauth.auth']
  id = auth['uid'].to_i
  session['id'] = id
  user = User.init(id)

  if user
    user.name = auth['info']['nickname']
    user.image_url = auth['info']['image']
    user.github_url = auth['info']['urls']['GitHub']
    user.update
  else
    user = User.insert(id, auth['info']['nickname'], auth['info']['image'], auth['info']['urls']['GitHub'])
  end

  redirect '/'
end

get '/auth/failure' do
  redirect '/logout'
end

get '/logout' do
  session.clear
  redirect '/'
end

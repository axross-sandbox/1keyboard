require 'sinatra'
require 'sinatra/rocketio'
require 'sqlite3'
require 'sass'

# アプリケーション設定
require_relative 'settings.rb'

set sessions: true
set server: :thin
set port: APP_PORT
set public_folder: File.dirname(__FILE__) + '/views'

Dir.foreach 'models/' do |filename|
  if File.extname(filename) == '.rb'
    require_relative 'models/' + filename
  end
end

require_relative 'controllers/routes.rb'
require_relative 'controllers/oauth.rb'
require_relative 'controllers/websocket.rb'

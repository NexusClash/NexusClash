require 'sinatra'
require 'faye/websocket'
require 'opal'
require 'opal/browser'

require File.expand_path('../app', __FILE__)

#use Rack::Session::Mongo

Faye::WebSocket.load_adapter('puma')

use Faye::RackAdapter, :mount => '/42', :timeout => 25

run Sinatra::Application
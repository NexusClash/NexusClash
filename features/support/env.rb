require 'bundler'
require 'observer'
require 'json'
require 'securerandom'
require 'faye/websocket'
require 'websocket/extensions'
require 'permessage_deflate'
Bundler.require

require 'simplecov'
require 'simplecov-json'
require 'simplecov-rcov'

SimpleCov.formatters = [
		SimpleCov::Formatter::HTMLFormatter,
		SimpleCov::Formatter::JSONFormatter,
		SimpleCov::Formatter::RcovFormatter
]
SimpleCov.start

Mongoid.load!('mongoid.yml')

Mongoid.purge! if Mongoid.default_session.options[:database] == 'nexusdash_test' # Lets be EXTRA SAFE

require_rel '../../enums'
require_rel '../../config'
require_rel '../../behaviour/core'
require_rel '../../behaviour/intent'
require_rel '../../behaviour/effect'
require_rel '../../mixins'
require_rel '../../controllers'
require_rel '../../models'
require_rel '../../firmament/entities'
require_rel '../../firmament'
require_rel '../../wayfarer'
#require_rel '../../datatables'

p = Entity::Plane.new
p.plane = 1
p.name = 'Testville'
p.save
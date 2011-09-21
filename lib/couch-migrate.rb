require_relative 'couch_migrate_railtie.rb' if defined?(Rails)
list = Dir["#{File.dirname(__FILE__)}/couch_migrate/**/*.rb"]
skip = Dir["#{File.dirname(__FILE__)}/couch_migrate/couchrest_model/**/*.rb"]
(list - skip).each {|f| require f}

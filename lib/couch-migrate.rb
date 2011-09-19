require_relative 'couch_migrate_railtie.rb' if defined?(Rails)
Dir["#{File.dirname(__FILE__)}/couch_migrate/**/*.rb"].each {|f| require f}

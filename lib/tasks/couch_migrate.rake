require_relative '../couch-migrate'

def migrater
  $db_path = 'http://127.0.0.1:5984/couch-migrate_development'
  migrater = CouchMigrate::CouchMigrater.new($db_path)
end

namespace :couch_migrate do

  desc 'migrate all pending migrations'

  namespace :test do

    task :migrate => ['migrate:up']

    namespace :migrate do
      desc 'couchdb migration up'
      task 'up' => [:environment, :url] do
        migrater.migrate(:up)
      end

      desc 'couchdb migration down'
      task 'down' => [:environment, :url] do
        migrater.migrate(:down)
      end

      desc 'couchdb migration down, then up'
      task 'redo' => [:environment, :url] do
        migrater.migrate(:down)
        migrater.migrate(:up)
      end

      desc 'print couchdb URL'
      task 'url' => :environment do
        $stderr.puts("CouchDB URL: #{$db_path}")
      end

    end
  end
end

require_relative '../couch-migrate'

namespace :db do

  desc 'migrate all pending migrations'
  task :migrate => ['migrate:up']

  namespace :migrate do

    desc 'couchdb migration up'
    task 'up' => :environment do
      db_path = 'http://127.0.0.1:5984/couch-migrate_development'
      migrater = CouchMigrate::CouchMigrater.new(db_path)
      migrater.migrate(:up)
    end

    desc 'couchdb migration down'
    task 'down' => :environment do
      db_path = 'http://127.0.0.1:5984/couch-migrate_development'
      migrater = CouchMigrate::CouchMigrater.new(db_path)
      migrater.migrate(:down)
    end


    desc 'couchdb migration down, then up'
    task 'redo' => :environment do
      db_path = 'http://127.0.0.1:5984/couch-migrate_development'
      migrater = CouchMigrate::CouchMigrater.new(db_path)
      migrater.migrate(:down)
      migrater.migrate(:up)
    end


  end

end

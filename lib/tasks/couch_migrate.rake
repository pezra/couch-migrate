require_relative '../couch-migrate'

desc 'CouchDB migration'
task 'couch:migrate' => :environment do
  persisted_list = CouchMigrate::CouchPersistedList.new
  executer = CouchMigrate::CouchExecuter
  path = Pathname.new("db/migrate")
  migrater = CouchMigrate::SimpleMigrater.new(persisted_list, executer).directory(path)
  migrater.migrate(:up)
end


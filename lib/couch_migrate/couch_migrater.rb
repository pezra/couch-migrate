require_relative 'base_migrater'
require_relative 'couch_persisted_list'
require_relative 'couch_executer'

module CouchMigrate
  class CouchMigrater < BaseMigrater
    def initialize(database, migration_directory="db/migrate")
      persisted_list = CouchPersistedList.new(database)
      executer = CouchExecuter
      super(persisted_list, executer, migration_directory)
      self
    end

  end
end



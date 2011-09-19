require_relative 'base_migrater'

module CouchMigrate
  class CouchMigrater < BaseMigrater
    def initialize(database, migration_directory="db/migrate")
      persisted_list = CouchMigrate::CouchPersistedList.new(database)
      executer = CouchMigrate::CouchExecuter
      super(persisted_list, executer, migration_directory)
      self
    end

  end
end



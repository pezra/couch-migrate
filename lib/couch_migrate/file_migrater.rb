require_relative 'base_migrater'

module CouchMigrate
  class FileMigrater < BaseMigrater
    def initialize(migration_directory="db/migrate")
      persisted_list = CouchMigrate::FilePersistedList.new(migration_directory)
      executer = CouchMigrate::CouchExecuter
      super(persisted_list, executer, migration_directory)
      self
    end

  end
end


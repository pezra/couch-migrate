require_relative 'base_migrater'
require_relative 'file_persisted_list'
require_relative 'couch_executer'

module CouchMigrate
  class FileMigrater < BaseMigrater
    def initialize(migration_directory="db/migrate")
      persisted_list = FilePersistedList.new(migration_directory)
      executer = CouchExecuter
      super(persisted_list, executer, migration_directory)
      self
    end

  end
end


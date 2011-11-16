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

    def migrate(*args)
      if defined?( CouchRest::Model::Base)
        orig_auto_update_design_doc = CouchRest::Model::Base.auto_update_design_doc
        CouchRest::Model::Base.auto_update_design_doc = false
      end
      begin
        super
      ensure
        if defined?(CouchRest::Model::Base)
          CouchRest::Model::Base.auto_update_design_doc = orig_auto_update_design_doc 
        end
      end
    
    end
  end
end



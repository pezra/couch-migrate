require 'couchrest'
require_relative 'base_persisted_list'

module CouchMigrate
  class CouchPersistedList < BasePersistedList
    DocName = 'migrations'
    MigrationField = 'completed'

    def initialize(database)
      @db = CouchRest.database!(database) # find or create
      raise "db cannot be created using url #{database}" if @db.nil?
      super()
      self
    end

    private

    def read
      @list = @db.get(DocName)[MigrationField] rescue []
    end

    def write
      doc = @db.get(DocName) rescue {'_id' => DocName}
      doc[MigrationField] = @list
      @db.save_doc(doc)
    end

    def cleanup
      @list = []
      write
    end

  end

end


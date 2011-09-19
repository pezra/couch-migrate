require 'couchrest'

module CouchMigrate
  class CouchPersistedList < BasePersistedList
    DocName = 'migrations'
    MigrationField = 'completed'

    def initialize(database)
      @db = CouchRest.database!(database) # find or create
      raise "db cannot be created using url #{database}" if @db.nil?
      super()
      # response = @db.save_doc({'_id' => 'migrations', :type => 'Migrations', :completed => ['1_migration','migration_2']})
      # doc = @db.get(response['id'])
      # puts doc.inspect
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
      self
    end

    # def save_or_create(db, doc)
    #   begin
    #     rev = db.get(doc['_id'])['_rev']
    #     doc['_rev'] = rev
    #     db.save_doc(doc)
    #   rescue RestClient::ResourceNotFound => nfe
    #     db.save_doc(doc)
    #   end
    # end

  end

end


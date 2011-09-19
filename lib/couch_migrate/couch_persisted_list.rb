module CouchMigrate
  class CouchPersistedList < BasePersistedList
    def initialize(database)
      super()
      @db = database
    end

    def get
      puts "couch get"
      super
    end

    def set(arr)
      puts "couch set"
      super
    end

    def <<(arr)
      puts "couch add"
      super
    end

  end

end


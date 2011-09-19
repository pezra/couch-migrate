require 'pathname'

module CouchMigrate
  class FilePersistedList < BasePersistedList
    def initialize(directory="db/migrate")
      super()
      require 'yaml'
      @path = Pathname.new(directory)+"meta.yml"
      read
    end

    def get
      read
      super
    end

    def set(arr)
      super
      write
    end

    def <<(arr)
      super
      write
    end

    def reset
      super
      @path.delete rescue nil
    end

    private

    def read
      @data = YAML.load(File.read(@path)) rescue {}
      @data[:complete] ||= []
      @list = @data[:complete]
    end

    def write
      @data[:complete] = @list
      File.open(@path,"w"){|f| f<< YAML.dump(@data) }
    end

  end

end


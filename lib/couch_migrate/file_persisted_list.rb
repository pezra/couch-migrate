require 'pathname'
require 'yaml'

module CouchMigrate
  class FilePersistedList < BasePersistedList
    def initialize(directory="db/migrate")
      super()
      path = Pathname.new(directory)
      path.mkpath
      @path = path+"meta.yml"
      read
      self
    end

    protected

    def read
      @data = YAML.load(File.read(@path)) rescue {}
      @data[:complete] ||= []
      @list = @data[:complete]
    end

    def write
      @data[:complete] = @list
      File.open(@path,"w"){|f| f<< YAML.dump(@data) }
    end

    def cleanup
      @path.delete rescue nil
    end

  end

end


require 'pathname'
require 'yaml'

module CouchMigrate
  class FilePersistedList < BasePersistedList
    def initialize(meta_file_directory="db/migrate")
      super()
      path = Pathname.new(meta_file_directory)
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
      File.delete(@path.to_s) rescue nil
      # @path.delete rescue nil # fakefs does not handle this correctly
    end

  end

end


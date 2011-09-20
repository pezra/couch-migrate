module CouchMigrate
  class BasePersistedList

    def initialize
      @list = []
    end

    def get
      read
      @list
    end

    def set(arr)
      raise "argument must be an array" unless arr.is_a?(Array)
      @list = arr.dup
      write
      self
    end

    def add(arr)
      raise "argument must be an array" unless arr.is_a?(Array)
      @list.concat(arr).uniq!
      write
      self
    end

    def remove(arr)
      raise "argument must be an array" unless arr.is_a?(Array)
      @list -= arr
      write
      self
    end

    def reset
      @list = []
      cleanup
      self
    end

    protected

    def read
    end

    def write
    end

    def cleanup
    end
  end
end


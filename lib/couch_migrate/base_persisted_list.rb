module CouchMigrate
  class BasePersistedList

    def initialize
      reset
    end

    def get
      @list
    end

    def set(arr)
      raise "argument must be an array" unless arr.is_a?(Array)
      @list = arr
    end

    def <<(arr)
      raise "argument must be an array" unless arr.is_a?(Array)
      @list.concat(arr).uniq!
    end

    def reset
      @list = []
    end
  end

end


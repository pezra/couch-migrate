class PersistedList

  def initialize
    @list = []
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

end

class Executer
  def initialize(path)
    @path = path
    self
  end

  def go
    load(@path)
  end
end

class SimpleMigrater
  attr_reader :failed_migration

  def initialize(persisted_list = nil, executer = nil)
    @raw_migrations = []
    @existing_migrations = persisted_list || PersistedList.new
    @executer = executer || Executer
    @directory = "db/migrations"
  end

  def migrate(quiet = false)
    @failed_migration, completed = nil, []
    pending_migrations.each do |migration|
      begin
        @executer.new(@directory + migration).go
        completed << migration
      rescue Exception => e
        @failed_migration = migration
        puts '-'*40, "FAILURE in migration (#{migration}): #{e.message}", '-'*10, e.backtrace, '-'*40 unless quiet
        return
      end
    end
  ensure
    @existing_migrations << completed
  end

  def directory(path=nil)
    return @directory if path.nil?
    @directory = path
    raw_migrations(Pathname.new(path).children(with_directory = false))
    self
  end

  def raw_migrations(arr=nil)
    return @raw_migrations if arr.nil?
    raise "argument must be an array" unless arr.is_a?(Array)
    @raw_migrations = filter_and_sort(arr)
    self
  end

  def pending_migrations
    raw_migrations - existing_migrations
  end

  def existing_migrations(arr=nil)
    return @existing_migrations.get if arr.nil?
    @existing_migrations.set(arr)
    self
  end

  private

  def filter_and_sort(arr)
    # discard invalid formats, then sort numerically by first number, then alphabetically for remainder
    format = /(\d+)_(.*)\.rb/
    arr.map do |e|
      name = Pathname.new(e).basename.to_s
      match = format.match(name)
      [name, match[1], match[2]] rescue nil
    end.compact.sort_by{|e| [e[1].to_i, e[2]] }.map{|e| e[0] }
  end

end

class CouchPersistedList < PersistedList
end

class CouchExecuter < Executer
  def initialize(path)
    super
    self
  end

end


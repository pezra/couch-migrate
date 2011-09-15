class SimpleExecuter
  def initialize(enabled, str)
    raise "'enabled' argument must be an Array of symbols (such as [:up, :down] or []" unless enabled.is_a?(Array)
    @migration_str = str
    @enabled = enabled
    self
  end

  def go
    Namespaced.module_eval(<<-EOS)
      def self.up
        yield if #{@enabled.include?(:up)}
      end

      def self.down
        yield if #{@enabled.include?(:down)}
      end
    EOS

    Namespaced.module_eval(@migration_str)
  end

  module Namespaced
  end
end

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

class SimpleMigrater
  attr_reader :failed_migration

  def migrate(*args)
    migration_reserved_args= [:quiet]
    executer_args = args - migration_reserved_args

    @failed_migration, completed = nil, []
    pending_migrations.each do |migration|
      begin
        str = File.read(@directory + migration)
        @executer.new(executer_args, str).go
        completed << migration
      rescue Exception => e
        @failed_migration = migration
        puts '-'*40, "FAILURE in migration (#{migration}) with message:", e.message, '-'*10, e.backtrace[0...5], '-'*40 unless args.include?(:quiet)
        return
      end
    end
  ensure
    @existing_migrations << completed
  end

  def initialize(persisted_list = nil, executer = nil)
    @raw_migrations = []
    @existing_migrations = persisted_list || PersistedList.new
    @executer = executer || SimpleExecuter
    @directory = "db/migrations"
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

class CouchExecuter < SimpleExecuter
  def initialize(path)
    super
    self
  end

end


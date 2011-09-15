class CouchMigrate
  attr_reader :failed_migration

  def initialize
    @raw_migrations = []
    @existing_migrations = []
    @directory = "db/migrations"
  end

  def migrate
    @failed_migration, completed = nil, []
    pending_migrations.each do |migration|
      begin
        load(@directory + migration)
        completed << migration
      rescue Exception => e
        @failed_migration = migration
        return
      end
    end
  ensure
    @existing_migrations.concat(completed).uniq!
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
    return @existing_migrations if arr.nil?
    raise "argument must be an array" unless arr.is_a?(Array)
    @existing_migrations = arr
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

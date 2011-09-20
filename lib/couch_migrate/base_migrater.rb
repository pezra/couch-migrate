module CouchMigrate
  class BaseMigrater
    attr_reader :failed_migration

    def initialize(persisted_list = nil, executer = nil, migration_directory = "db/migrations")
      @raw_migrations = []
      @completed_migrations = persisted_list || BasePersistedList.new
      @executer = executer || BaseExecuter
      directory(migration_directory)
      self
    end

    def migrate(*args)
      migration_reserved_args= [:quiet]
      executer_args = args - migration_reserved_args

      @failed_migration, completed = nil, []
      direction, action, migrations = if args.include?(:down)
        [:down, :remove, [completed_migrations.last]]
      else
        [:up, :add, pending_migrations]
      end

      migrations.compact.each do |migration|
        begin
          puts '-'*40, "Migration #{direction} (#{migration})" unless args.include?(:quiet)
          str = File.read(@directory + migration)
          @executer.new(executer_args, str, migration).go
          completed << migration
          puts '-'*40 unless args.include?(:quiet)
        rescue Exception => e
          @failed_migration = migration
          puts '-'*5,"FAILURE in migration #{direction} (#{migration}) with message:", e.message, '-'*5, e.backtrace[0...10], '-'*40 unless args.include?(:quiet)
          return {success: completed, failed: [@failed_migration]}
        end
      end

      return completed.empty? ? {} : {success: completed}
    ensure
      @completed_migrations.send(action, completed)
    end

    def directory(path=nil)
      return @directory if path.nil?
      @directory = Pathname.new(path)
      refresh_raw_migrations
      self
    end

    def reset
      @completed_migrations.reset
      self
    end

    def reload
      refresh_raw_migrations
      self
    end

    def refresh_raw_migrations(arr=nil)
      raise "argument must be an array" unless arr.nil? || arr.is_a?(Array)
      arr ||= Pathname.new(@directory).children(with_directory = false) rescue []
      @raw_migrations = filter_and_sort(arr)
      self
    end

    def raw_migrations(arr=nil)
      return @raw_migrations if arr.nil?
      refresh_raw_migrations(arr)
      self
    end

    def completed_migrations(arr=nil)
      return @completed_migrations.get if arr.nil?
      @completed_migrations.set(arr)
      self
    end

    def pending_migrations
      raw_migrations - completed_migrations
    end

    private

    def filter_and_sort(arr= [])
      # discard invalid formats, then sort numerically by first number, then alphabetically for remainder
      format = /(\d+)_(.*)\.rb/
      arr.map do |e|
        name = Pathname.new(e).basename.to_s
        match = format.match(name)
        [name, match[1], match[2]] rescue nil
      end.compact.sort_by{|e| [e[1].to_i, e[2]] }.map{|e| e[0] }
    end

  end
end

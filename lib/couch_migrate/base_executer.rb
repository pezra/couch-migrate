module CouchMigrate
  class BaseExecuter
    def initialize(enabled, str, filename = "")
      raise "'enabled' argument must be an Array of symbols (such as [:up, :down] or []" unless enabled.is_a?(Array)
      @migration_str = str
      @enabled = enabled
      @filename = filename
      self
    end

    def go
      Namespaced.module_eval(<<-EOS, __FILE__, __LINE__ + 1)
        def self.up
          yield if #{@enabled.include?(:up)}
        end

        def self.down
          yield if #{@enabled.include?(:down)}
        end

        # convenience method for migration files to use
        def self.use_couchrest_model
          require 'couch_migrate/couchrest_model/extend.rb'
        end

      EOS

      Namespaced.module_eval(@migration_str, @filename)
    end

    module Namespaced
    end
  end
end


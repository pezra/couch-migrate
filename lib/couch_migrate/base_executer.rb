module CouchMigrate
  class BaseExecuter
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
end


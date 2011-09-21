# use "use_couchrest_model" in the DSL or
# include this module in a migration to use CouchRest::Model
if defined?(::CouchRest::Model)
  module ::CouchRest
    module Model
      class Base
        class << self
          alias to_s_original to_s

          def to_s
            to_s_original.sub(/CouchMigrate::BaseExecuter::Namespaced::/, '')
          end
        end

      end
    end
  end
end

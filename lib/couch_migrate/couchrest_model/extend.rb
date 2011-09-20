# use "use_couchrest_model" in the DSL or
# include this module in a migration to use CouchRest::Model
if defined?(CouchRest::CouchRest::Model)
  module CouchRest
    module Model
      class Base
        before_save :rewrite_type_for_migration_classes

        def rewrite_type_for_migration_classes
          class_name = self.class.to_s.sub(/CouchMigrate::BaseExecuter::Namespaced::/, '')
          self['type'] = class_name
        end
      end
    end
  end
end

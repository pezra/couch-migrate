require_relative '../base_executer'
require 'couchrest_model'

# use "use_couchrest_model" in the DSL or
# include this module in a migration to use CouchRest::Model
module CouchMigrate
  class BaseExecuter
    module Namespaced
      module CouchRest
        module Model
          class Base < ::CouchRest::Model::Base
            class << self
              alias to_s_original to_s
              
              def to_s
                to_s_original.sub(/CouchMigrate::BaseExecuter::Namespaced::/, '')
              end
              
              def inherited(klass)
                klass.auto_update_design_doc = false
              end
            end
          end
        end
      end
    end
  end
end

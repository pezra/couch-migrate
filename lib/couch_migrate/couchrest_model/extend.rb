require_relative '../base_executer'
require 'couchrest_model'

# use "use_couchrest_model" in the DSL or
# include this module in a migration to use CouchRest::Model

class << ::CouchRest::Model::Base
  alias to_s_original to_s
  
  def to_s
    to_s_original.sub(/CouchMigrate::BaseExecuter::Namespaced::/, '')
  end
end



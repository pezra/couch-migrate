require_relative '../spec_helper'
require 'couch_migrate/couchrest_model/extend'

describe CouchMigrate::BaseExecuter::Namespaced::CouchRest::Model::Base do 
  let(:migration){<<-MIGR
use_couchrest_model

class TestModel < CouchRest::Model::Base
  property :name, String
end

up do
  raise "Auto update design docs should be off" if TestModel.auto_update_design_doc
end
MIGR
}

  it "disables view auto update for models defined in the migration" do 
    lambda {
      CouchMigrate::BaseExecuter.new([:up], migration).go
    }.should_not raise_error
  end


end

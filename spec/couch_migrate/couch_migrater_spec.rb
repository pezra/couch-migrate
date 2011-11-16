require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'couch-migrate'
require_relative 'shared_sequential_migrations'

describe CouchMigrate::CouchMigrater, "#migrate" do
  let(:path) { Pathname.new("./tmp/spec").expand_path.tap{|it| it.mkpath} }
  let(:db_uri) { 'http://127.0.0.1:5984/couch-migrate_test' }

  it_should_behave_like "sequential_migrations" do
    let(:path) { Pathname.new("spec/tmp") }

    subject { CouchMigrate::CouchMigrater }

    def migrater
      # allows new migrations to be picked up
      subject.new(db_uri, path)
    end
  end

  it "doesn't automatically destroy design documents created in previous runs" do 
    class ::TestModel < CouchRest::Model::Base
      property :name, String
      design do
        view :by_name
      end
    end
    ::TestModel.save_design_doc!
    Object.module_eval { remove_const :TestModel }

    File.open(path + "1_model_wo_by_name-view.rb", 'w'){|f| f << <<-MIGR}
      use_couchrest_model
      class TestModel < CouchRest::Model::Base
        property :name, String
      end
      up do 
        TestModel.all
      end
    MIGR

    lambda {
      CouchMigrate::CouchMigrater.new(db_uri, path).migrate(:up, :quiet)
    }.should_not change { CouchRest::Model::Base.database.get('_design/TestModel') || raise("missing design doc") }
  end

end


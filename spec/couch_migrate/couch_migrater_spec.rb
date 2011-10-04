require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'couch-migrate'
require_relative 'shared_sequential_migrations'

describe CouchMigrate::CouchMigrater, "#migrate" do

  it_should_behave_like "sequential_migrations" do
    subject { CouchMigrate::CouchMigrater }

    let(:path){ Pathname.new("spec/tmp") }
    let(:db_path) { 'http://127.0.0.1:5984/couch-migrate_test' }

    def migrater
      # allows new migrations to be picked up
      subject.new(db_path, path)
    end
  end

end


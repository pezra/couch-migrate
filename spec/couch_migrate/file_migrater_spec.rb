require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'couch-migrate'
require_relative 'shared_sequential_migrations'

describe CouchMigrate::FileMigrater, "#migrate" do

  it_should_behave_like "sequential_migrations" do
    subject { CouchMigrate::FileMigrater }
    let(:path){ Pathname.new("spec/tmp") }

    def migrater
      # allows new migrations to be picked up
      subject.new(path)
    end
  end

end


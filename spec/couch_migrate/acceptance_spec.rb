require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'couch-migrate'

describe "Rake task" do
  it "works" do
    persisted_list = CouchMigrate::CouchPersistedList.new
    executer = CouchMigrate::CouchExecuter
    migrater = CouchMigrate::BaseMigrater.new(persisted_list, executer)
    migrater.migrate
  end

end


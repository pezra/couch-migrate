require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'couch-migrate'
require_relative 'shared_persisted_list'

describe CouchMigrate::CouchPersistedList do

  it_should_behave_like "a_persisted_list" do
    let(:db_path) { 'http://127.0.0.1:5984/couch-migrate_test' }
    subject { CouchMigrate::CouchPersistedList.new(db_path).tap{|l| l.reset} }
  end
end


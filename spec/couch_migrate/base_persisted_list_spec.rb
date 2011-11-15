require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'couch-migrate'
require_relative 'shared_persisted_list'

describe CouchMigrate::BasePersistedList do

  it_should_behave_like "a_persisted_list" do
    subject { CouchMigrate::BasePersistedList.new }
  end
end


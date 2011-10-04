require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'couch-migrate'
require 'pathname'
require_relative 'shared_persisted_list'

describe CouchMigrate::FilePersistedList do

  it_should_behave_like "a_persisted_list" do
    let(:path){ Pathname.new("spec/tmp") }
    subject { CouchMigrate::FilePersistedList.new(path) }
  end
end


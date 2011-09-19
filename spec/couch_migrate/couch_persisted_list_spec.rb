require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'couch-migrate'

describe CouchMigrate::CouchPersistedList do
  let(:db_path) { 'http://127.0.0.1:5984/couch-migrate_test' }
  subject { CouchMigrate::CouchPersistedList.new(db_path) }

  before(:each) do
    subject.reset
  end

  it "starts off with an empty value/list" do
    subject.get.should == []
  end

  it "can set values" do
    arr = [1,2,3]
    subject.set(arr).get.should == arr
  end

  it "can append values" do
    arr = [1,2,3]
    more = [4,5]
    expected = [1,2,3,4,5]

    subject.set(arr) << more
    subject.get.should == arr
  end

  it "can be reset" do
    subject.set([1,2,3]).reset
    subject
  end

  it "is chainable" do
    (subject.set([1]) << [2]).get.should == [1,2]
    (subject.set([1]) << [2]).reset.get.should == []
  end

end

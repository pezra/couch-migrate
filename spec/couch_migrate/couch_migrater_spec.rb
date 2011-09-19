require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'couch-migrate'

describe "CouchMigrater", "#migrate" do


  context "interacting with the file system" do
    subject { CouchMigrate::CouchMigrater }
    let(:db_path) { 'http://127.0.0.1:5984/couch-migrate_test' }
    let(:path){ Pathname.new("spec/tmp") }

    let(:file_name_1){ "1_migration_a.rb" }
    let(:file_name_2){ "2_migration_b.rb" }
    let(:file_name_3){ "3_migration_b.rb" }
    let(:file_path_1){ path + file_name_1 }
    let(:file_path_2){ path + file_name_2 }
    let(:file_path_3){ path + file_name_3 }

    before(:each) do
      migrater.reset # clear pre-existing migration meta data
      path.mkpath
      file_path_1.delete rescue nil
      file_path_2.delete rescue nil
      file_path_3.delete rescue nil
    end

    after(:each) do
      # migrater.reset # remove meta file
      file_path_1.delete rescue nil
      file_path_2.delete rescue nil
      file_path_3.delete rescue nil
      path.rmdir rescue nil
    end

    def migrater
      # allows new migrations to be picked up
      res = subject.new(db_path, path)
      res
    end

    it "handles a sequence of migration added over time" do
      params = [:up, :quiet]

      # should succeed
      File.open(file_path_1,"w"){|f| f << "up do end" }
      migrater.migrate(*params).should == {success: [file_name_1]}

      # should do nothing
      migrater.migrate(*params).should == {}

      # should fail
      File.open(file_path_2,"w"){|f| f << "up do raise '2 simulated failure' end" }
      migrater.migrate(*params).should == {success: [], failed: [file_name_2]}

      # should pass now
      File.open(file_path_2,"w"){|f| f << "up do end" }
      migrater.migrate(*params).should == {success: [file_name_2]}

      # should succeed
      File.open(file_path_3,"w"){|f| f << "up do end" }
      migrater.migrate(*params).should == {success: [file_name_3]}

      # should do nothing
      migrater.migrate(*params).should == {}

      # resetting the migration causes all to be run next time
      migrater.reset
      migrater.migrate(*params).should == {success: [file_name_1, file_name_2, file_name_3]}
    end

  end

end



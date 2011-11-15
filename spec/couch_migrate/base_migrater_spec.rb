require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'couch-migrate'
require 'pathname'
require 'fakefs/spec_helpers'

describe CouchMigrate::BaseMigrater, "sorting and filtering" do

  it "ignores files that do not follow the migrationOrder_migration_title format" do
    names = [
      '2_name.rb', #valid
      'a_bad_name.rb', #invalid
      '.#1_migration_a.rb', #invalid
      '3_name.rb', #valid
    ]
    subject.raw_migrations(names)
    subject.raw_migrations.should == ['2_name.rb', '3_name.rb']
  end

  it "sorts on migration numbers" do
    subject.raw_migrations(['2_name.rb','1_name.rb', '3_name.rb'])
    subject.pending_migrations.should == ['1_name.rb','2_name.rb', '3_name.rb']
  end

  it "sorts on title if migration numbers are the same" do
    subject.raw_migrations(['2_a_name.rb','2_b_name.rb'])
    subject.raw_migrations.should == ['2_a_name.rb','2_b_name.rb']
  end

  it "sorts on title if migration numbers are the same (version 2)" do
    subject.raw_migrations(['2_b_name.rb','2_a_name.rb'])
    subject.raw_migrations.should == ['2_a_name.rb','2_b_name.rb']
  end

  it "sorts migration numbers numerically, not alphabetically" do
    subject.raw_migrations(['10_name.rb','2_name.rb'])
    subject.raw_migrations.should == ['2_name.rb', '10_name.rb']
  end

  it "sorts migration numbers numerically, not alphabetically (version 2)" do
    subject.raw_migrations(['2_name.rb','10_name.rb'])
    subject.raw_migrations.should == ['2_name.rb', '10_name.rb']
  end

end

describe CouchMigrate::BaseMigrater, "#migrate" do

  let(:file_name_1){ "1_migration_a.rb" }
  let(:file_name_2){ "2_migration_b.rb" }
  let(:file_name_3){ "3_migration_b.rb" }

  it "can set migrations from a list" do
    subject.raw_migrations.should == []

    subject.raw_migrations([file_name_1, file_name_2]).raw_migrations.should == [file_name_1,file_name_2]
  end

  it "does not execute migrations that have already been run" do
    subject.raw_migrations([file_name_1, file_name_2]).completed_migrations([file_name_1]).pending_migrations.should == [file_name_2]
  end

  context "interacting with the file system" do
    include FakeFS::SpecHelpers

    let(:path){ Pathname.new("spec/tmp").tap{|p| p.mkpath} }

    before(:each) do
      # create migration files
      [
        [file_name_1, "up do end" ],
        [file_name_2, "up do raise '2 simulated failure' end" ],
        [file_name_3, "up do end" ],
      ].each do |file_name, content|
        File.open(path+file_name, 'w') {|f| f << content}
      end

    end

    it "reads the db/migrations directory to generate a list of potential migrations to run" do
      subject.directory(path).raw_migrations.should == [file_name_1, file_name_2, file_name_3]
      subject.directory(path).pending_migrations.should == [file_name_1, file_name_2, file_name_3]
    end

    it "stops when a migration file exits with an error, not processing any subsequent files afterwards" do
      subject.directory(path).pending_migrations.should == [file_name_1, file_name_2, file_name_3]

      subject.migrate(:quiet, :up).should == {success: [file_name_1], failed: [file_name_2]}

      subject.failed_migration.should == file_name_2
      subject.pending_migrations.should == [file_name_2, file_name_3]
    end

  end

end


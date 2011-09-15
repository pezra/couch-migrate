require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "CouchMigrate", "#migrate" do
  subject { CouchMigrate.new }

  let(:file_name_1){ "1_migration_a.rb" }
  let(:file_name_2){ "2_migration_b.rb" }
  let(:file_name_3){ "3_migration_b.rb" }

  it "can set migrations from a list" do
    subject.raw_migrations.should == []

    subject.raw_migrations([file_name_1, file_name_2]).raw_migrations.should == [file_name_1,file_name_2]
  end

  context "interacting with the file system" do
    let(:path){ Pathname.new("spec/tmp") }
    let(:file_1){ path + file_name_1 }
    let(:file_2){ path + file_name_2 }
    let(:file_3){ path + file_name_3 }

    before(:all) do
      path.mkpath
      File.open(file_3,"w"){|f| f << " " }
      File.open(file_2,"w"){|f| f << "raise '2 simulated failure'" }
      File.open(file_1,"w"){|f| f << " " }
    end

    after(:all) do
      file_1.delete
      file_2.delete
      file_3.delete
      path.rmdir rescue nil
    end

    it "reads the db/migrations directory to generate a list of potential migrations to run" do
      subject.directory(path).raw_migrations.should == [file_name_1, file_name_2, file_name_3]
      subject.directory(path).pending_migrations.should == [file_name_1, file_name_2, file_name_3]
    end

    it "stops when a migration file exits with an error, not processing any subsequent files afterwards" do
      subject.directory(path).pending_migrations.should == [file_name_1, file_name_2, file_name_3]
      subject.migrate
      subject.failed_migration.should == file_name_2
      subject.pending_migrations.should == [file_name_2, file_name_3]
    end

  end

  it "does not execute migrations that have already been run" do
    subject.raw_migrations([file_name_1, file_name_2]).existing_migrations([file_name_1]).pending_migrations.should == [file_name_2]
  end

end

describe "CouchMigrate", "sorting and filtering" do
  subject { CouchMigrate.new }

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

  it "ignores files that do not have follow the migrationOrder_migration_title format" do
    subject.raw_migrations(['2_name.rb','a_bad_name.rb'])
    subject.raw_migrations.should == ['2_name.rb']
  end

end


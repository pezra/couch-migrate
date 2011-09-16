require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Rake task" do
  it "works" do
    persisted_list = CouchPersistedList.new
    executer = CouchExecuter
    migrater = SimpleMigrater.new(persisted_list, executer)
    migrater.migrate
  end

end

describe "CouchMigrate::SimpleExecuter" do
  subject{ CouchMigrate::SimpleExecuter }
  let(:msg) { "this line was executed by the script" }
  let(:execution_verification) { "raise '#{msg}'" }

  describe "#go" do
    let(:enabled) { [] }
    it "executes a string (typically loaded from a script file)" do
      lambda{ subject.new(enabled, execution_verification).go }.should raise_error(RuntimeError,msg)
    end

    it "enables classes to be defined" do
      script =<<-EOS
        class Foo
          def test; #{execution_verification} end
        end
        up do
          Foo.new.test
        end
      EOS
      lambda{ subject.new([:up], script).go }.should raise_error(RuntimeError,msg)
    end

    it "enables classes to be defined, and they are namespaced" do
      script =<<-EOS
        class NamespacedFoo
          def test; end
        end
        up do
          NamespacedFoo.new.test
          # puts Module.constants.grep(/NamespacedFoo/).inspect
          # puts Namespaced.constants.grep(/NamespacedFoo/).inspect
          # puts SimpleExecuter::Namespaced.constants.grep(/NamespacedFoo/).inspect
          # puts SimpleExecuter.constants.grep(/NamespacedFoo/).inspect
          # puts
        end
      EOS

      subject.new([:up], script).go

      # puts Module.constants.grep(/Foo/).inspect
      # puts SimpleExecuter::Namespaced.constants.grep(/Foo/).inspect
      # puts SimpleExecuter.constants.grep(/Foo/).inspect

      Module.constants.include?(:NamespacedFoo).should == false
      CouchMigrate::SimpleExecuter.constants.include?(:NamespacedFoo).should == false
      CouchMigrate::SimpleExecuter::Namespaced.constants.include?(:NamespacedFoo).should == true
    end
  end

  describe "#up" do
    context "when enabled" do
      let(:enabled) { [:up] }

      it "executes its block of code" do
        lambda{ subject.new(enabled,"up do raise '#{msg}' end").go }.should raise_error(RuntimeError,msg)
      end
    end

    context "when disabled" do
      let(:enabled) { [] }

      it "does not executes its block of code" do
        lambda{ subject.new(enabled,"up do raise '#{msg}' end").go }.should_not raise_error(RuntimeError,msg)
      end
    end

  end

  describe "#down" do
    context "when enabled" do
      let(:enabled) { [:down] }

      it "executes its block of code" do
        lambda{ subject.new(enabled,"down do raise '#{msg}' end").go }.should raise_error(RuntimeError,msg)
      end
    end

    context "when disabled" do
      let(:enabled) { [] }

      it "does not executes its block of code" do
        lambda{ subject.new(enabled,"down do raise '#{msg}' end").go }.should_not raise_error(RuntimeError,msg)
      end
    end

  end

end

describe "SimpleMigrater", "#migrate" do
  subject { SimpleMigrater.new }

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
      File.open(file_3,"w"){|f| f << "up do end" }
      File.open(file_2,"w"){|f| f << "up do raise '2 simulated failure' end" }
      File.open(file_1,"w"){|f| f << "up do end" }
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
      subject.migrate(:quiet, :up)
      subject.failed_migration.should == file_name_2
      subject.pending_migrations.should == [file_name_2, file_name_3]
    end

  end

  it "does not execute migrations that have already been run" do
    subject.raw_migrations([file_name_1, file_name_2]).existing_migrations([file_name_1]).pending_migrations.should == [file_name_2]
  end

end

describe "SimpleMigrater", "sorting and filtering" do
  subject { SimpleMigrater.new }

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


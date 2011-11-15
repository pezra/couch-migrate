require 'pathname'
require 'fakefs/spec_helpers'

shared_examples_for "sequential_migrations" do
  let(:path){ raise "a path must be defined by the grouping using these shared examples" }

  include FakeFS::SpecHelpers

  def migrater
    # allows new migrations to be picked up
    raise "Groups that include shared examples for sequential migrations must implement a migrater function that returns a new migration object"
  end

  context "sequential usage over time" do

    let(:file_name_1){ "1_migration_a.rb" }
    let(:file_name_2){ "2_migration_b.rb" }
    let(:file_name_3){ "3_migration_b.rb" }

    before(:each) do
      path.mkpath
      migrater.reset # clear pre-existing migration meta data
    end

    def create_migration(file_name, content)
      File.open(path+file_name,"w"){|f| f << content }
    end

    it "handles a sequence of migration added over time" do
      up_params = [:up, :quiet]
      down_params = [:down, :quiet]

      # should succeed
      create_migration(file_name_1, "up do end" )
      migrater.raw_migrations.should == [file_name_1]
      migrater.completed_migrations.should == []
      migrater.pending_migrations.should == [file_name_1]
      migrater.migrate(*up_params).should == {success: [file_name_1]}

      # should do nothing
      migrater.migrate(*up_params).should == {}

      # should fail
      create_migration(file_name_2, "up do raise '2 simulated failure' end" )
      migrater.migrate(*up_params).should == {success: [], failed: [file_name_2]}

      # should pass now
      create_migration(file_name_2, "up do end" )
      migrater.migrate(*up_params).should == {success: [file_name_2]}

      # Down
      migrater.migrate(*down_params).should == {success: [file_name_2]}

      # up
      migrater.migrate(*up_params).should == {success: [file_name_2]}

      # should succeed
      create_migration(file_name_3, "up do end" )
      migrater.migrate(*up_params).should == {success: [file_name_3]}

      # should do nothing
      migrater.migrate(*up_params).should == {}

      # resetting the migration causes all to be run next time
      migrater.reset
      migrater.pending_migrations.should == [file_name_1, file_name_2, file_name_3]
      migrater.migrate(*up_params).should == {success: [file_name_1, file_name_2, file_name_3]}

      # Down * 3
      migrater.migrate(*down_params).should == {success: [file_name_3]}
      migrater.migrate(*down_params).should == {success: [file_name_2]}
      migrater.migrate(*down_params).should == {success: [file_name_1]}

      # Down does nothing after going down as far as possible
      migrater.migrate(*down_params).should == {}

      # Now, back up
      migrater.pending_migrations.should == [file_name_1, file_name_2, file_name_3]
      migrater.migrate(*up_params).should == {success: [file_name_1, file_name_2, file_name_3]}

    end
  end
end


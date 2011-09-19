require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'couch-migrate'

describe "CouchMigrate::BaseExecuter" do
  subject{ CouchMigrate::BaseExecuter }
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
          # puts BaseExecuter::Namespaced.constants.grep(/NamespacedFoo/).inspect
          # puts BaseExecuter.constants.grep(/NamespacedFoo/).inspect
          # puts
        end
      EOS

      subject.new([:up], script).go

      # puts Module.constants.grep(/Foo/).inspect
      # puts BaseExecuter::Namespaced.constants.grep(/Foo/).inspect
      # puts BaseExecuter.constants.grep(/Foo/).inspect

      Module.constants.include?(:NamespacedFoo).should == false
      CouchMigrate::BaseExecuter.constants.include?(:NamespacedFoo).should == false
      CouchMigrate::BaseExecuter::Namespaced.constants.include?(:NamespacedFoo).should == true
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


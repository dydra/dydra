require File.join(File.dirname(__FILE__), 'spec_helper')

describe Datagraph::Account do
  before :all do
    @account = Datagraph::Account.new('jhacker') # the demo account
  end

  context "Account#exists?" do
    it "should not raise an exception" do
      lambda { @account.exists? }.should_not raise_error
    end

    it "should return true if the repository exists" do
      @account.exists?.should == true
    end

    it "should return false if the repository does not exist" do
      Datagraph::Account.new('foobar').exists?.should == false
    end
  end

  context "Account#name" do
    it "should not raise an exception" do
      lambda { @account.name }.should_not raise_error
    end

    it "should return a string" do
      @account.name.should be_a(String)
    end

    it "should return the account name" do
      @account.name.should == 'jhacker'
    end
  end

  context "Account#repository(name)" do
    it "should require one argument" do
      lambda { @account.repository() }.should raise_error(ArgumentError)
      lambda { @account.repository('foaf') }.should_not raise_error(ArgumentError)
    end

    it "should not raise an exception" do
      lambda { @account.repository('foaf') }.should_not raise_error
    end

    it "should return a repository" do
      @account.repository('foaf').should be_a(Datagraph::Repository)
    end
  end

  context "Account#repositories" do
    it "should not raise an exception" do
      lambda { @account.repositories }.should_not raise_error
    end

    it "should return an array of repositories" do
      @account.repositories.should be_a(Array)
      @account.repositories.each { |r| r.should be_a(Datagraph::Repository) }
    end

    it "should return the repositories belonging to the account" do
      @account.repositories.should == [@account.repository('foaf')]
    end
  end
end

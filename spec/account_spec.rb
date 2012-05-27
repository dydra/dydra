# This is free and unencumbered software released into the public domain.

require File.join(File.dirname(__FILE__), 'spec_helper')

describe Dydra::Account do
  before :all do
    @account_name = ENV['ACCOUNT'] || 'jhacker' # the demo account
    @account = Dydra::Account.new(@account_name)
  end

  context "Account#exists?" do
    it "should return true if the repository exists" do
      @account.exists?.should == true
    end

    it "should return false if the repository does not exist" do
      Dydra::Account.new('foobar').exists?.should == false
    end
  end

  context "Account#url" do
    it "should return a URL" do
      @account.url.should be_a RDF::URI
    end
  end

  context "Account#path" do
    it "should return a string" do
      @account.path.should be_a String
    end
  end

  context "Account#name" do
    it "should return a string" do
      @account.name.should be_a String
    end

    it "should return the account name" do
      @account.name.should == @account_name
    end
  end

  context "Account#email" do
    it "should return a string" do
      @account.email.should be_a String
    end
  end

  context "Account#fullname" do
    it "should return a string" do
      @account.fullname.should be_a String
    end
  end

  context "Account#repository(name)" do
    it "should require one argument" do
      lambda { @account.repository() }.should raise_error ArgumentError
      lambda { @account.repository('foaf') }.should_not raise_error ArgumentError
    end

    it "should return a repository" do
      @account.repository('foaf').should be_a Dydra::Repository
    end
  end

  context "Account#[name]" do
    it "should return a repository" do
      @account['foaf'].should be_a Dydra::Repository
    end
  end

  context "Account#repositories" do
    it "should return an array of repositories" do
      @account.repositories.should be_an Array
      @account.repositories.each { |r| r.should be_a Dydra::Repository }
    end

    it "should return the repositories belonging to the account" do
      @account.repositories.should == [@account.repository('foaf')]
    end
  end

  context "Account#each_repository" do
    it "should return an enumerator" do
      @account.each_repository.should be_an Enumerator
    end

    it "should yield the repositories belonging to the account" do
      @account.each_repository.to_a.should == @account.repositories
    end
  end
end

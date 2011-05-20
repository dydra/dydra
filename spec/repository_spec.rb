require File.join(File.dirname(__FILE__), 'spec_helper')

describe Dydra::Repository do
  before :all do
    @repository = Dydra::Repository.new('jhacker', 'foaf') # a demo repository
  end

  context "Repository#exists?" do
    it "should not raise an exception" do
      lambda { @repository.exists? }.should_not raise_error
    end

    it "should return true if the repository exists" do
      @repository.exists?.should == true
    end

    it "should return false if the repository does not exist" do
      Dydra::Repository.new('jhacker', 'fooabar').exists?.should == false
    end
  end

  context "Repository#account" do
    it "should not raise an exception" do
      lambda { @repository.account }.should_not raise_error
    end

    it "should return an account" do
      @repository.account.should be_a(Dydra::Account)
    end

    it "should return the correct account" do
      @repository.account.should == Dydra::Account.new('jhacker')
    end
  end

  context "Repository#name" do
    it "should not raise an exception" do
      lambda { @repository.name }.should_not raise_error
    end

    it "should return a string" do
      @repository.name.should be_a(String)
    end

    it "should return the account name" do
      @repository.name.should == 'foaf'
    end
  end

  context "Repository#summary" do
    it "should not raise an exception" do
      lambda { @repository.summary }.should_not raise_error
    end

    it "should return a string" do
      @repository.summary.should be_a(String)
    end
  end

  context "Repository#description" do
    it "should not raise an exception" do
      lambda { @repository.description }.should_not raise_error
    end

    it "should return a string" do
      @repository.description.should be_a(String)
    end
  end

  context "Repository#created" do
    it "should not raise an exception" do
      lambda { @repository.created }.should_not raise_error
    end

    pending "should return a time" do
      @repository.created.should be_a(XMLRPC::DateTime) # FIXME
    end
  end

  context "Repository#updated" do
    it "should not raise an exception" do
      lambda { @repository.updated }.should_not raise_error
    end

    pending "should return a time" do
      @repository.created.should be_a(XMLRPC::DateTime) # FIXME
    end
  end

  context "Repository#query" do
    before :all do
      @query = 'select * where { ?s ?p ?o }'
    end

    it "should not raise an exception" do
      lambda { @repository.query(@query, :format => :parsed) }.should_not raise_error
    end

    it "should return correct results" do
      @repository.query(@query, :format => :parsed).size.should == 10
    end
  end
end

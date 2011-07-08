require File.join(File.dirname(__FILE__), 'spec_helper')

describe Dydra::Repository do
  before :all do
    warn "Running tests against production...not very wise" if ENV['DYDRA_URL'].nil? || ENV['DYDRA_URL'].empty?
    @user = 'jhacker' || ENV['DYDRA-TEST-USER']
    @repo_name = 'foaf' || ENV['DYDRA-TEST-REPO']
    @repository = Dydra::Repository.new(@user, @repo_name) # a demo repository
  end

  context "Repository#exists?" do
    it "should not raise an exception" do
      lambda { @repository.exists? }.should_not raise_error
    end

    it "should return true if the repository exists" do
      @repository.exists?.should == true
    end

    it "should return false if the repository does not exist" do
      Dydra::Repository.new(@user, 'asdfajsdflajsdfasldkfjasdlkf').exists?.should == false
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
      @repository.account.should == Dydra::Account.new(@user)
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
      @repository.name.should == @repo_name
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

    it "should pass through a user query id" do
      @repository.query(@query, :format => :parsed, :user_query_id => "rpsec-test-query").size.should == 10
    end

    it "should recognize 1.1 update query forms" do
      lambda { @repository.query('INSERT DATA { :s :p :o }', :format => :parsed) }.should_not raise_error Dydra::MalformedQuery
    end
  end

  context "Repository#delete and Repository#create" do

    before :all do
      @create = Dydra::Repository.new(@user, 'test-create')
      @create.exists?.should == false
    end

    it "should be createable" do
      @create.create!
      @create.exists?.should == true
    end

    it "should be empty on creation" do
      @create.count.should == 0
    end

    it "should return a 422 if it already exists" do
      lambda { @create.create! }.should raise_error(RestClient::UnprocessableEntity)
    end

    it "should be deleteable" do
      @create.destroy!
      @create.exists?.should == false
    end
  end

  context "Repository#insert" do

    before :each do
      @import = Dydra::Repository.new(@user, 'test-importer')
      begin @import.create! rescue RestClient::UnprocessableEntity end
      @import.clear!.wait!
    end

    it "should insert an array of statements" do
      statements = [RDF::Statement.new(RDF::SIOC.type, RDF::FOAF.name, 'sioc-type'),
                    RDF::Statement.new(RDF::SIOC.subject, RDF::FOAF.name, 'sioc-subject')]
      @import.insert(*statements)
      result = @import.query('select * where { ?s ?p ?o }', :format => :parsed)
      result.size.should == 2
      result.first.p.should == RDF::FOAF.name
    end

    it "should insert an array of statements with correct graphs" do
      statements = [RDF::Statement.new(RDF::SIOC.type, RDF::FOAF.name, 'sioc-type', :context => RDF::FOAF.context),
                    RDF::Statement.new(RDF::SIOC.subject, RDF::FOAF.name, 'sioc-subject', :context => RDF::FOAF.another_context),
                    RDF::Statement.new(RDF::SIOC.name, RDF::FOAF.name, 'sioc-name')]
      @import.insert(*statements)
      result = @import.query('select * where { { graph ?g { ?s ?p ?o }} union { ?s ?p ?o }}', :format => :parsed)
      result.size.should == 3
      result.map { |r| r.g }.should =~ [RDF::FOAF.another_context, RDF::FOAF.context, nil]
    end

    it "should insert an array of statements without a default graph" do
      statements = [RDF::Statement.new(RDF::SIOC.type, RDF::FOAF.name, 'sioc-type', :context => RDF::FOAF.context),
                    RDF::Statement.new(RDF::SIOC.subject, RDF::FOAF.name, 'sioc-subject', :context => RDF::FOAF.another_context)]
      @import.insert(*statements)
      result = @import.query('select * where { { graph ?g { ?s ?p ?o }} union { ?s ?p ?o }}', :format => :parsed)
      result.size.should == 2
      result.map { |r| r.g }.should =~ [RDF::FOAF.another_context, RDF::FOAF.context]
    end
  end
end

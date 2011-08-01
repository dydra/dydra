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

    it "should recognize query forms on a line by themselves" do
      @repository.query("select\n* where {?s ?p ?o }", :format => :parsed)
      lambda { @repository.query("select\n* where {:s :p :o }", :format => :parsed) }.should_not raise_error Dydra::MalformedQuery
    end

    it "should recognize insert data query forms on a line by themselves" do
      lambda { @repository.query("INSERT DATA\n{:s :p :o }", :format => :parsed) }.should_not raise_error Dydra::MalformedQuery
    end

    it "should recognize query forms without trailing whitespace" do
      lambda { @repository.query("CONSTRUCT{ ?P foaf:name ?FullName } where { ?P ?pred ?FullName}", :format => :parsed) }.should_not raise_error Dydra::MalformedQuery
    end

    it "should raise a query error instead of an HTTP error for bad queries" do
      # note un-prefixed :, sparql endpoint will cry about undeclared prefixes
      lambda { @repository.query('select * where { :s :p :o }', :format => :parsed) }.should raise_error Dydra::QueryError
    end

    # FIXME: working 1.1 update query
    it "should correctly parse optional results" do
      @repository = Dydra::Repository.new(@user, 'test-optional')
      begin @repository.create! rescue RestClient::UnprocessableEntity end
      statements = [RDF::Statement.new(RDF::SIOC.type, RDF::FOAF.name, 'sioc-type', :context => RDF::FOAF.context),
                    RDF::Statement.new(RDF::SIOC.subject, RDF::FOAF.name, 'sioc-subject', :context => RDF::FOAF.another_context),
                    RDF::Statement.new(RDF::SIOC.name, RDF::FOAF.name, 'sioc-name')]
      @repository.insert(*statements)

      result = @repository.query('select * where { { ?s ?p ?o } union { graph ?g { ?s ?p ?o} } }', :format => :parsed)
    end

    context "result parsing" do
      it "should parse json-columns ASK results" do
        Dydra::Client.should_receive(:post).and_return('{"columns": ["result"], "rows": [ [true] ], "total": 1}')
        result = @repository.query('INSERT DATA { :s :p :o }', :format => :parsed)
        result.should be_true
      end
    end
  end

  context "Repository#destroy and Repository#create" do

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

    it "should be destroyable" do
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

  context "Repository#delete" do
    before :each do
      @delete = Dydra::Repository.new(@user, 'test-deletion')
      begin @delete.create! rescue RestClient::UnprocessableEntity end
      statements = [RDF::Statement.new(RDF::SIOC.type, RDF::FOAF.name, 'sioc-type', :context => RDF::FOAF.context),
                    RDF::Statement.new(RDF::SIOC.subject, RDF::FOAF.name, 'sioc-subject', :context => RDF::FOAF.another_context),
                    RDF::Statement.new(RDF::SIOC.name, RDF::FOAF.name, 'sioc-name')]
      @delete.insert(*statements)
    end

    it "should delete a particular statement from a hash" do
      @delete.delete(:subject => RDF::SIOC.name, :predicate => RDF::FOAF.name, :object => 'sioc-name')
      @delete.query("select * where { <#{RDF::SIOC.name}> <#{RDF::FOAF.name}> 'sioc-name' }", :format => :parsed).size.should == 0
      @delete.count.should == 2
    end

    pending "should delete a particular statement from a triple" do
      @delete.delete([RDF::SIOC.name, RDF::FOAF.name, 'sioc-name'])
      @delete.query("select * where { <#{RDF::SIOC.name}>, <#{RDF::FOAF.name}>, 'sioc-name' }").size.should == 0
      @delete.size.should == 2
    end

    pending "should delete a pattern from a hash" do
      @delete.delete(:subject => RDF::SIOC.name)
      @delete.query("select * where { <#{RDF::SIOC.name}> ?p ?o }").size.should == 0
      @delete.size.should == 2
    end

  end
end

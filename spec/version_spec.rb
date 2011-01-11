require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'Dydra::VERSION' do
  it "should match the VERSION file" do
    Dydra::VERSION.to_s.should == File.read(File.join(File.dirname(__FILE__), '..', 'VERSION')).chomp
  end
end

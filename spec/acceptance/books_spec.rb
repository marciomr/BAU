require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "Feature name", %q{
  In order to ...
  As a ...
  I want to ...
} do

  scenario "Scenario name" do
    true.should == true
  end
end

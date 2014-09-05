#encoding : utf-8
require 'spec_helper'

require 'eclipse/workspace'

describe 'workspace' do

  before :all do
    @dataDir =  File.expand_path(File.join(File.dirname(__FILE__), 'data'))
  end

  it "should run the readme example" do
    installation = File.expand_path(File.join(@dataDir, 'installation'))
    File.directory?(installation).should == true
    workspace =  Eclipse::Workspace.new(installation)
    workspace.parse
    workspace.views.size.should == 49
    workspace.view_categories.size.should == 7
    workspace.preferencePages.size.should == 3
    workspace.preferencePage_categories.size.should == 1
    workspace.perspectives.size.should == 7
  end

  it "should find feature from an installed application" do
    installation = File.expand_path(File.join(@dataDir, 'installation'))
    File.directory?(installation).should == true
    workspace =  Eclipse::Workspace.new(installation)
    workspace.parse
    workspace.views.size.should == 49
    workspace.view_categories.size.should == 7
    workspace.preferencePages.size.should == 3
    workspace.preferencePage_categories.size.should == 1
    workspace.perspectives.size.should == 7
    workspace.features.size.should == 1
    id = 'ch.elexis.core.application.feature'
    workspace.features.each{ 
      |key, value|
      key.should == id
      value.symbolicName.should  == id
    }
  end

  it "should work with a simulated checkout of the elexis-3-core" do
    elexis_core = File.expand_path(File.join(@dataDir, 'source'))
    File.directory?(elexis_core).should == true
    workspace =  Eclipse::Workspace.new(elexis_core)
    workspace.parse
    workspace.features.size.should == 2
    workspace.view_categories.size.should == 8
    workspace.preferencePage_categories.size.should == 0
    workspace.perspectives.size.should == 9
    workspace.plugins.size.should == 3
    workspace.preferencePages.size.should == 1
    workspace.views.size.should > 3
    workspace.perspectives.first.should_not be nil
    workspace.preferencePages.first.should_not be nil
    workspace.view_categories.first.should_not be nil
    workspace.preferencePage_categories.first.should be nil
    workspace.views.size.should == 52
  end


end
#encoding : utf-8
require 'spec_helper'

require 'eclipse/workspace'

describe 'workspace' do

  before :all do
    @dataDir =  File.expand_path(File.join(File.dirname(__FILE__), 'data'))
  end

  it "should run the readme example" do
      require 'eclipse/plugin'
      workspace =  Eclipse::Workspace.new(@dataDir)
      workspace.parsePluginDir
      workspace.views.first {|view| puts view.id }
      workspace.views.size.should == 49
      workspace.view_categories.size.should == 7
      workspace.preferencePages.size.should == 3
      workspace.preferencePage_categories.size.should == 1
      workspace.perspectives.size.should == 7
  end

  it "should work with a source workspace" do
    plugin = File.join('/opt/src/elexis-3-core')
    workspace =  Eclipse::Workspace.new(File.join(@dataDir, 'source'))
    workspace.parse_sub_dirs
    workspace.views.first.should_not be nil
    workspace.perspectives.first.should_not be nil
    workspace.preferencePages.first.should_not be nil
    workspace.view_categories.first.should_not be nil
    workspace.preferencePage_categories.first.should be nil
    workspace.views.size.should == 52
    workspace.view_categories.size.should == 8
    workspace.preferencePages.size.should == 1
    workspace.preferencePage_categories.size.should == 0
    workspace.perspectives.size.should == 9
    workspace.plugins.size.should == 3
  end

end
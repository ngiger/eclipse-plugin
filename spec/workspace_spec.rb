#encoding : utf-8
require 'spec_helper'

require 'eclipse/workspace'

describe 'workspace' do

  before :all do
    @dataDir =  File.expand_path(File.join(File.dirname(__FILE__), 'data'))
  end

  it "should run the readme example" do
    installation = File.expand_path(File.join(@dataDir, 'installation'))
    expect(File.directory?(installation)).to eq(true)
    workspace =  Eclipse::Workspace.new(installation)
    workspace.parse
    expect(workspace.views.size).to eq(49)
    expect(workspace.view_categories.size).to eq(7)
    expect(workspace.preferencePages.size).to eq(3)
    expect(workspace.preferencePage_categories.size).to eq(1)
    expect(workspace.perspectives.size).to eq(7)
  end

  it "should find feature from an installed application" do
    installation = File.expand_path(File.join(@dataDir, 'installation'))
    expect(File.directory?(installation)).to eq(true)
    workspace =  Eclipse::Workspace.new(installation)
    workspace.parse
    expect(workspace.views.size).to eq(49)
    expect(workspace.view_categories.size).to eq(7)
    expect(workspace.preferencePages.size).to eq(3)
    expect(workspace.preferencePage_categories.size).to eq(1)
    expect(workspace.perspectives.size).to eq(7)
    expect(workspace.features.size).to eq(1)
    id = 'ch.elexis.core.application.feature'
    workspace.features.each{ 
      |key, value|
      expect(key).to eq(id)
      expect(value.symbolicName).to  eq(id)
    }
  end

  it "should work with a simulated checkout of the elexis-3-core" do
    elexis_core = File.expand_path(File.join(@dataDir, 'source'))
    expect(File.directory?(elexis_core)).to eq(true)
    workspace =  Eclipse::Workspace.new(elexis_core)
    workspace.parse
    expect(workspace.features.size).to eq(2)
    expect(workspace.view_categories.size).to eq(8)
    expect(workspace.preferencePage_categories.size).to eq(0)
    expect(workspace.perspectives.size).to eq(9)
    expect(workspace.plugins.size).to eq(3)
    expect(workspace.preferencePages.size).to eq(1)
    expect(workspace.views.size).to be > 3
    expect(workspace.perspectives.first).not_to be nil
    expect(workspace.preferencePages.first).not_to be nil
    expect(workspace.view_categories.first).not_to be nil
    expect(workspace.preferencePage_categories.first).to be nil
    expect(workspace.views.size).to eq(52)
  end


end

#encoding : utf-8
require 'spec_helper'

require 'eclipse/plugin'

describe 'Plugin' do

  CHECK_4_VIEW            = 'ch.elexis.views.TemplatePrintView'
  CHECK_4_PERSPECTIVE     = 'elexis.articlePerspective'
  CHECK_4_PREFERENCE_PAGE = 'org.iatrix.preferences.IatrixPreferences'
  APP_JAR                 = 'ch.elexis.core.application_3.0.0.v20140314-1352.jar'
  IATRIX_JAR              = 'org.iatrix_3.0.0.v20140313-1017.jar'
  JAR_WITHOUT_LOCALIZE    = 'ch.elexis.laborimport.hl7.allg-3.0.0-SNAPSHOT.jar'
  before :all do
    @dataDir =  File.expand_path(File.join(File.dirname(__FILE__), 'data'))
  end

  it "should run the readme example" do
      require 'eclipse/plugin'
      workspace =  Eclipse::Workspace.new(@dataDir)
      workspace.parsePluginDir
      workspace.views.first {|view| puts view.id }
      workspace.views.size.should == 66
  end

  it "must be able to analyse a plugin.xml without localization" do
    plugin = File.join(@dataDir, 'plugins', JAR_WITHOUT_LOCALIZE)
    info = Eclipse::Plugin::Info.new(plugin)
    info.preferencePages['ch.elexis.laborimport.hl7.preferences'].should_not be nil
    info.workspace.should == @dataDir
  end

  it "must be able to analyse a plugin.xml with localization" do
    plugin = File.join(@dataDir, 'plugins', IATRIX_JAR)
    info = Eclipse::Plugin::Info.new(plugin)
    info.views['org.iatrix.views.JournalView'].should_not be nil
    info.view_categories['org.iatrix'].should_not be nil
    info.workspace.should == @dataDir
  end

  it "must return the perspectives" do
    plugin = File.join(@dataDir, 'plugins', APP_JAR)
    info = Eclipse::Plugin::Info.new(plugin)
    info.perspectives[CHECK_4_PERSPECTIVE].should_not be nil
  end

  it "must return the preferencePages" do
    plugin = File.join(@dataDir, 'plugins', IATRIX_JAR)
    info = Eclipse::Plugin::Info.new(plugin)
    info.preferencePages[CHECK_4_PREFERENCE_PAGE].should_not be nil
  end

  it "must return the correct translation for a view" do
    plugin = File.join(@dataDir, 'plugins', APP_JAR)
    info = Eclipse::Plugin::Info.new(plugin)
    info.views[CHECK_4_VIEW].should_not be nil
    german = 'Vorlage Drucken'
    info.views[CHECK_4_VIEW].translation.should == german
    pp info.getTranslatedViews.find_all{ |item| item.match(german) }
    info.workspace.should == @dataDir
    info.getTranslatedViews.find_all{ |item| item.match(german) }.should_not be nil
  end

  it "must return the correct translation for a preferencePage" do
    plugin = File.join(@dataDir, 'plugins', IATRIX_JAR)
    info = Eclipse::Plugin::Info.new(plugin)
    info.preferencePages[CHECK_4_PREFERENCE_PAGE].should_not be nil
    german = 'Iatrix'
    info.preferencePages[CHECK_4_PREFERENCE_PAGE].translation.should == german
    info.workspace.should == @dataDir
    info.getTranslatedPreferencePages.find_all{ |item| item.match(german) }.should_not be nil
  end

  it "must return the correct translation for a perspective" do
    plugin = File.join(@dataDir, 'plugins', APP_JAR)
    info = Eclipse::Plugin::Info.new(plugin)
    info.perspectives[CHECK_4_PERSPECTIVE].should_not be nil
    german = 'Artikel'
    info.perspectives[CHECK_4_PERSPECTIVE].translation.should == german
    info.workspace.should == @dataDir
    info.getTranslatedPerspectives.find_all{ |item| item.match(german) }.should_not be nil
  end

end

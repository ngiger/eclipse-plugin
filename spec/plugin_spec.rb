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
    @dataDir    = File.expand_path(File.join(File.dirname(__FILE__), 'data'))
    @installDir = File.expand_path(File.join(File.dirname(__FILE__), 'data', 'installation'))
    @pluginsDir = File.expand_path(File.join(File.dirname(__FILE__), 'data', 'installation', 'plugins'))
  end

  it "must be able to analyse a plugin.xml without localization" do
    plugin = File.join(@pluginsDir, JAR_WITHOUT_LOCALIZE)
    info = Eclipse::Plugin::Info.new(plugin)
    info.preferencePages['ch.elexis.laborimport.hl7.preferences'].should_not be nil
    info.workspace.should == @installDir
  end

  it "must be able to analyse a plugin.xml with localization" do
    plugin = File.join(@pluginsDir, IATRIX_JAR)
    info = Eclipse::Plugin::Info.new(plugin)
    info.views['org.iatrix.views.JournalView'].should_not be nil
    info.view_categories['org.iatrix'].should_not be nil
    info.workspace.should == @installDir
  end

  it "must return the perspectives" do
    plugin = File.join(@pluginsDir, APP_JAR)
    info = Eclipse::Plugin::Info.new(plugin)
    info.perspectives[CHECK_4_PERSPECTIVE].should_not be nil
  end

  it "must return the preferencePages" do
    plugin = File.join(@pluginsDir, IATRIX_JAR)
    info = Eclipse::Plugin::Info.new(plugin)
    info.preferencePages[CHECK_4_PREFERENCE_PAGE].should_not be nil
  end

  it "must return the correct translation for a view" do
    plugin = File.join(@pluginsDir, APP_JAR)
    info = Eclipse::Plugin::Info.new(plugin)
    info.views[CHECK_4_VIEW].should_not be nil
    german = 'Vorlage Drucken'
    info.views[CHECK_4_VIEW].translation.should == german
    pp info.getTranslatedViews.find_all{ |item| item.match(german) }
    info.workspace.should == @installDir
    info.getTranslatedViews.find_all{ |item| item.match(german) }.should_not be nil
  end

  it "must return the correct translation for a preferencePage" do
    plugin = File.join(@pluginsDir, IATRIX_JAR)
    info = Eclipse::Plugin::Info.new(plugin)
    info.preferencePages[CHECK_4_PREFERENCE_PAGE].should_not be nil
    german = 'Iatrix'
    info.preferencePages[CHECK_4_PREFERENCE_PAGE].translation.should == german
    info.workspace.should == @installDir
    info.getTranslatedPreferencePages.find_all{ |item| item.match(german) }.should_not be nil
  end

  it "must return the correct translation for a perspective" do
    plugin = File.join(@pluginsDir, APP_JAR)
    info = Eclipse::Plugin::Info.new(plugin)
    info.perspectives[CHECK_4_PERSPECTIVE].should_not be nil
    german = 'Artikel'
    info.perspectives[CHECK_4_PERSPECTIVE].translation.should == german
    info.workspace.should == @installDir
    info.getTranslatedPerspectives.find_all{ |item| item.match(german) }.should_not be nil
  end

  it "should work with a source plugin" do
    info = Eclipse::Plugin::Info.new(File.join(@dataDir, 'source', 'ch.elexis.core.ui.contacts'))
    info.jar_or_src.should_not be nil
    info.views.first.should_not be nil
    info.perspectives.first.should_not be nil
    info.preferencePages.first.should_not be nil
    info.view_categories.first.should_not be nil
    # info.preferencePage_categories.first.should_not be nil
  end

end

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
    expect(info.preferencePages['ch.elexis.laborimport.hl7.preferences']).not_to be nil
    expect(info.workspace).to eq(@installDir)
  end

  it "must be able to analyse a plugin.xml with localization" do
    plugin = File.join(@pluginsDir, IATRIX_JAR)
    info = Eclipse::Plugin::Info.new(plugin)
    expect(info.views['org.iatrix.views.JournalView']).not_to be nil
    expect(info.view_categories['org.iatrix']).not_to be nil
    expect(info.workspace).to eq(@installDir)
  end

  it "must return the perspectives" do
    plugin = File.join(@pluginsDir, APP_JAR)
    info = Eclipse::Plugin::Info.new(plugin)
    expect(info.perspectives[CHECK_4_PERSPECTIVE]).not_to be nil
  end

  it "must return the preferencePages" do
    plugin = File.join(@pluginsDir, IATRIX_JAR)
    info = Eclipse::Plugin::Info.new(plugin)
    expect(info.preferencePages[CHECK_4_PREFERENCE_PAGE]).not_to be nil
  end

  it "must return the correct translation for a view" do
    plugin = File.join(@pluginsDir, APP_JAR)
    info = Eclipse::Plugin::Info.new(plugin)
    expect(info.views[CHECK_4_VIEW]).not_to be nil
    german = 'Vorlage Drucken'
    expect(info.views[CHECK_4_VIEW].translation).to eq(german)
    puts info.getTranslatedViews.find_all{ |item| item.match(german) }
    expect(info.workspace).to eq(@installDir)
    expect(info.getTranslatedViews.find_all{ |item| item.match(german) }).not_to be nil
  end

  it "must return the correct translation for a preferencePage" do
    plugin = File.join(@pluginsDir, IATRIX_JAR)
    info = Eclipse::Plugin::Info.new(plugin)
    expect(info.preferencePages[CHECK_4_PREFERENCE_PAGE]).not_to be nil
    german = 'Iatrix'
    expect(info.preferencePages[CHECK_4_PREFERENCE_PAGE].translation).to eq(german)
    expect(info.workspace).to eq(@installDir)
    expect(info.getTranslatedPreferencePages.find_all{ |item| item.match(german) }).not_to be nil
  end

  it "must return the correct translation for a perspective" do
    plugin = File.join(@pluginsDir, APP_JAR)
    info = Eclipse::Plugin::Info.new(plugin)
    expect(info.perspectives[CHECK_4_PERSPECTIVE]).not_to be nil
    german = 'Artikel'
    expect(info.perspectives[CHECK_4_PERSPECTIVE].translation).to eq(german)
    expect(info.workspace).to eq(@installDir)
    expect(info.getTranslatedPerspectives.find_all{ |item| item.match(german) }).not_to be nil
  end

  it "should work with a source plugin" do
    info = Eclipse::Plugin::Info.new(File.join(@dataDir, 'source', 'bundles', 'ch.elexis.core.ui.contacts'))
    expect(info.jar_or_src).not_to be nil
    expect(info.views.first).not_to be nil
    expect(info.perspectives.first).not_to be nil
    expect(info.preferencePages.first).not_to be nil
    expect(info.view_categories.first).not_to be nil
    # info.preferencePage_categories.first.should_not be nil
  end

end

#encoding : utf-8
require 'spec_helper'

require 'eclipse/plugin'

describe 'Plugin' do

  before :each do
    @dataDir =  File.expand_path(File.join(File.dirname(__FILE__), 'data'))
  end
  
  it "must be able to analyse a plugin.xml without localization" do
    plugin = File.join(@dataDir, 'ch.elexis.laborimport.hl7.allg-3.0.0-SNAPSHOT.jar')
    info = Eclipse::Plugin::Info.new(plugin, @dataDir)
  end

end

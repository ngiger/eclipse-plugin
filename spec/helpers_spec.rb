#encoding : utf-8
require 'spec_helper'

require 'eclipse/plugin'
require 'eclipse/helpers'

describe 'Helpers' do

  before :each do
    @dataDir =  File.expand_path(File.join(File.dirname(__FILE__), 'data'))
  end

  it "should escape a property_string into an UTF-8 string" do
     IO.readlines(File.join(@dataDir, 'plugin_de.properties')).each{
       |line|
        next unless line.index('Add_Recurring_Appointment')
        unescaped = Eclipse::Helpers.unescape(line)
        unescaped.should match /hinzufügen/
     }
  end
end

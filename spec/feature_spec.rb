#encoding : utf-8
require 'spec_helper'

require 'eclipse/feature'

describe 'Feature' do

  FEATURE_NAME            =  'ch.elexis.core.application.feature'

  before :all do
    @dataDir =  File.expand_path(File.join(File.dirname(__FILE__), 'data'))
  end

  it "must be able to analyse a feature.xml" do
    feature = File.join(@dataDir, 'source', 'features', FEATURE_NAME)
    f_info = Eclipse::Feature::Info.new(feature)
    expect(f_info.symbolicName).to eq(FEATURE_NAME)
    expect(f_info.included_features).to  eq(["ch.docbox.elexis.feature"])
    expect(f_info.included_plugins.size).to  be > 10
    expect(f_info.description).not_to eq(nil)
    expect(f_info.label).not_to eq(nil)
    expect(f_info.license).not_to eq(nil)
  end

  it "must be able to analyse a feature.jar" do
    feature = Dir.glob(File.join(@dataDir, 'features', FEATURE_NAME+'*.jar'))[0]
    f_info = Eclipse::Feature::Info.new(feature)
    expect(f_info.symbolicName).to eq(FEATURE_NAME)
    expect(f_info.included_features).to  eq([])
    expect(f_info.included_plugins.size).to  be > 10
    expect(f_info.description).not_to eq(nil)
    expect(f_info.label).not_to eq(nil)
    expect(f_info.license).not_to eq(nil)
  end

end

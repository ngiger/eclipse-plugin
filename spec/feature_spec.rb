#encoding : utf-8
require 'spec_helper'

require 'eclipse/feature'

describe 'Feature' do

  FEATURE_NAME            =  'ch.elexis.core.application.feature'

  before :all do
    @dataDir =  File.expand_path(File.join(File.dirname(__FILE__), 'data'))
  end

  it "must be able to analyse a feature.xml" do
    feature = File.join(@dataDir, 'source', FEATURE_NAME)
    f_info = Eclipse::Feature::Info.new(feature)
    f_info.symbolicName.should == FEATURE_NAME
    f_info.included_features.should  == ["ch.docbox.elexis.feature"]
    f_info.included_plugins.size.should  > 10
    f_info.description.should_not ==  nil
    f_info.label.should_not == nil
    f_info.license.should_not == nil
  end

  it "must be able to analyse a feature.jar" do
    feature = Dir.glob(File.join(@dataDir, 'features', FEATURE_NAME+'*.jar'))[0]
    f_info = Eclipse::Feature::Info.new(feature)
    f_info.symbolicName.should == FEATURE_NAME
    f_info.included_features.should  == []
    f_info.included_plugins.size.should  > 10
    f_info.description.should_not ==  nil
    f_info.label.should_not == nil
    f_info.license.should_not == nil
  end

end

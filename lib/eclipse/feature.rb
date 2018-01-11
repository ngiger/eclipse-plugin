require "eclipse/plugin/version"
require "eclipse/helpers"
require "eclipse/workspace"
require 'zip'
require "nokogiri"

module Eclipse
  module Feature
    class Info
      attr_reader :included_plugins, :included_features
      attr_reader :symbolicName, :id, :label, :version, :provider, :description, :license, :copyright

      def getFeatureInfo(content)
        @included_plugins = []
        @included_features = []
        doc = Nokogiri::XML(content)
        @symbolicName = doc.root.attributes['id'].text
        @label        = doc.root.attributes['label'].text
        @version      = doc.root.attributes['version'].text
        @provider     = doc.root.attributes['provider'] ? doc.root.attributes['provider'].text     : ''
        @description  = doc.search('description') ? doc.search('description').text                 : ''
        @license      = doc.search('license')     ? doc.search('license').text.gsub(/\n\s*/, '')   : ''
        @copyright    = doc.search('copyright')   ? doc.search('copyright').text.gsub(/\n\s*/, '') : ''
        doc.search('plugin').each   { |s| @included_plugins  << s.attribute('id').text }
        doc.search('includes').each { |s| @included_features << s.attribute('id').text }
      end
      def initialize(jar_or_src_dir)
        featureXml = File.join(jar_or_src_dir, 'feature.xml')
        if File.directory?(jar_or_src_dir)
          getFeatureInfo(File.read(featureXml))
        elsif File.exists?(jar_or_src_dir)
          @jarfile = Zip::File.open(jar_or_src_dir)
          if @jarfile.find_entry('feature.xml')
            getFeatureInfo(@jarfile.read('feature.xml'))
          else
            raise("#{jar_or_src_dir} must contain a feature.xml")
          end
        else
          raise("#{jar_or_src_dir} must be feature.jar or point to a directory containing a feature.xml")
        end    
      end
    end
  end
end

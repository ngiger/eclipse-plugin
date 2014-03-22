require "eclipse/plugin/version"
require "eclipse/helpers"
require "eclipse/workspace"

require 'zip/zip'
require "rexml/document"
include REXML  # so that we don't have to prefix everything with REXML::...

module Eclipse
  module Plugin
    class Info
      attr_reader :iso, :views, :view_categories, :preferencePages, :perspectives, :workspace, :preferencePage_categories
      attr_reader :symbolicName, :feature, :jar_or_src
      # Some helper classes for the extension points we are interested in
      UI_PreferencePage = Struct.new('UI_PreferencePage', :id, :category, :translation)
      UI_View           = Struct.new('UI_View',           :id, :category, :translation)
      UI_Perspective    = Struct.new('UI_Perspective',    :id, :category, :translation)
      Feature           = Struct.new('Feature',           :id, :label, :version, :provider, :description, :license, :copyright)
      Category          = Struct.new('Category',          :id, :name, :translation)

      # method parse copied from buildr.apache.org/lib/buildr/java/packaging.rb
      # Avoids pulling in buildr with a lot of dependencies
      # :call-seq:
      #   parse(str) => manifest
      #
      # Parse a string in MANIFEST.MF format and return a new Manifest.
      LINE_SEPARATOR = /\r\n|\n|\r[^\n]/ #:nodoc:
      SECTION_SEPARATOR = /(#{LINE_SEPARATOR}){2}/ #:nodoc:
      def parse(str)
        sections = str.split(SECTION_SEPARATOR).reject { |s| s.strip.empty? }
        sections = sections.map { |section|
          lines = section.split(LINE_SEPARATOR).inject([]) { |merged, line|
            if line[/^ /] == ' '
              merged.last << line[1..-1]
            else
              merged << line
            end
            merged
          }
          lines.map { |line| line.scan(/(.*?):\s*(.*)/).first }.
            inject({}) { |map, (key, value)| map.merge(key=>value) }
        }
        sections
      end

      def getFeatureInfo(content)
        doc = Document.new(content)
        doc.root.elements
        @feature = Feature.new(doc.root.attributes['id'],
                               doc.root.attributes['label'],
                               doc.root.attributes['version'],
                               doc.root.attributes['provider'],
                               doc.root.elements['description'].text,
                               doc.root.elements['license'].text.gsub(/\n\s*/, ''),
                               doc.root.elements['copyright'].text.gsub(/\n\s*/, '')
                              )
        # could enumerate a lot of plugins and which other features are included
        # doc.root.elements['plugin'].attributes['id']
      end
      
      def initialize(jar_or_src, iso='de')
        @workspace                 = File.dirname(jar_or_src).sub(/\/plugins$/, '')
        @iso                       = iso
        @jar_or_src                = jar_or_src
        @feature                   = nil
        @views                     = Hash.new
        @view_categories           = Hash.new
        @preferencePages           = Hash.new
        @perspectives              = Hash.new
        @preferencePage_categories       = Hash.new
        # we use hashes to be able to find the categories fast
        if File.directory?(jar_or_src)
          @jarfile = nil
          readPluginXML(jar_or_src)
          mfName = File.join(jar_or_src, 'META-INF', 'MANIFEST.MF')
          featureName = File.join(jar_or_src, 'feature.xml')
          if File.exists?(featureName)
            getFeatureInfo(File.read(featureName))
          elsif File.exists?(mfName)
            getSymbolicNameFrom(File.read(mfName))
          end
        else
          @jarfile                   = Zip::ZipFile.open(jar_or_src)
          readPluginXML(File.basename(jar_or_src))
          if @jarfile.find_entry('feature.xml')
            getFeatureInfo(@jarfile.read('feature.xml'))
          elsif @jarfile.find_entry('META-INF/MANIFEST.MF')
            getSymbolicNameFrom(@jarfile.read('META-INF/MANIFEST.MF'))
          end
        end
#        @nonfree = /medelexis/i.match(File.dirname(File.dirname(plugin)))

        if false
#      rescue => e # HACK: we need this to handle org.apache.commons.lang under Windows-7
        puts "Skipped plugin #{File.expand_path(jar_or_src)}"
#        puts "error was #{e.inspect}"
        puts caller
        end
      end

      def show
        puts "Plugin: #{@jar_or_src} with #{@views.size}/#{@view_categories.size} views #{@preferencePages.size}/#{@preferencePage_categories.size} preferencePages #{@perspectives.size} perspectives"
      end
      
      def addCategory(hash, id, name = nil)
        return if hash[id] and hash[id].translation
        hash[id] = Category.new(id, name) unless hash[id]
        translation = getTranslationForPlugin(name, @iso) if name
        hash[id].translation = translation if name and translation
        puts "#{File.basename(@jarname)}: Added category #{id} name #{name} tr '#{translation}'" if $VERBOSE
      end

      def getTranslatedPreferencePages
        all = []
        @preferencePages.each{
          |id, content|
            unless content.category
              next if @preferencePages.find { |sub_id, x| x.category.eql?(content.id) }
            end
            category =  content.category
            cat_trans = content.translation
            text = nil
            if @preferencePage_categories[category]
              text = "#{@preferencePage_categories[category].translation}/#{content.translation}"
              puts "preferencePages #{id} category #{category.inspect} text #{cat_trans}" if $VERBOSE
            else
              text = content.translation
              puts "preferencePages #{id} text #{text}" if $VERBOSE
            end
            all << text
        }
        all.sort.reverse.uniq if all and all.size > 0
      end

      def getTranslatedViews
        all = []
        @views.each{
          |id, content|
            category =  content.category
            cat_trans = content.translation
            text = nil
            if category
              text = "#{@view_categories[category].translation}/#{content.translation}"
            else
              text = "Other/#{content.translation}"
            end
            all << text if text
        }
        all.sort.reverse.uniq if all and all.size > 0
      end
      def getTranslatedPerspectives
        all = []
        @perspectives.each{
          |id, content|
            category =  content.category
            cat_trans = content.translation
            text = nil
            if category
              text = "#{@perspectives[category].translation}/#{content.translation}"
              puts "perspectives #{id} category #{category.inspect} text #{cat_trans}" if $VERBOSE
            else
              text = content.translation
              puts "perspectives #{id} categories #{category} text #{text}" if $VERBOSE
            end
            all << text
        }
        all.sort.reverse.uniq if all and all.size > 0
      end

      def getTranslationForPlugin(look_for, iso)
        properties = "plugin_#{iso}.properties"
        puts "Looking for translation of #{look_for} in #{properties}"  if $VERBOSE
        content = nil
        if @jarfile
          content = @jarfile.read(properties) if @jarfile.find_entry(properties)
        else
          name = File.join(@jar_or_src, "plugin.properties")
          properties = File.new(name).read if File.exists?(name)
        end
        return look_for unless content                                
        line_nr = 0
        content.split("\n").each {
          |line|
              line_nr += 1
              id,value = line.split(' = ')
              if id and id.index(look_for) and value
                return Helpers::unescape(value.sub("\r","").sub("\n",""))
              else id,value = line.split('=')
                return Helpers::unescape(value.sub("\r","").sub("\n","")) if id and id.index(look_for)
              end
        }
        return look_for # default
      end

      def getSymbolicNameFrom(content)
        if content
          mf = parse(content)
          @symbolicName =  mf[0]['Bundle-SymbolicName'].split(';')[0]
        end
      end

      def readPluginXML(plugin)
        if @jarfile
          return unless @jarfile.find_entry('plugin.xml')
          doc = Document.new @jarfile.read('plugin.xml')
        else
          plugin_xml = File.join(plugin, 'plugin.xml')
          return unless File.exists?(plugin_xml)
          doc = Document.new File.new(plugin_xml).read
        end
        # Get all perspectives
        root = doc.root
        res = []
        root.elements.collect { |x| res << x if /org.eclipse.ui.perspectives/.match(x.attributes['point']) }
        res[0].elements.each{
          |x|
          id = x.attributes['name'].sub(/^%/,'')
          @perspectives[id] = UI_Perspective.new(id, nil, getTranslationForPlugin(id, @iso))
        } if res and res[0] and res[0].elements
        puts "found #{@perspectives.size} perspectives in #{plugin}" if $VERBOSE

        # Get all views
        res = []
        root.elements.collect { |x| res << x if /org.eclipse.ui.views/.match(x.attributes['point']) }
        res[0].elements.each{
          |x|
          name     = x.attributes['name'].sub(/^%/,'') if  x.attributes['name']
          id       = x.attributes['id'].sub(/^%/,'')
          if x.name.eql?('category')
            addCategory(@view_categories, id, name)
          elsif x.attributes['name']
            category = x.attributes['category']
            translation =  getTranslationForPlugin(name, @iso)
            puts "#{File.basename(@jarname, '.jar')}: Adding view: id #{id} category #{category.inspect} translation #{translation}" if $VERBOSE
            unless category
              @views[id]           = UI_View.new(id, nil, translation)
            else
              @views[id]           = UI_View.new(id, category, translation)
            end
          end
        } if res and res[0] and res[0].elements
        puts "found #{@views.size} views and #{@view_categories.size} categories" if $VERBOSE

        # Get all preferencePages
        res = []
        root.elements.collect { |x| res << x if /org.eclipse.ui.preferencePages/.match(x.attributes['point']) }
        res[0].elements.each{
          |x|
          name     = x.attributes['name'].sub(/^%/,'')
          id       = x.attributes['id'].sub(/^%/,'')
          category = x.attributes['category']
          addCategory(@preferencePage_categories, id, name) unless category
          translation =  getTranslationForPlugin(name, @iso)
          puts "Adding preferences: id #{id} category #{category.inspect} translation #{translation}" if $VERBOSE
          unless category
            @preferencePages[id]           = UI_PreferencePage.new(id, nil, translation)
          else
            @preferencePages[id]           = UI_PreferencePage.new(id, category, translation)
          end
        } if res and res[0] and res[0].elements
        puts "#{sprintf("%-40s", File.basename(File.dirname(plugin)))}: now #{@preferencePages.size} preferencePages" if $VERBOSE
      end
    end
  end
end

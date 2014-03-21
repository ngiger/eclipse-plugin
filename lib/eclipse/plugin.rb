require "eclipse/plugin/version"

require 'zip'
require "rexml/document"
include REXML  # so that we don't have to prefix everything with REXML::...

module Eclipse
  class Workspace
    attr_reader :workspace_dir, :views, :view_categories, :preferencePages, :perspectives, :prefPage_categories
    def initialize(workspace_dir)
      @workspace_dir             = workspace_dir
      @views                     = Hash.new
      @view_categories           = Hash.new
      @preferencePages           = Hash.new
      @perspectives              = Hash.new
      @prefPage_categories       = Hash.new
    end
    
    def parsePluginDir(plugins_dir = File.join("plugins"))
      name = "#{plugins_dir}/*.jar"
      Dir.glob(name).each{
        |jarname|
          puts "Adding: #{jarname}" if $VERBOSE
          info = Info.new(jarname)
      }
    end
  end
  
  module Plugin
    class Info
      # Some helper classes for the extension points we are interested in
      UI_PreferencePage = Struct.new('UI_PreferencePage', :id, :category, :translation)
      UI_View           = Struct.new('UI_View',           :id, :category, :translation)
      UI_Perspective    = Struct.new('UI_Perspective',    :id, :category, :translation)
      Category          = Struct.new('Category',    :id, :name, :translation)
      attr_reader :iso, :views, :view_categories, :preferencePages, :perspectives

      def initialize(jarname, workspace, iso='de')
        puts "Info #{jarname} ws #{workspace} iso #{iso}" if $VERBOSE
        @iso                       = iso
        @jarname                   = jarname
        @jarfile                   = Zip::File.open(jarname)
        @workspace                 = workspace
        @views                     = Hash.new
        @view_categories           = Hash.new
        @preferencePages           = Hash.new
        @perspectives              = Hash.new
        @prefPage_categories       = Hash.new
        # we use hashes to be able to find the categories fast
        readPluginXML(File.basename(jarname))
      rescue => e # HACK: we need this to handle org.apache.commons.lang under Windows-7
        puts "Skipped plugin #{File.expand_path(jarname)}"
        puts "error was #{e.inspect}"
        puts caller
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
            if @prefPage_categories[category]
              text = "#{@prefPage_categories[category].translation}/#{content.translation}"
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
        properties = "plugin.properties" unless @jarfile.find_entry(properties)
        puts "Looking for translation of #{look_for} in #{properties}"  if $VERBOSE
        line_nr = 0
        @jarfile.read(properties).split("\n").each {
          |line|
              line_nr += 1
              id,value = line.split(' = ')
              if id and id.index(look_for) and value
                return EclipseHelpers::my_unescape(value.sub("\r","").sub("\n",""))
              else id,value = line.split('=')
                return EclipseHelpers::my_unescape(value.sub("\r","").sub("\n","")) if id and id.index(look_for)
              end
        } if @jarfile.find_entry(properties)
        return look_for # default
      end

      def readPluginXML(plugin_xml)
        return unless  @jarfile.find_entry('plugin.xml')
        doc = Document.new @jarfile.read('plugin.xml')
        # Get all perspectives
        root = doc.root
        res = []
        root.elements.collect { |x| res << x if /org.eclipse.ui.perspectives/.match(x.attributes['point']) }
        res[0].elements.each{
          |x|
          id = x.attributes['name'].sub(/^%/,'')
          @perspectives[id] = UI_Perspective.new(id, nil, getTranslationForPlugin(id, @iso))
        } if res and res[0] and res[0].elements
        puts "found #{@perspectives.size} perspectives in #{plugin_xml}" if $VERBOSE

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
          addCategory(@prefPage_categories, id, name) unless category
          translation =  getTranslationForPlugin(name, @iso)
          puts "Adding preferences: id #{id} category #{category.inspect} translation #{translation}" if $VERBOSE
          unless category
            @preferencePages[id]           = UI_PreferencePage.new(id, nil, translation)
          else
            @preferencePages[id]           = UI_PreferencePage.new(id, category, translation)
          end
        } if res and res[0] and res[0].elements
        puts "#{sprintf("%-40s", File.basename(File.dirname(plugin_xml)))}: now #{@preferencePages.size} preferencePages" if $VERBOSE
      end
    end
  end
end

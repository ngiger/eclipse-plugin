require "eclipse/plugin"

module Eclipse
  class Workspace
    attr_reader :workspace_dir, :views, :view_categories, :preferencePages, :perspectives, :preferencePage_categories, :plugins, :features
    def initialize(workspace_dir)
      @workspace_dir             = workspace_dir
      @views                     = Hash.new
      @view_categories           = Hash.new
      @preferencePages           = Hash.new
      @perspectives              = Hash.new
      @preferencePage_categories = Hash.new
      @plugins                   = Hash.new
      @features                  = Hash.new
    end

    def parsePluginDir(plugins_dir = File.join(@workspace_dir, "plugins"))
      Dir.glob("#{plugins_dir}/*.jar").each{
        |jarname|
        info = Plugin::Info.new(jarname)
        next unless info
        add_info(info, jarname) 
      }
      show if $VERBOSE
    end

    def parse
      isInstallation = false
      ['plugins', 'features'].each{ |subdir|
        dir = File.join(@workspace_dir, subdir)
        if File.directory?(dir)
          isInstallation = true
          parsePluginDir(dir)        
        end
      }
      parse_sub_dirs unless isInstallation
    end
    
    def parse_sub_dirs
      Dir.glob("#{@workspace_dir}/*").each{
        |item|
          proj = File.join(item, '.project')
          name = nil
          name = Document.new(File.new(proj).read).root.elements['name'].text if File.exists?(proj)
          next unless File.directory?(item)
          info = Plugin::Info.new(item)
          next unless info # ex. we read a feature
          add_info(info, item)
          if name and info.symbolicName and name != info.symbolicName
            puts "Warning: in #{item} the symbolicName (#{info.symbolicName}) of the plugin differs from the project name #{name}"
          end
      }
      show if $VERBOSE
    end
    def show
      puts "Workspace #{@workspace_dir} with #{@plugins.size} plugins #{@views.size}/#{@view_categories.size} views #{@preferencePages.size}/#{@preferencePage_categories.size} preferencePages #{@perspectives.size} perspectives"
    end
    private
      def add_info(info, dir = nil)
        if info.feature
          @features[info.feature.symbolicName] = info.feature
          return
        end
        if info.symbolicName == nil
          require 'pry'; binding.pry
        end
        return unless info.symbolicName
        @plugins[info.symbolicName] = info
        info.views.each{ |k, v|                       @views[k] = v }
        info.view_categories.each{ |k, v|             @view_categories[k] = v }
        info.perspectives.each{ |k, v|                @perspectives[k] = v }
        info.preferencePages.each{ |k, v|             @preferencePages[k] = v }
        info.preferencePage_categories.each{ |k, v|   @preferencePage_categories[k] = v }
      end
  end
end
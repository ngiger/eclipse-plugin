#encoding : utf-8
require 'iconv' unless String.method_defined?(:encode)

module Eclipse

  module Helpers

    module_function

    # properties files are saved (at least in the cases, that interest me)
    # as ISO-8859-15 files
    def unescape(inhalt)
      if String.method_defined?(:encode)
        inhalt.encode!('UTF-8', 'ISO-8859-15', :invalid => :replace)
      else
        ic = Iconv.new('UTF-8//IGNORE', 'ISO-8859-15')
        inhalt = ic.iconv(inhalt)
      end
    end
  end
end
module Settings
  class TemplatesController < ApplicationController
    def index
      @templates = Dir[Rails.root.join('app', 'templates', '*')].select{ |f| File.file? f }.map{ |f| File.basename f }
    end
  end
end

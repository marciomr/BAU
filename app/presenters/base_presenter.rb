class BasePresenter
  def initialize(object, template)
    @object = object
    @template = template
  end
  
  def self.presents(name)
    define_method(name) do
      @object
    end
  end
  
  def method_missing(method, *args, &block)
    @template.send(method, *args, &block)
  end
    
  def link_field(name, title = name.capitalize, path = search_path(name, book.send(name)), options = {})  
    base_field(name, title) do
      link_to(@object.send(name).to_s, path)
    end
  end
      
  def field(name, title = name.capitalize)
    base_field(name, title) do
      @object.send(name).to_s
    end
  end
  
  private
  
  def base_field(name, title)
    if @object.send("#{name}?")
      content_tag :p do
        content = content_tag :strong do 
          "#{title}: " 
        end 
        content << yield
      end
    end
  end
    
  def pluralize(model_name, singular, plural)
    @object.send(model_name).count == 1 ? singular : plural
  end
  
  def truncate_with_tooltip(name, path = '#', *args)
    options = args.extract_options!      
    link_to truncate(name, :length => 40), path, options.merge(:rel => 'tooltip', :title => name)
  end
  
end

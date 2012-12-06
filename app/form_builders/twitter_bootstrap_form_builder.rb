class TwitterBootstrapFormBuilder < ActionView::Helpers::FormBuilder  

  def method_missing(method, *args, &block)
    @template.send(method, *args, &block)
  end
  
  %w(text_field text_area number_field password_field).each do |method|
    define_method(method) do |name, title, *args|
      options = args.extract_options!
      field_class = [method]
      field_class << options[:class] if options[:class]
      content_tag(:div, :class => 'control-group') do
        label(name, title, :class => 'control-label') + 
        content_tag(:div, :class => 'controls') do
          super(name, :class => field_class.join(' ')) +
          if options[:remove_link]
            content_tag(:span, :class => "help-inline") do
              link_to_remove_fields raw("&times;"), self
            end
          end
        end 
      end
    end
  end
  
  def multiple_field(name, title, field, *args)
    content = fields_for("#{name}s") do |b|
      render :partial => 'field', :locals => {:f => b, :name => "#{name}s", :title => title, :field => field}
    end 
    
    content << content_tag(:div, :class => 'controls') do
      link_to_add_fields "Adicionar #{title}", self, "#{name}s".to_sym, field, title.titleize
    end
    
    content + content_tag(:br)  
  end
  
  def submit(name = 'Salvar', *args)
    content_tag :div, :class => 'form-actions' do
      super(name, :class => 'btn btn-primary')
    end
  end
  
end

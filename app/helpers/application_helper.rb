module ApplicationHelper
  
  def present(object, klass = nil)
    klass ||= "#{object.class}Presenter".constantize
    presenter = klass.new(object, self)
    yield presenter if block_given?
    presenter
  end
  
  def link_to_remove_fields(name, f)  
    f.hidden_field(:_destroy) + link_to_function(name, "remove_fields(this)", :class => 'close')  
  end  
  
  def link_to_add_fields(name, f, association, field, title)  
    new_object = f.object.class.reflect_on_association(association).klass.new  
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|  
      render("field", :f => builder, :name => association, :field => field, :title => title)  
    end  
    link_to_function(name, "add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\", \"#{field}\")", :id => "add_#{association}")  
  end  
  
  def twitter_bootstrap_form_for(object, options = {}, &block)
    options[:builder] = TwitterBootstrapFormBuilder
    form_for(object, options, &block)
  end
  
  def twitter_bootstrap_tag(name, title)
    content_tag(:div, :class => 'control-group') do
      label_tag(name, title) +
      content_tag(:div, :class => 'controls') do
        yield
      end
    end
  end
  
  %w(text_field text_area number_field password_field).each do |method|
    define_method("twitter_bootstrap_#{method}_tag") do |name, title, params, *args, &block|
      twitter_bootstrap_tag(name, title) do
        send("#{method}_tag", name, params[name], :class => method)
      end
    end
  end
  
  def twitter_bootstrap_check_box_tag(name, title, *args, &block)
    twitter_bootstrap_tag(name, title) do
      check_box_tag name
    end
  end
  
  def twitter_bootstrap_submit_tag(name = 'Salvar', *args)
    options = args.extract_options!
    div_class = 'form-actions'
    div_class += ' ' + options[:class] if options[:class] 
    content_tag :div, :class => div_class do
      submit_tag(name, :class => 'btn btn-primary', :name => nil, :id => options[:id])
    end
  end
  
  def twitter_bootstrap_select(name, title, content, *args)
    twitter_bootstrap_tag(name, title) do
      select name, '', content, {:include_blank => true}
    end
  end

  %w(btn btn_primary btn_danger btn_mini btn_mini_danger).each do |method|
    define_method(method) do |*args|
      options = args.extract_options!      
      
      return if options[:controller] # to prevent a wierd error
      
      parts = method.to_s.split('_')
      classes = ['btn'] 
      classes += options[:class].split if options[:class]
      classes << 'btn-mini' if parts.include?('mini')
      classes << 'btn-primary' if parts.include?('primary')
      
      if parts.include?('danger')
        classes << 'btn-danger'
        options[:method] ||= :delete
        options[:confirm] ||= 'Tem certeza?'
      end
      
      options[:class] = classes.join(' ')
      link_to(args[0], args[1], options)
    end
  end

end

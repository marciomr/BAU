module CustomMatcher
  
  RSpec::Matchers.define "have_flash_notice".to_sym do |expected| 
    match do |actual| 
      if expected
        actual.find(:css, ".alert-success").should have_content(expected)
      else
        actual.find(:css, ".alert-success").should be_present          
      end
    end 
  end
  
  RSpec::Matchers.define "have_flash_alert".to_sym do |expected| 
    match do |actual| 
      if expected
        actual.find(:css, ".alert-error").should have_content(expected)
      else
        actual.find(:css, ".alert-error").should be_present          
      end
    end 
  end
  
  RSpec::Matchers.define :have_link_to do |expected|
    match do |actual| 
      actual.find(:css, "a[href^=\"#{expected}\"]").should be_present
    end 
  end
  
  RSpec::Matchers.define :have_img do |expected|
    match do |actual| 
      actual.find(:css, "img[src^=\"#{expected}\"]").should be_present
    end 
  end
end



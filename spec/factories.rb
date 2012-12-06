FactoryGirl.define do

  factory :user do |f|
    f.sequence(:id) { |n| n + 1 }
    f.sequence(:name) { |n| "Foo Bar #{n}" }
    f.username { |u| u.name.parameterize.underscore } 
    f.password "secret"
    f.password_confirmation { |u| u.password }
    f.description "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."

    factory :admin do |f|
      f.id 1
      f.name 'Admin'
    end
  end  

  factory :book do |f|
    f.sequence(:title) { |n| "Titulo #{n}" }
    f.subtitle "Subtitulo"
    f.volume 1
    f.language "pt"
    f.page_number 100
    f.cdd "234DFG23"
    f.imglink "http://bibliotecaterralivre.org"
    f.editor "Editor"
    f.city "Rio de Janeiro"
    f.country "Brasil"
    f.year 2010
    f.subject "Assunto"
    f.pdflink "http://www.example.com"
    f.collection "Ay Carmela"
    f.description "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
    user
  end

  factory :author do |f|
    f.name "Kropotkin"
  end

  factory :tag do |f|
    f.title "Tag"
  end
  
end


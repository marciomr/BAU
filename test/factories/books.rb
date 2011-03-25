Factory.define :book do |f|
  f.sequence(:tombo) { |n| n }
  f.sequence(:title) { |n| "Titulo #{n}" }
  f.authors {|authors| [authors.association(:author)]}
  f.tags {|tags| [tags.association(:tag)]}
  
  f.sequence(:editor) { |n| "Editor #{n}" }
  f.city "Rio de Janeiro"
  f.country "Brasil"
  f.year 2010
  f.subject "Assunto"
  f.collection "Ay Carmela"
  f.description "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
end

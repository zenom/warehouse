YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb', 'app/**/*.rb'] 
  t.options += ['--title', "Warehouse Documentation"]
  #t.after = lambda { `cp -R docs/images/ doc/images/` }	
end

#  t.files   = ['lib/**/*.rb', 'app/**/*.rb', '-', 'TestDoc.md', 'Routes.md'] 
#t.files   = ['lib/**/*.rb', 'app/**/*.rb'] 
#  t.options = ['--title Rails'] 
#t.options = ['--file TestDoc.md,Routes.md']
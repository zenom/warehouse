# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)
#100.times { Fabricate(:content, :state => :complete) }
Fabricate(:user, :email => "andy@zenjavi.com", :password => "andy12")
Fabricate(:folder, :folder => "/Photo", :media => "DVD")
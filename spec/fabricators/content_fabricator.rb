require 'digest/sha1'
Fabricator :content do
  found_date          { Fabricate.sequence(:date) {|i| Chronic.parse("#{i.to_s} days ago")}}
  destination_folder  { "Video_#{Faker::Name.first_name}_#{Faker::Name.last_name}_#{Time.now.to_i}"}
  state               { [:failed, :complete, :processing, :pending].sample }
  cadre_title         { Faker::Company.catch_phrase }
  directory_hash      { Digest::SHA1.hexdigest Time.now.to_s }
  folder!             { Fabricate(:folder) }
end
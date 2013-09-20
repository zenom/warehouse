Fabricator :folder do
  folder    { Fabricate.sequence(:path) { |i| "/folder_#{i}" } }
  media     { Settings::MEDIA_TYPES.sample }
  title     { Faker::Company.catch_phrase}
  content_type { Settings::CONTENT_TYPES.sample}
end
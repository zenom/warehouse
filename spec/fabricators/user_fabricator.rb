Fabricator :user do
  first_name    { Faker::Name.first_name }
  last_name     { Faker::Name.last_name }
  email         { Faker::Internet.email }
  role          { "admin" }
  active        { true }
  password      { |user| user.password = newpass(10) }
end

def newpass( len )
  chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
  newpass = ""
  1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
  return newpass
end
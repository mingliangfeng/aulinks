# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user_link do
    Category "MyString"
    url "MyString"
    ip "MyString"
    location "MyString"
    is_friend 1
  end
end

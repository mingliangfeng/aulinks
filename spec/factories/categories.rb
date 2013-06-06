# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :category do
    hid 1
    name "MyString"
    is_top 1
  end
end

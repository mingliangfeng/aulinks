# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :category_link do
    category_id 1
    link_id 1
    recommend 1
    show_order 1
  end
end

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :link_relation do
    parent_id 1
    sub_id 1
    show_order 1
  end
end

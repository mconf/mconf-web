# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :ldap_token do
    user_id 1
    identifier "MyString"
    data "MyText"
  end
end

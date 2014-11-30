# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :mail_address do
    attention 'Monfresh'
    street_1 '1 davis dr'
    city 'Belmont'
    state_province 'CA'
    postal_code '90210'
    country_code 'US'
    association :location, factory: :no_address
  end

  factory :mail_address_with_extra_whitespace, class: MailAddress do
    attention '   Moncef '
    street_1 '8875     La Honda Road'
    city 'La Honda  '
    state_province ' CA '
    postal_code ' 94020'
    country_code ' US '
  end
end

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :location do
    name { 'VRS Services' }
    description { 'Provides jobs training' }
    kind { :other }
    short_desc { 'short description' }
    accessibility { %i[tape_braille disabled_parking] }
    latitude { 37.583939 }
    longitude { -122.3715745 }
    organization
    address

    factory :location_with_admin do
      admin_emails { ['Moncef@smcgov.org'] }
      association :organization, factory: :nearby_org
    end

    factory :location_for_org_admin do
      name { 'Samaritan House' }
      website { 'http://samaritanhouse.com' }
      association :organization, factory: :far_org
    end

    factory :loc_with_extra_whitespace do
      description { ' Provides job training' }
      name { 'VRS   Services ' }
      short_desc { 'Provides job training. ' }
      transportation { ' BART stop 1 block away.' }
      website { ' http://samaritanhouse.com  ' }
      admin_emails { [' foo@bar.com  ', 'foo@bar.com'] }
      email { ' bar@foo.com  ' }
      languages { [' English', 'Vietnamese '] }
    end

    factory :virtual_with_address do
      virtual { true }
    end
  end

  factory :nearby_loc, class: Location do
    name { 'Library' }
    description { 'great books about jobs' }
    kind { :human_services }
    importance { 2 }
    short_desc { 'short description' }
    accessibility { [:elevator] }
    latitude { 37.5808591 }
    longitude { -122.343072 }
    association :address, factory: :near
    languages { %w[Spanish Arabic] }
    association :organization, factory: :nearby_org
  end

  factory :no_address, class: Location do
    name { 'No Address' }
    description { 'no coordinates' }
    kind { :other }
    short_desc { 'short description' }
    virtual { true }
    association :organization, factory: :no_address_org
  end

  factory :farmers_market_loc, class: Location do
    name { 'Belmont Farmers Market' }
    description { 'yummy food about jobs' }
    market_match { true }
    payments { %w[Credit WIC SFMNP SNAP] }
    products { %w[Cheese Flowers Eggs Seafood Herbs] }
    kind { :farmers_markets }
    importance { 3 }
    short_desc { 'short description' }
    latitude { 37.3180168 }
    longitude { -122.2743951 }
    languages { %w[French Tagalog] }
    association :address, factory: :far_west
    association :organization, factory: :hsa
  end

  factory :far_loc, class: Location do
    name { 'Belmont Farmers Market' }
    description { 'yummy food' }
    kind { :other }
    short_desc { 'short description' }
    latitude { 37.6047797 }
    longitude { -122.3984501 }
    association :address, factory: :far
    languages { %w[Spanish Arabic] }
    association :organization, factory: :far_org
  end

  factory :loc_with_nil_fields, class: Location do
    name { 'Belmont Farmers Market with cat' }
    description { 'yummy food and flute performers' }
    kind { :farmers_markets }
    short_desc { 'short description' }
    address
    latitude { 37.568272 }
    longitude { -122.3250474 }
    association :organization, factory: :no_address_org
  end

  factory :soup_kitchen, class: Location do
    name { 'Soup Kitchen' }
    description { 'daily hot soups' }
    kind { :human_services }
    short_desc { 'short description' }
    latitude { 37.3180168 }
    longitude { -122.2743951 }
    association :address, factory: :far_west
    association :organization, factory: :food_pantry
  end
end

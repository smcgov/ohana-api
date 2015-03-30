class Location < ActiveRecord::Base
  attr_accessible :accessibility, :active, :admin_emails, :alternate_name,
                  :description, :email, :hours, :importance, :kind,
                  :languages, :latitude, :longitude, :market_match, :name,
                  :payments, :products, :short_desc, :transportation, :website,
                  :virtual, :address_attributes, :mail_address_attributes,
                  :phones_attributes, :regular_schedules_attributes,
                  :holiday_schedules_attributes

  belongs_to :organization

  has_one :address, dependent: :destroy
  accepts_nested_attributes_for :address, allow_destroy: true

  has_many :contacts, dependent: :destroy

  has_one :mail_address, dependent: :destroy
  accepts_nested_attributes_for :mail_address, allow_destroy: true

  has_many :phones, dependent: :destroy
  accepts_nested_attributes_for :phones,
                                allow_destroy: true, reject_if: :all_blank

  has_many :services, dependent: :destroy

  has_many :regular_schedules, dependent: :destroy
  accepts_nested_attributes_for :regular_schedules,
                                allow_destroy: true, reject_if: :all_blank

  has_many :holiday_schedules, dependent: :destroy
  accepts_nested_attributes_for :holiday_schedules,
                                allow_destroy: true, reject_if: :all_blank

  validates :address,
            presence: {
              message: I18n.t('errors.messages.no_address')
            },
            unless: ->(location) { location.virtual? }

  validates :kind, :organization, :name,
            presence: { message: I18n.t('errors.messages.blank_for_location') }

  validates :description,
            presence: { message: I18n.t('errors.messages.blank_for_location') },
            unless: proc { |loc| loc.kind == 'farmers_markets' }

  ## Currently, the short description field is limited to 200 characters.
  ## Change the value below to increase or decrease the limit.
  # validates :short_desc, length: { maximum: 200 }

  validates :website, url: true, allow_blank: true

  validates :languages, pg_array: true

  validates :admin_emails, array: { email: true }

  validates :email, email: true, allow_blank: true

  after_validation :geocode, if: :needs_geocoding?

  geocoded_by :full_physical_address

  extend Enumerize
  serialize :accessibility, Array
  # Don't change the terms here! You can change their display
  # name in config/locales/en.yml
  enumerize :accessibility,
            in: [:cd, :deaf_interpreter, :disabled_parking, :elevator, :ramp,
                 :restroom, :tape_braille, :tty, :wheelchair, :wheelchair_van],
            multiple: true

  # Don't change the terms here! You can change their display
  # name in config/locales/en.yml
  enumerize :kind,
            in: [:arts, :clinics, :education, :entertainment, :farmers_markets,
                 :government, :human_services, :libraries, :museums, :other,
                 :parks, :sports]

  # List of admin emails that should have access to edit a location's info.
  # Admin emails can be added to a location via the Admin interface.
  serialize :admin_emails, Array

  serialize :ask_for, Array
  serialize :products, Array
  serialize :payments, Array

  auto_strip_attributes :description, :email, :name, :short_desc,
                        :transportation, :website

  auto_strip_attributes :admin_emails, reject_blank: true, nullify: false

  extend FriendlyId
  friendly_id :slug_candidates, use: [:history]

  # Try building a slug based on the following fields in
  # increasing order of specificity.
  def slug_candidates
    [
      :name,
      [:name, :address_street],
      [:name, :mail_address_city]
    ]
  end

  def address_street
    address.address_1 if address.present?
  end

  def mail_address_city
    mail_address.city if mail_address.present?
  end

  def full_physical_address
    return unless address.present?
    "#{address.address_1}, #{address.city}, #{address.state_province} #{address.postal_code}"
  end

  def needs_geocoding?
    return false if address.blank? || new_record_with_coordinates?
    address.changed?
  end

  def new_record_with_coordinates?
    new_record? && latitude.present? && longitude.present?
  end

  # See app/models/concerns/search.rb
  include Search
end

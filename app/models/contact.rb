class Contact < ActiveRecord::Base
  attr_accessible :email, :extension, :fax, :name, :phone, :title

  belongs_to :location, touch: true

  validates :name, :title, presence: { message: "can't be blank for Contact" }
  validates :email, email: true, allow_blank: true
  validates :phone, phone: true, allow_blank: true
  validates :fax, fax: true, allow_blank: true

  auto_strip_attributes :email, :extension, :fax, :name, :phone, :title, squish: true
end

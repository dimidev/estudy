class Building
  include Mongoid::Document
  include Mongoid::Datatable

  after_initialize :defaults

  field :name,    type: String
  field :area,    type: Integer, default: 0
  field :floors,  type: Integer, default: 0

  validates_presence_of :name, :area, :floors
  validates_numericality_of :area, :floors, only_integer: true, greater_or_equal_to: 0

  embeds_one :address,    autobuild: true
  has_many :halls,        dependent: :destroy
  belongs_to :institution

  accepts_nested_attributes_for :address, reject_if: :all_blank

  private
  def defaults
    self.institution ||= Institution.first
  end
end

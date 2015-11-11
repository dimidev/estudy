class Student < User
  #before_create :auto_increment
  after_initialize :defaults

  field :semester,  type: Integer, default: 1
  field :stc,       type: Integer # Student Code
  field :status
  enumerize :status, in: [:active, :not_active, :postpoment, :graduate], default: :active

  validates_associated :department, :studies_programme
  validates_presence_of :semester, :status
  validates_numericality_of :semester, only_integer: true, greater_than_or_equal_to: 1

  validates_associated :studies_programme
  has_many :registrations
  belongs_to :studies_programme
  belongs_to :department

  scope :active, lambda{ where(active: true) }

  private
  def defaults
    self.role= :student
  end

  def auto_increment
    if self.new_record?
    end
  end
end

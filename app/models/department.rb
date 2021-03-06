class Department
  include Mongoid::Document
  include Mongoid::Paperclip
  include Mongoid::Datatable
  extend Enumerize
  extend ActiveModel::Naming

  after_initialize :defaults

  attr_accessor :delete_img
  before_validation {department_logo.clear if delete_img == '1' }

  field :title,               type: String
  field :foundation_date,     type: Integer
  field :status
  enumerize :status, in: {active: true, not_active: false}, default: :active
  field :head_of_department,  type: String

  index({title: 1},{unique: true, background: true})

  has_mongoid_attached_file :department_logo, styles:{medium:'300x300>',thumb:'60x60>'},
                            url:"/system/:attachment/:style/:id.:extension",
                            path:":rails_root/public/system/:attachment/:style/:id.:extension",
                            default_url: 'institution.png'

  validates_attachment :department_logo, content_type: {content_type: /\Aimage\/.*\Z/}, size: {less_than: 2.megabytes}
  validates_associated :institution
  validates_uniqueness_of :title
  validates_presence_of :title, :foundation_date, :head_of_department
  validates_numericality_of :foundation_date, only_integer: true

  embeds_one :address,      autobuild: true
  embeds_many :contacts
  belongs_to :institution
  has_many :admins,           dependent: :destroy
  has_many :professors,       dependent: :destroy
  has_many :students,         dependent: :destroy
  has_many :studies_programs, dependent: :destroy
  has_many :timetables,       dependent: :destroy
  has_many :notices,          dependent: :destroy
  has_many :course_classes,   dependent: :destroy
  has_many :exams,            dependent: :destroy

  accepts_nested_attributes_for :address, :contacts, reject_if: :all_blank, allow_destroy: true

  scope :active, lambda { where(status: true) }

  def active?
    self.status == 'active'
  end

  def courses_for_class
    studies_programs = self.studies_programs.pluck(:id)
    parent_courses = Course.where(:studies_program_id.in => studies_programs).pluck(:id)
    child_courses = Course.where(:parent_course_id.in => parent_courses)

    Course.or([:studies_program_id.in => studies_programs, :id.nin => child_courses.pluck(:parent_course_id).uniq], [:id.in=> child_courses.pluck(:id)])
  end

  private
  def defaults
    self.institution = Institution.first
  end
end
class Course
  include Mongoid::Document
  include Mongoid::Datatable
  extend Enumerize
  extend ActiveModel::Naming

  COURSE_TYPE = %w(compulsory specification selection_required foreign_language)
  COURSE_PART = %w(theory lab)

  field :title,             type: String
  enumerize :course_type, in: COURSE_TYPE
  enumerize :course_part, in: COURSE_PART
  field :semester,          type: String
  field :ects,              type: Integer
  field :hours,             type: Integer, default: 0
  field :percent,           type: Integer
  field :attendances_limit, type: Integer

  validates_presence_of :title, :hours
  validates :ects, presence: true, numericality: {integer_only: true, greater_than_equal_to: 0}, unless: lambda{ |obj| obj.has_parent_course? }
  validates :percent, presence: true, numericality: {integer_only: true, greater_than_equal_to: 0, less_than_or_equal_to: 100}, if: lambda{ |obj| obj.has_parent_course? }
  validates :attendances_limit, presence: true, numericality: {integer_only: true, greater_than_equal_to: 0, less_than_or_equal_to: 100}, if: lambda{ |obj| obj.course_part == 'lab' }

  belongs_to  :studies_programme
  has_many    :registrations
  has_many    :course_classes, dependent: :destroy
  has_many    :courses, as: :parent_course, dependent: :destroy
  belongs_to  :parent_course, polymorphic: true
  belongs_to  :department

  accepts_nested_attributes_for :courses, reject_if: :all_blank, allow_destroy: true
end

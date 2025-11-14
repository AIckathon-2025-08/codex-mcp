class Task < ActiveRecord::Base
  # Associations
  belongs_to :user
  has_many :subtasks, dependent: :destroy

  # Validations
  validates :title, presence: true
  validates :status, inclusion: { in: %w[planning active completed] }

  # Callbacks
  before_validation :set_defaults, on: :create

  # Scopes
  scope :planning, -> { where(status: 'planning') }
  scope :active, -> { where(status: 'active') }
  scope :completed, -> { where(status: 'completed') }

  # Methods
  def progress
    return "0/0" if subtasks.empty?
    completed = subtasks.where(status: 'completed').count
    total = subtasks.count
    "#{completed}/#{total}"
  end

  def completion_percentage
    return 0 if subtasks.empty?
    (subtasks.where(status: 'completed').count.to_f / subtasks.count * 100).round
  end

  def all_objectives_complete?
    subtasks.any? && subtasks.where(status: 'pending').count == 0
  end

  def activate!
    update(status: 'active')
  end

  def complete!
    update(status: 'completed')
  end

  private

  def set_defaults
    self.status ||= 'planning'
  end
end

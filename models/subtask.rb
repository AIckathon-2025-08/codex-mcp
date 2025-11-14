class Subtask < ActiveRecord::Base
  # Associations
  belongs_to :task

  # Validations
  validates :title, presence: true
  validates :status, inclusion: { in: %w[pending completed] }
  validates :position, presence: true, numericality: { greater_than: 0 }

  # Callbacks
  before_validation :set_defaults, on: :create
  before_validation :set_position, on: :create

  # Scopes
  scope :pending, -> { where(status: 'pending') }
  scope :completed, -> { where(status: 'completed') }
  scope :ordered, -> { order(:position) }

  # Methods
  def complete!
    update(status: 'completed')
  end

  def completed?
    status == 'completed'
  end

  private

  def set_defaults
    self.status ||= 'pending'
  end

  def set_position
    if position.nil?
      max_position = task.subtasks.maximum(:position) || 0
      self.position = max_position + 1
    end
  end
end

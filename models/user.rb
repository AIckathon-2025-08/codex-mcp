class User < ActiveRecord::Base
  # Associations
  has_many :tasks, dependent: :destroy

  # Validations
  validates :username, presence: true, uniqueness: true
  validates :xp, numericality: { greater_than_or_equal_to: 0 }
  validates :level, numericality: { greater_than_or_equal_to: 1 }

  # Callbacks
  before_validation :set_defaults, on: :create

  # Class Methods
  def self.default_user
    # Get or create the single default user
    @default_user ||= find_or_create_by(username: 'default') do |user|
      user.xp = 0
      user.level = 1
    end
  end

  # Methods
  def award_xp(amount)
    self.xp += amount
    check_level_up
    save
  end

  def active_tasks
    tasks.where(status: 'active')
  end

  def completed_tasks
    tasks.where(status: 'completed')
  end

  def stats
    {
      username: username,
      level: level,
      xp: xp,
      xp_to_next_level: xp_required_for_next_level,
      total_quests: tasks.count,
      completed_quests: completed_tasks.count,
      active_quests: active_tasks.count
    }
  end

  private

  def set_defaults
    self.xp ||= 0
    self.level ||= 1
  end

  def check_level_up
    required_xp = xp_required_for_level(level + 1)
    if xp >= required_xp
      self.level += 1
      check_level_up # Recursive in case they earned enough for multiple levels
    end
  end

  def xp_required_for_level(target_level)
    # Simple formula: level 2 = 100 XP, level 3 = 250 XP, level 4 = 450 XP
    # Formula: (target_level - 1) * 100 + (target_level - 1) * (target_level - 2) * 25
    base = (target_level - 1) * 100
    bonus = (target_level - 1) * (target_level - 2) * 25
    base + bonus
  end

  def xp_required_for_next_level
    xp_required_for_level(level + 1) - xp
  end
end

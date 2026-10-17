class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  extend ActiveHash::Associations::ActiveRecordExtensions
  belongs_to :role

  has_one :cart, dependent: :destroy
  has_many :orders, dependent: :restrict_with_error

  PASSWORD_REGEX = /\A(?=.*?[a-z])(?=.*?\d)[a-z\d]+\z/i

  validates :last_name, :first_name, presence: true
  validates :role_id, inclusion: { in: [Role::CUSTOMER_ID, Role::ADMIN_ID] }
  validates :password, format: { with: PASSWORD_REGEX, message: "には英字と数字の両方を含めてください" }, if: -> { password.present? }

  before_validation :assign_customer_role, on: :create
  after_create :create_default_cart

  def admin?
    role_id == Role::ADMIN_ID
  end

  private

  def assign_customer_role
    self.role_id ||= Role::CUSTOMER_ID
  end

  def create_default_cart
    create_cart!
  end
end

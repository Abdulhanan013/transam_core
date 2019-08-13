class Message < ActiveRecord::Base

  # Include the object key mixin
  include TransamObjectKey

  #------------------------------------------------------------------------------
  # Callbacks
  #------------------------------------------------------------------------------
  after_initialize  :set_defaults
  after_create      :send_email

  # Associations
  belongs_to :organization
  belongs_to :user, -> { unscope(where: :active) }
  belongs_to :to_user, -> { unscope(where: :active) }, :class_name => 'User', :foreign_key => "to_user_id"
  belongs_to :priority_type
  belongs_to :message_template
  has_many   :responses, :class_name => "Message", :foreign_key => "thread_message_id"

  # Has been tagged by the user
  has_many    :message_tags
  has_many    :users, :through => :message_tags

  # Validations on core attributes
  validates :organization_id,   :presence => true
  validates :user,              :presence => true
  validates :to_user,           :presence => true
  validates :priority_type_id,  :presence => true
  validates :subject,           :presence => true
  validates :body,              :presence => true

  default_scope { where(active: true).order('created_at DESC') }

  # List of allowable form param hash keys
  FORM_PARAMS = [
    :organization_id,
    :user_id,
    :to_user_id,
    :thread_message_id,
    :priority_type_id,
    :subject,
    :body
  ]

  EMAIL_STATUS_DEFAULT = "Stopped"
  EMAIL_STATUS_SENT = "Sent"

  def self.allowable_params
    FORM_PARAMS
  end

  # Returns true if the user has tagged this order
  def tagged? user
    users.include? user
  end

  # Tags this message for the user
  def tag user
    unless tagged? user
      users << user
    end
  end

  # Recursively determine how many total responses there are to this thread
  def response_count
    sum = 0
    responses.each do |r|
      sum += 1
      sum += r.response_count
    end
    return sum
  end

  # Set resonable defaults for a new message
  def set_defaults
    self.email_status ||= EMAIL_STATUS_DEFAULT
    self.active = self.active.nil? ? true : self.active
  end

  def email_enabled?
    to_user.notify_via_email && (!message_template || (message_template.active && message_template.email_enabled))
  end

  # If the to_user has elected to receive emails, send them upon message creation
  def send_email
    if email_enabled?
      Delayed::Job.enqueue SendMessageAsEmailJob.new(object_key), :priority => 0
    end
  end

  # def to_user
  #   User.unscope(where: :active).find_by(id: to_user_id)
  # end

  def as_json(options={})
    {
      object_key: object_key,
      subject: subject,
      active: active,
      created_at: created_at,
      email_status: email_status,
      user: user&.to_s,
      name: message_template&.name,
      description: message_template&.description,
      email_enabled: message_template&.email_enabled
    }
  end

end

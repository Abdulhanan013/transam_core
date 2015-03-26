# During a rehabilitation update, subsystems can be selected and associated
# with a cost
class AssetEventSubsystem < ActiveRecord::Base
 #-----------------------------------------------------------------------------
  # Callbacks
  #-----------------------------------------------------------------------------
  after_initialize  :set_defaults

  #-----------------------------------------------------------------------------
  # Associations
  #-----------------------------------------------------------------------------
  # Every sign_order_sign belongs to a sign
  belongs_to  :rehabilitation_update_event, :class_name => 'RehabilitationUpdateEvent', :foreign_key => "asset_event_id", :inverse_of => :asset_event_subsystems

  # Every asset_event_subsystem belongs to a subsystem
  belongs_to  :subsystem

  #-----------------------------------------------------------------------------
  # Scopes
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Validations
  #-----------------------------------------------------------------------------
  validates     :subsystem,                   :presence => :true
  validates     :rehabilitation_update_event, :presence => :true
  validates     :parts_cost,                  :numericality => {:only_integer => :true, :greater_than => 0}, allow_nil: true
  validates     :labor_cost,                  :numericality => {:only_integer => :true, :greater_than => 0}, allow_nil: true
  
  #-----------------------------------------------------------------------------
  # Constants
  #-----------------------------------------------------------------------------

  # List of allowable form param hash keys
  FORM_PARAMS = [
    :id,
    :subsystem,
    :rehabilitation_update_event,
    :parts_cost,
    :labor_cost
  ]

  #-----------------------------------------------------------------------------
  #
  # Class Methods
  #
  #-----------------------------------------------------------------------------

  def self.allowable_params
    FORM_PARAMS
  end

  #-----------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #-----------------------------------------------------------------------------
  def cost
    parts_cost.to_i + labor_cost.to_i
  end
  #-----------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #-----------------------------------------------------------------------------
  protected

  # Set resonable defaults for a new instance
  def set_defaults
  end
end

#------------------------------------------------------------------------------
#
# Policy
#
#------------------------------------------------------------------------------
class Policy < ActiveRecord::Base
  
  # Enable auditing of this model type
  has_paper_trail
  
  # Include the unique key mixin
  include UniqueKey

  #------------------------------------------------------------------------------
  # Overrides
  #------------------------------------------------------------------------------
  
  #require rails to use the asset key as the restful parameter. All URLS will be of the form
  # /policy/{object_key}/...
  def to_param
    object_key
  end
  
  #------------------------------------------------------------------------------
  # Callbacks
  #------------------------------------------------------------------------------
  after_initialize :set_defaults
  
  # Always generate a unique object key before saving to the database
  before_validation(:on => :create) do
    generate_unique_key(:object_key)
  end
  
  #------------------------------------------------------------------------------
  # Associations
  #------------------------------------------------------------------------------
  # Every policy belongs to an organization
  belongs_to  :organization

  # Has a single method for calculating costs
  belongs_to  :cost_calculation_type

  # Has a single method for calculating asset depreciation
  belongs_to  :depreciation_calculation_type
  
  # Has a single method for calculating service life
  belongs_to  :service_life_calculation_type
  
  # Has a single method for estimating condition
  belongs_to  :condition_estimation_type
  
  # Has 0 or more policy items
  has_many    :policy_items

  #------------------------------------------------------------------------------
  # Validations
  #------------------------------------------------------------------------------
  validates  :object_key,                       :presence => true, :uniqueness => true
  validates :organization_id,                   :presence => true
  validates :service_life_calculation_type_id,  :presence => true
  validates :cost_calculation_type_id,          :presence => true
  validates :depreciation_calculation_type_id,  :presence => true
  validates :condition_estimation_type_id,      :presence => true

  validates :year,                              :presence => true
  validates :name,                              :presence => true
  validates :description,                       :presence => true
  validates_numericality_of :interest_rate,     :greater_than_or_equal_to => 0.0, :less_than_or_equal_to => 100.0
  validates_numericality_of :condition_threshold,:greater_than_or_equal_to => 0.0, :less_than_or_equal_to => 5.0

  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------
  
  # default scope
  default_scope { where(:active => true) }

  # set named scopes 
  scope :current, -> { where(:current => true) }

  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :object_key,
    :organization_id,
    :service_life_calculation_type_id, 
    :cost_calculation_type_id, 
    :condition_estimation_type_id, 
    :depreciation_calculation_type_id,
    :year,
    :name,
    :description,
    :interest_rate,
    :condition_threshold,
    :current,
    :active    
  ]
  
  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------
    
  def self.allowable_params
    FORM_PARAMS
  end
  
  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected 

  # Set resonable defaults for a new policy
  def set_defaults
    self.year ||= Date.today.year
    self.interest_rate ||= 0.025
    self.condition_threshold ||= 2.5 
    self.active ||= true
  end    
      
end

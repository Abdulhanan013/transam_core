class AttachmentType < ActiveRecord::Base

  #attr_accessible :name, :description, :active
        
  # default scope
  default_scope { where(:active => true) }
  
end


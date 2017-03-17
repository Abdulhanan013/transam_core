#------------------------------------------------------------------------------
#
# AssetRehabilitationUpdateJob
#
# Updates an assets rehabilitation ststus
#
#------------------------------------------------------------------------------
class AssetRehabilitationUpdateJob < AbstractAssetUpdateJob

  def requires_sogr_update?
    true
  end

  def execute_job(asset)
    asset.update_rehabilitation
  end

  def prepare
    Rails.logger.debug "Executing AssetRehabilitationUpdateJob at #{Time.now.to_s} for Asset #{object_key}"
  end

end

### Load asset query configurations
puts "======= Loading core asset query configurations ======="

# transam_assets table
QueryAssetClass.find_or_create_by(table_name: 'transam_assets')

# Query Category and fields
transam_assets_category_fields = {
  'Identification & Classification': [
    {
      name: 'organization_id',
      label: 'Organization',
      filter_type: 'multi_select',
      auto_show: true,
      association: {
        table_name: 'organizations',
        display_field_name: 'short_name'
      }
    },
    {
      name: 'asset_tag',
      label: 'Asset ID / Segment ID',
      filter_type: 'text'
    },
    {
      name: 'external_id',
      label: 'External ID',
      filter_type: 'text'
    },
    {
      name: 'asset_subtype_id',
      label: 'Subtype',
      filter_type: 'multi_select',
      association: {
        table_name: 'asset_subtypes',
        display_field_name: 'name'
      }
    },
    {
      name: 'description',
      label: 'Description / Segment Name',
      filter_type: 'text'
    }
  ],

  'Characteristics': [
    {
      name: 'manufacturer_id',
      label: 'Manufacturer',
      filter_type: 'text',
      pairs_with: 'other_manufacturer',
      association: {
        table_name: 'manufacturers',
        display_field_name: 'name'
      }
    },
    {
      name: 'other_manufacturer',
      label: 'Manufacturer (Other)',
      filter_type: 'text',
      hidden: true
    },
    {
      name: 'manufacturer_model_id',
      label: 'Model',
      filter_type: 'text',
      pairs_with: 'other_manufacturer_model',
      association: {
        table_name: 'manufacturer_models',
        display_field_name: 'name'
      }
    },
    {
      name: 'other_manufacturer_model',
      label: 'Model (Other)',
      filter_type: 'text',
      hidden: true
    },
    {
      name: 'manufacture_year',
      label: 'Year of Construction / Year of Manufacture',
      filter_type: 'numeric'
    },
    {
      name: 'quantity',
      label: 'Quantity',
      filter_type: 'numeric',
      pairs_with: 'quantity_unit'
    },
    {
      name: 'quantity_unit',
      label: 'Quantity Units',
      filter_type: 'text'
    }
  ],

  'Funding': [
    {
      name: 'purchase_cost',
      label: 'Cost (Purchase)',
      filter_type: 'numeric'
    }
  ],

  'Procurement & Purchase': [
    {
      name: 'purchase_date',
      label: 'Purchase Date',
      filter_type: 'date'
    },
    {
      name: 'purchased_new',
      label: 'Purchased New',
      filter_type: 'boolean'
    },
    {
      name: 'vendor_id',
      label: 'Vendor',
      filter_type: 'text',
      pairs_with: 'other_vendor',
      association: {
        table_name: 'organizations',
        display_field_name: 'short_name'
      }
    },
    {
      name: 'other_vendor',
      label: 'Vendor (Other)',
      filter_type: 'text',
      hidden: true
    }
  ],

  'Operations': [
    {
      name: 'in_service_date',
      label: 'In Service Date',
      filter_type: 'date'
    }
  ],

  'Life Cycle (Replacement Status)': [
    {
      name: 'replacement_status_type_id',
      label: 'Replacement Status',
      filter_type: 'multi_select',
      association: {
        table_name: 'replacement_status_types',
        display_field_name: 'name'
      }
    }
  ],

  'Life Cycle (Depreciation)': [
    {
      name: 'depreciable',
      label: 'Asset is Depreciable?',
      filter_type: 'boolean'
    },
    {
      name: 'depreciation_start_date',
      label: 'Depreciation Start Date',
      filter_type: 'date'
    }
  ],

  'Life Cycle (Disposition & Transfer)': [
    {
      name: 'disposition_date',
      label: 'Date of Disposition',
      filter_type: 'date'
    }
  ]
}

# seeding
fields_data = {
  'transam_assets': transam_assets_category_fields
}

fields_data.each do |table_name, category_fields|
  query_asset_table = QueryAssetClass.find_by_table_name table_name
  category_fields.each do |category_name, fields|
    qc = QueryCategory.find_or_create_by(name: category_name)
    fields.each do |field|
      if field[:association]
        qac = QueryAssociationClass.find_or_create_by(field[:association])
      end
      qf = QueryField.find_or_create_by(
        name: field[:name], 
        label: field[:label], 
        query_category: qc, 
        query_association_class_id: qac.try(:id),
        filter_type: field[:filter_type],
        auto_show: field[:auto_show],
        hidden: field[:hidden],
        pairs_with: field[:pairs_with]
      )
      qf.query_asset_classes << query_asset_table
    end
  end
end


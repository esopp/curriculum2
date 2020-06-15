class Dimension < BaseRec

  # dim_type field valid options
  BIG_IDEA = 'bigidea'
  MISCONCEPTION = 'miscon'
  ESSENTIAL_QUESTION = 'essq'
  QUESTION = 'question'
  CONCEPT = 'concept'
  COMPETENCY = 'comp'
  STANDARD = 'standard'
  VAL_DIM_TYPES = [BIG_IDEA, MISCONCEPTION, ESSENTIAL_QUESTION]
  # Do not change existing sequence of
  # RESOURCES_TYPES.
  # Only add new resource types to end.
  RESOURCE_TYPES = [
    'second_subj',
    'correct_understanding',
    'poss_source_miscon',
    'compiler',
    'citation',
    'link',
    'distractor',
    'question_bank',
    'third_subj',
  ]

  validate :valid_dim_type

  has_many :dim_trees
  has_many :trees, through: :dim_trees

  scope :active, -> { where(:active => true) }

  # Translation Field
  def get_dim_name_key
    ret = dim_name_key ? dim_name_key : "dimension.#{id}.name"
    return ret
  end

  def get_dim_desc_key
    ret = dim_desc_key ? dim_desc_key : "dimension.#{id}.desc"
    return ret
  end

  def get_dim_resource_key
    return "dimension.#{id}.resource"
  end

  def self.get_dim_type_key(dimCode, tree_type, version)
    return "curriculum.#{tree_type}.#{version}.#{dimCode}"
  end

  def self.get_dim_type_name(dimCode, treeTypeCode, versionCode, localeCode)
    dimCodeKey =  Dimension.get_dim_type_key(dimCode, treeTypeCode, versionCode)
    return Translation.find_translation_name(localeCode, dimCodeKey, nil) ||
      I18n.t("nav_bar.#{dimCode.split("_").join("")}.name")
  end

  # To Do: fill this in
  def self.createOrUpdateDimensionRecord()
  end



  ###############################################

  # function parse_filters
  # interpret dimension filters from param
  # e.g.: filters = "subj_miscon_sci,gb_miscon_21,subj_bigidea_ear,..."
  # @param filters {String}
  # @param valid_dims {Array<String>}
  #
  # @returns hash in the form:
    # {
    #   "bigidea" : {
    #     :subj => "sci",
    #     :gb => {
    #       min_grade: 0,
    #       max_grade: 12,
    #       id: 5 #(optional)
    #     }
    #   },
    #   "miscon" : {...},
    #   ...
    # }
  def self.parse_filters(filters, valid_dims)
    ret = Hash.new { |hash, key| hash[key] = {} }
    filters.split(",").each do |f|
      info = f.split("_")
      if valid_dims.include?(info[1])
        if info[0] == "subj"
          if BaseRec::BASE_SUBJECTS.include?(info[2]) #|| BaseRec::BASE_PRACTICES.include?(info[2])
            ret[info[1]][:subj] = info[2]
          end #BaseRec::BASE_SUBJECTS.include(info[3])
        elsif info[0] == "gb"
          begin
            gb = GradeBand.find(info[2])
            ret[info[1]][:gb] = {
              min_grade: gb.min_grade,
              max_grade: gb.max_grade,
              code: gb.code
            }
          rescue
            ret[info[1]][:gb] = {
              min_grade: GradeBand::MIN_GRADE,
              max_grade: GradeBand::MAX_GRADE,
              code: 'All'
            }
          end
        end #if info[0]
      end #if info[1]
    end #filters.split(",").each do
    return ret
  end

  def self.get_resource_key(
    resourceType,
    treeTypeCode,
    versionCode
  )
    return "curriculum.#{treeTypeCode}.#{versionCode}.dim.#{resourceType}"
  end

  def self.get_resource_name(
    resourceType,
    treeTypeCode,
    versionCode,
    localeCode,
    default
  )
    return Translation.find_translation_name(
      localeCode,
      "curriculum.#{treeTypeCode}.#{versionCode}.dim.#{resourceType}",
      default
    )
  end

  def resource_key(resourceType)
    return "dimension.#{id}.#{resourceType}"
  end

  def resource_name(
    localeCode,
    resourceType,
    default
  )
    key = resource_key(resourceType)
    return Translation.find_translation_name(
      localeCode,
      key,
      default
    )
  end

  private

  def valid_dim_type
    VAL_DIM_TYPES.include?(dim_type)
  end

end

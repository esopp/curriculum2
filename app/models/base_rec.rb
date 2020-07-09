class BaseRec < ActiveRecord::Base
  self.abstract_class = true

  # Only used in uploads
  SAVE_CODE_STATUS = ['', 'Code Added', 'Code Updated', 'Code Error']
  REC_NO_CHANGE = 0
  REC_ADDED = 1
  REC_UPDATED = 2
  REC_ERROR = 3

  # only used in uploads and testing
  UPLOAD_STATUS = ['-', 'Upload Started', 'Uploaded', 'Upload Done']
  UPLOAD_PROGRESS_PCT = [0, 33, 67, 100]
  UPLOAD_NOT_UPLOADED = 0
  UPLOAD_TREE_UPLOADING = 1
  UPLOAD_TREE_UPLOADED = 2
  UPLOAD_DONE = 3

  #To Do - check this
  # hard coded variables - must match record 1 in database tables - see db/seeds.rb
  # only used by factorybot. see test/factories/factories.rb
  TREE_TYPE_ID = 1
  TREE_TYPE_CODE = 'TFV'
  VERSION_ID = 1
  VERSION_CODE = 'v01'


  LOCALE_BS = 'bs'
  LOCALE_HR = 'hr'
  LOCALE_SR = 'sr'
  LOCALE_EN = 'en'
  LOCALE_TR = 'tr'
  LOCALE_AR_EG = 'ar_EG'
  LOCALE_TR_TR = 'tr_TR'
  VALID_LOCALES = [LOCALE_TR, LOCALE_EN, LOCALE_AR_EG]
  DEFAULT_LOCALE = LOCALE_EN
  BASE_SUBJECTS = [
    'bio', #Biology
    'cap', #Capstones
    'che', #Chemistry
    'edu', #Education
    'engl', #English
    'eng', #Engineering
    'mat', #Math
    'mec', #Mechanics
    'phy', #Physics
    'sci', #Science
    'ear', #Earth Science
    'geo', #Geology
    'tech', #Technology
    'adv', #advisory
    'ara', #Arabic
    'art', #Art
    'soc', #Social Science
  ]
  SUBJECT_COLORS = [
    '#E5FFDE',
    '#009FFD',
    '#FCAF58',
    '#DBCBD8',
    '#DBCBD8',
    '#564787',
    '#564787',
    '#F26DF9',
    '#F5EE9E',
    '#A2E8DD',
    '#A85751',
    '#2CA58D',
    '#9DC5BB',
    '#414535',
    '#EDD2E0',
    '#6F9CEB',
    '#D1F58C',
  ]

  # BASE_PRACTICES = [
  #   'stem', #Science And Engineering Practices
  #   'spec', #Specific Practices
  # ]

  # only used in uploads
  UPLOAD_RPT_COL = ['Row', 'Unit', 'Chapter', 'Outcome', 'Indicator', 'Code','Desc','StatusMsg']

  # ALL_SECTORS = ['1','2','3','4','5','6','7','8','9','10']

  #name of the log file where runtime issues with data are logged
  DATA_COMPLAINTS_PATH = "#{Rails.root}/log/data_complaints.out"

  DIM_CHANGE_LOG_PATH = "#{Rails.root}/log/dimension_changes.out"

  #To Do: add comment
  # When/why
  # generic
  # what happens when returned
  def self.process_resource_content(resource_type, resource_name, content_text)
    convert_id_to_google_folder_url = [
      'depth_0_materials',
      'depth_1_materials',
      'depth_2_materials',
      'lp_folder'
    ]
    convert_id_to_google_ss_url = [
      'lp_ss_id'
    ]
    ret = content_text
    if convert_id_to_google_folder_url.include?(resource_type)
      ret = "<a href='https://drive.google.com/drive/folders/#{content_text}' target='_blank'>#{resource_name}</a>"
    elsif convert_id_to_google_ss_url.include?(resource_type)
      ret = "<a href='https://docs.google.com/spreadsheets/d/#{content_text}' target='_blank'>#{resource_name.singularize}</a>"
    end
    return ret
  end

  def self.subject_color(subject_code)
    return SUBJECT_COLORS[BASE_SUBJECTS.index(subject_code)]
  end

end

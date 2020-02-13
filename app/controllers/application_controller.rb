class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :initTypeCode
  before_action :getLocaleCode
  before_action :getSubjectCode
  before_action :getGradeBandCode
  before_action :set_type_and_version
  before_action :config_devise_params, if: :devise_controller?

  include ApplicationHelper

  # put locale in url
  # - see: http://guides.rubyonrails.org/i18n.html#setting-the-locale-from-url-params
  # - see config/routes.rb locale scope, placing the locale after domain name and before rest of path (not in query string)
  # - now *_path and *_url now place locale in url
  def default_url_options
    { locale: I18n.locale }
  end

  def int_or_zero_from_s(strIn)
    begin
      ret = Integer(strIn)
    rescue ArgumentError, TypeError
      ret = 0
    end
  end

  protected

    # set the current Subject ID
    def setSubjectCode(code)
      Rails.logger.debug("app setSubjectCode code: #{code.inspect}")
      if Subject.all.map{ |s| s.code}.include?(code)
        # next default Subject to cookie:
        Rails.logger.debug("app Subject code matched! #{code.inspect}")
        @subject_code = code
        cookies['subject'] = code
      else
        Rails.logger.debug("app Subject code not matched! #{code} - #{@subject_code.inspect}")
      end
      Rails.logger.debug "@subject_code: #{@subject_code.inspect}"
    end

    # set the current gradeBand ID
    def setGradeBandCode(code)
      Rails.logger.debug("app setGradeBand code: #{code.inspect}")
      if GradeBand.all.map{ |gb| gb.code}.include?(code)
        # next default gradeBand to cookie:
        Rails.logger.debug("app gradeBand code matched! #{code.inspect}")
        cookies['gradeBand'] = code
      else
        Rails.logger.debug("app gradeBand code not matched! #{code}")
      end
    end

  private

    # set the Subject code
    def getSubjectCode
      subp = params['subject'].to_s
      subc = cookies['subject'].to_s
      @subject_code = ''
      validSubjects = []
      Subject.all.each do |s|
        validSubjects << s.code
      end
      if validSubjects.include?(subp)
        # first set Subject to the Subject passed as the Subject param
        Rails.logger.debug("app param set subject code: param: #{subp} cookie: #{subc}")
        @subject_code = subp
      elsif validSubjects.include?(subc)
        # next default Subject to cookie:
        Rails.logger.debug("app cookie set subject code: param: #{subp} cookie: #{subc}")
        @subject_code = subc
      else
        Rails.logger.debug("app no set subject code: param: #{subp} cookie: #{subc}")
      end
      Rails.logger.debug "app @subject_code: #{@subject_code.inspect}"
      cookies[:subject] = @subject_code
      Rails.logger.debug "app cookies[:subject]: #{cookies[:subject].inspect}"
    end

    # set the GradeBand code
    def getGradeBandCode
      gbp = params['gradeBand'].to_s
      gbc = cookies['gradeBand'].to_s
      @grade_band_code = ''
      validGradeBands = GradeBand.pluck(:code)
      if validGradeBands.include?(gbp)
        # first set gradeBand to the gradeBand passed as the gradeBand param
        Rails.logger.debug("app param set GradeBand code: param: #{gbp} cookie: #{gbc}")
        @grade_band_code = gbp
      elsif validGradeBands.include?(gbc)
        # next default gradeBand to cookie:
        Rails.logger.debug("app cookie set GradeBand code: param: #{gbp} cookie: #{gbc}")
        @grade_band_code = gbc
      else
        Rails.logger.debug("app no set subject code: param: #{gbp} cookie: #{gbc}")
      end
      Rails.logger.debug "app @grade_band_code: #{@grade_band_code.inspect}"
      cookies[:gradeBand] = @grade_band_code
      Rails.logger.debug "app cookies[:gradeBand]: #{cookies[:gradeBand].inspect}"
    end

    # set the locale code
    def getLocaleCode
      locp = params['locale'].to_s
      locc = cookies['locale'].to_s
      if (
        locp.present? &&
        BaseRec::VALID_LOCALES.include?(locp)
      )
        # first set locale to the locale passed as the locale param
        @locale_code = locp
      elsif (
        locc.present? &&
        BaseRec::VALID_LOCALES.include?(locc)
      )
        # next default locale to cookie:
        @locale_code = locc
      else
        # next set it to default locale
        @locale_code = Rails.application.config.i18n.default_locale
        # # next set locale to the locale in user record
        # @locale_code = current_user.try(:locale) || @locale_code
      end
      # set the locale in I18n
      Rails.logger.debug "@locale_code: #{@locale_code.inspect}"
      I18n.locale = @locale_code
      cookies[:locale] = @locale_code
    end

    def set_type_and_version
      # assumes only one version record
      @versionsHash = TreeType.versions_hash
      if current_user.present?
        version_id = current_user[:last_version_id] || cookies.permanent.signed[:last_version_id]
        @versionRec = version_id ? Version.where(:id => version_id).first : Version.first
        puts "SET VERISON TO #{@versionRec.inspect} with: current_user.present? condition"
      elsif cookies.permanent.signed[:last_version_id]
        @versionRec = Version.where(:id => cookies.permanent.signed[:last_version_id]).first
      elsif @treeTypeRec
        @versionRec = (@treeTypeRec[:working_version_id] != 0) ? Version.where(:id => @treeTypeRec[:working_version_id]).first : Version.first
      else
        @versionRec = Version.first
      end
      if @versionRec.blank?
        raise I18n.translate('app.errors.missing_version_record')
      elsif @versionRec.code != BaseRec::VERSION_CODE
        raise I18n.translate('app.errors.missing_version_code')
      end
    end

    def initTypeCode
      # defaults to first tree type record
      if current_user.present?
        puts "SETTING INIT TYPE CODE WITH USER PRESENT #{current_user.inspect}"
        last_tree_type = TreeType.where(:id => current_user[:last_tree_type_id])
        @treeTypeRec = last_tree_type.count > 0 ? last_tree_type.first : TreeType.first
      elsif cookies.permanent.signed[:last_tree_type_id]
        @treeTypeRec = TreeType.where(:id => cookies.permanent.signed[:last_tree_type_id]).first || TreeType.first
      else
        @treeTypeRec = TreeType.first
      end
      if @treeTypeRec
        Rails.logger.debug("*** @treeTypeRec.curriculum_title_key: #{@treeTypeRec.curriculum_title_key}")
        @locale_codes = @treeTypeRec.valid_locales.split(',')
        @locale_code = (@locale_codes.length >0) ? @locale_codes.first : BaseRec::LOCALE_EN
        Rails.logger.debug("*** @locale_code: #{@locale_code}")
        @locale = Locale.where(code: @locale_code)
        Rails.logger.debug("*** @locale: #{@locale.inspect}")
        # To Do - create new translate method to return value with a default value of some kind
        @appTitle = Translation.find_translation_name(
          @locale_code,
          @treeTypeRec.curriculum_title_key,
          Translation.where(key: 'app.title', locale: @locale_code)
        )
        @sectorName = Translation.find_translation_name(@locale_code, @treeTypeRec.sector_set_name_key, '')
        @hierarchies = []
        @treeTypeRec.hierarchy_codes.split(',').each do |c|
          @hierarchies << Translation.find_translation_name(@locale_code, "curriculum.#{@treeTypeRec.code}.hierarchy.#{c}", '')
          Rails.logger.debug("*** @hierarchy: #{Translation.find_translation_name(@locale_code, "curriculum.#{@treeTypeRec.code}.hierarchy.#{c}", '')}")
        end
        Rails.logger.debug("*** @hierarchies: #{@hierarchies.inspect}")
        @misconCode = @treeTypeRec.miscon_dim_type
        @misconTitle = Translation.find_translation_name(@locale_code, @misconCode, 'Misconceptions')
        @bigIdeasCode = @treeTypeRec.big_ideas_dim_type
        @bigIdeasTitle = Translation.find_translation_name(@locale_code, @bigIdeasCode, 'Big Ideas')
        @dimTypeTitleByCode = {
          @misconCode => @misconTitle,
          @bigIdeasCode => @bigIdeasTitle
        }
        # To Do - is this needed anywhere else?
        @subjectByCode = {}
        @subjectById = {}
        subjects = Subject.where(tree_type_id: @treeTypeRec.id)
        subjects.each do |subj|
          h = {
            rec: subj,
            abbr: Translation.find_translation_name(@locale_code, "subject.#{@treeTypeRec.code}.#{subj.code}.abbr", ''),
            name: Translation.find_translation_name(@locale_code, "subject.#{@treeTypeRec.code}.#{subj.code}.name", ''),
          }
          @subjectByCode[subj.code] = h
          @subjectById[subj.id] = h
        end
      else
        # To Do - fill in defaults here?
        @appTitle = Translation.where(key: 'app.title', locale: @locale_code)
      end

      # Rails.logger.debug("*** application controller.set_type_and_version - @treeTypeRec: #{@treeTypeRec.inspect}")
      # Rails.logger.debug("*** current_user: #{@current_user.inspect}")
      # if @treeTypeRec.blank?
      #   raise I18n.translate('app.errors.missing_tree_type_record')
      # elsif @treeTypeRec.code != BaseRec::TREE_TYPE_CODE
      #   raise I18n.translate('app.errors.missing_tree_type_code')
      # end
    end

    def config_devise_params
      devise_parameter_sanitizer.permit(:sign_up, keys: [
        :given_name,
        :family_name,
        :govt_level,
        :govt_level_name,
        :municipality,
        :institute_type,
        :institute_name_loc,
        :position_type,
        :subject1,
        :subject2,
        :gender,
        :education_level,
        :work_phone,
        :work_address,
        :terms_accepted
      ])
    end

end

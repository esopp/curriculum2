# seed_turkey.rake
namespace :seed_turkey_v02b do

  task populate: [:update_tree_type]

  ###################################################################################
  desc "update the Curriculum Tree Type and Version"
  task update_tree_type: :environment do

    # reference version record from seeds.rb
    myVersion = Version.where(:code => 'v02')
    if myVersion.count > 0
      @v02 = myVersion.first
    else
      raise 'missing version 2 record'
    end

    # get the Tree Type record for the Curriculum
    throw "Invalid Tree Type Count" if TreeType.where(code: 'tfv').count != 2
    myTreeTypes = TreeType.where(code: 'tfv', version_id: @v02.id)
    if myTreeTypes.count < 1
      raise 'Missing Tree Type record for tfv v02'
    end
    @tfv = myTreeTypes.first

    @loc_en = Locale.where(code: 'en').first

    ###################################################################################
    # create upload records for .csv format uploads for V02
    Upload.delete_all

    # # Adding grade band 99 for the all gradeband for uploads
    # # set as deactivated, to prevent it from showing up in dropdowns
    # # To Do: consider using Grade Band 99 for All in dropdowns.
    # if GradeBand.where(tree_type_id: @tfv.id, code: '99').count < 1
    #   GradeBand.create(
    #     tree_type_id: @tfv.id,
    #     code: '99',
    #     sort_order: '99',
    #     active: false
    #   )
    # end

    # @gb_99 = GradeBand.where(tree_type_id: @tfv.id, code: '99').first

    # using nil gradeband id for all grades

    # create the technology subject:
    if Subject.where(tree_type_id: @tfv.id, code: 'tech').count < 1
      tech = Subject.create(
        tree_type_id: @tfv.id,
        code: 'tech',
        base_key: 'subject.tfv.tech',
        min_grade: 0,
        max_grade: 12
      )
    end
    Translation.find_or_update_translation(@loc_en.code, 'subject.tfv.tech.name', 'Tech Engineering')
    Translation.find_or_update_translation(@loc_en.code, 'subject.tfv.tech.abbr', 'tech')
    Translation.find_or_update_translation(@loc_en.code, 'subject.base.tech.name', 'Tech Engineering')
    Translation.find_or_update_translation(@loc_en.code, 'subject.base.tech.abbr', 'tech')

    @subjects = []
    @bio = Subject.where(tree_type_id: @tfv.id, code: 'bio').first
    @bio.min_grade = 9
    @bio.max_grade = 12
    @bio.save
    @che = Subject.where(tree_type_id: @tfv.id, code: 'che').first
    @mat = Subject.where(tree_type_id: @tfv.id, code: 'mat').first
    @sci = Subject.where(tree_type_id: @tfv.id, code: 'sci').first
    @phy = Subject.where(tree_type_id: @tfv.id, code: 'phy').first
    @ear = Subject.where(tree_type_id: @tfv.id, code: 'ear').first
    @tech = Subject.where(tree_type_id: @tfv.id, code: 'tech').first
    @subjects = [@bio, @che, @mat, @sci, @phy, @ear, @tech]

    @loc_tr = Locale.where(code: 'tr').first
    @loc_en = Locale.where(code: 'en').first

    @subjects.each do |s|
      if Upload.where(tree_type_code: 'tfv',
        subject_id: s.id,
        grade_band_id: nil,
        locale_id: @loc_en.id
      ).count < 1
        Upload.create!(
          tree_type_code: 'tfv',
          subject_id: s.id,
          grade_band_id: nil,
          locale_id: @loc_en.id,
          status: 0,
          filename: "tfvV02#{s.code.capitalize}AllEng.csv"
        )
      end
      if Upload.where(tree_type_code: 'tfv',
          subject_id: s.id,
          grade_band_id: nil,
          locale_id: @loc_tr.id
        ).count < 1
        Upload.create!(
          tree_type_code: 'tfv',
          subject_id: s.id,
          grade_band_id: nil,
          locale_id: @loc_tr.id,
          status: 0,
          filename: "tfvV02#{s.code.capitalize}AllTur.csv"
        )
      end
    end

  end #update_tree_type


end

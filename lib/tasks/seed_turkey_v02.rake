# seed_turkey_v02.rake
namespace :seed_turkey_v02 do

  task populate: [:setup, :create_tree_type, :load_locales, :create_admin_user, :create_grade_bands, :create_subjects, :dimension_translations, :outcome_translations, :create_uploads, :create_sectors]

  task setup: :environment do
    @versionNum = 'v02'
    @curriculumCode = 'tfv'
    @sectorCode = 'future'
  end

  ###################################################################################
  desc "create the Curriculum Tree Type and Version - Is Rerunnable!"
  task create_tree_type: :environment do

    # reference version record from seeds.rb
    myVersion = Version.where(:code => @versionNum)
    if myVersion.count > 0
      @ver = myVersion.first
    else
      @ver = Version.new
      @ver.code = @versionNum
      @ver.save
      @ver.reload
    end

    # create Tree Type record for the Curriculum
    myTreeTypes = TreeType.where(code: @curriculumCode, version_id: @ver.id)
    myTreeTypeValues = {
      code: @curriculumCode,
      hierarchy_codes: 'grade,unit,subunit,comp',
      valid_locales: BaseRec::LOCALE_EN+','+BaseRec::LOCALE_TR,
      sector_set_code: 'future,hide',
      sector_set_name_key: 'sector.set.future.name',
      curriculum_title_key: 'curriculum.tfv.title', # 'Mektebim STEM Curriculum'
      outcome_depth: 3,
      version_id: @ver.id,
      working_status: true,
      dim_codes: 'essq,bigidea,pract,miscon',
      tree_code_format: 'subject,grade,unit,subunit,comp',
      # To Do: Write documentation on obtaining translation keys
      # - for dimension translation use dim.get_dim_resource_key
      #
      # Detail headers notation key:
      # NOTE: Please avoid underscores (_) and commas (,)
      #       in item names.
      #   item - HEADER item
      #   [item] - TABLE item, dimension.
      #   {resource#n} - TABLE item, outcome resource translation
      #   <item> - TABLE item, sector
      #   +item+ - TABLE item, treetree
      #   {item#n#...} - TABLE item collection, multiple outcome resource translations
      #   {resources#n#...} - TABLE item, full width of table,
      #                  with numeric codes identifying which
      #                  categories of this item to display.
      #                  e.g., may use indexes in the
      #                  Outcome::RESOURCE_TYPES array.
      #   tableItem_tableItem_... - up to 4 columns table items allowed in one row.
      detail_headers: 'grade,unit,subunit,comp,[bigidea]_[essq],[pract],{resource#6},[miscon#2#1],<sector>,+treetree+,{resources#0#1#2#3#4#5}',
      # Grid headers notation key:
      # item or (item) - Ignored for now
      # [item] - grid column, may have multiple connected items
      # {item} - grid column, single item
      grid_headers: 'grade,unit,subunit,comp,[essq],[bigidea],[pract],{explain},[miscon]',
      dim_display: 'miscon#0#8#1#2#3#4#5#6#7',
    }
    if myTreeTypes.count < 1
      TreeType.create(myTreeTypeValues)
    else
      TreeType.update(myTreeTypes.first.id, myTreeTypeValues)
    end
    treeTypes = TreeType.where(code: @curriculumCode, version_id: @ver.id)
    throw "ERROR: Missing tfv tree type" if treeTypes.count < 1
    @tt = treeTypes.first

    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'app.title', 'Mektebim STEM Curriculum App')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, 'app.title', 'Mektebim STEM Müfredat Uygulaması')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

    # Create translation(s) for hierarchy codes
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'curriculum.tfv.hierarchy.grade', 'Grade')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'curriculum.tfv.hierarchy.unit', 'Unit')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    STDOUT.puts 'Create translation record for essential questions as K-12 Big Ideas.'
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'curriculum.tfv.hierarchy.subunit', 'Sub-Unit')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    STDOUT.puts 'Create translation record for Sub-Unit.'
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'curriculum.tfv.hierarchy.comp', 'Competence')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

    #To Do - Enter translations for sector_set_name_key
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'sector.set.future.name', 'Future Sectors')
    throw "ERROR updating sector.set.fut.sect.name: #{message}" if status == BaseRec::REC_ERROR

    #To Do - Enter translations for curriculum_title_key
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'curriculum.tfv.title', 'Mektebim STEM Curriculum')
    throw "ERROR updating curriculum.tfv.title translation: #{message}" if status == BaseRec::REC_ERROR

    # # Titles of Turkish Dimension Pages (see seeds.rb for default english)
    # rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, 'trees.bigidea.title', "Büyük Fikirler")
    # throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    # rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, 'trees.miscon.title', "Yanlış")
    # throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

    puts "Curriculum (Tree Type) is created for tfv "
    puts "  Created Curriculum: #{@tt.code} with Hierarchy: #{@tt.hierarchy_codes}"
  end #create_tree_type


  ###################################################################################
  desc "load up the locales (created in seeds.rb seed file)"
  task load_locales: :environment do
    @loc_tr = Locale.where(code: 'tr').first
    @loc_en = Locale.where(code: 'en').first
    puts "Locales: #{@loc_en.code}: #{@loc_en.name}, #{@loc_tr.code}: #{@loc_tr.name}"
  end #load_locales


  ###################################################################################
  desc "create the admin user(s)"
  task create_admin_user: :environment do
    # create an initial admin user to get things going.
    # Note: the Curriculum to display by default is TFV tree type
    # to do - turn off admin flag for production.
    if User.where(email: 'admin@sample.com').count < 1
      User.create(
        email: 'admin@sample.com',
        password: 'password',
        password_confirmation: 'password',
        given_name: 'Admin of',
        family_name: 'Curriculum',
        roles: 'admin',
        govt_level: "1",
        govt_level_name: "govt_level_name",
        municipality: "municipality",
        institute_type: "1",
        institute_name_loc: "institute_name_loc",
        position_type: "1",
        subject1: "subject1",
        subject2: "subject2",
        gender: "2",
        education_level: "1",
        work_phone: "work_phone",
        work_address: "work_address",
        terms_accepted: true,
        confirmed_at: DateTime.now,
        last_tree_type_id: @tt
      )
    end
    @user = User.where(email: 'admin@sample.com').first
    puts "admin user is created for #{@curriculumCode} curriculum"

  end #create_admin_user


  ###################################################################################
  desc "create the grade bands for this tree type (curriculum)"
  task create_grade_bands: :environment do
    sort_counter = 0
    %w(k 1 2 3 4 5 6 7 8 9 10 11 12).each do |g|
      begin
        gf = (g == 'k') ? 0 : sort_counter
        if GradeBand.where(tree_type_id: @tt.id, code: g).count < 1
          GradeBand.create(
            tree_type_id: @tt.id,
            code: g,
            sort_order: gf
          )
        end
        sort_counter += 1
      rescue => ex
        puts("exception creating gradeband #{g}, error: #{ex}")
      end
    end
    @gb_k = GradeBand.where(tree_type_id: @tt.id, code: 'k').first
    @gb_1 = GradeBand.where(tree_type_id: @tt.id, code: '1').first
    @gb_2 = GradeBand.where(tree_type_id: @tt.id, code: '2').first
    @gb_3 = GradeBand.where(tree_type_id: @tt.id, code: '3').first
    @gb_4 = GradeBand.where(tree_type_id: @tt.id, code: '4').first
    @gb_5 = GradeBand.where(tree_type_id: @tt.id, code: '5').first
    @gb_6 = GradeBand.where(tree_type_id: @tt.id, code: '6').first
    @gb_7 = GradeBand.where(tree_type_id: @tt.id, code: '7').first
    @gb_8 = GradeBand.where(tree_type_id: @tt.id, code: '8').first
    @gb_9 = GradeBand.where(tree_type_id: @tt.id, code: '9').first
    @gb_10 = GradeBand.where(tree_type_id: @tt.id, code: '10').first
    @gb_11 = GradeBand.where(tree_type_id: @tt.id, code: '11').first
    @gb_12 = GradeBand.where(tree_type_id: @tt.id, code: '12').first
    @gb_others = [@gb_9, @gb_10, @gb_11, @gb_12]
    @gb_math = [@gb_1, @gb_2, @gb_3, @gb_4, @gb_5, @gb_6, @gb_7, @gb_8, @gb_9, @gb_10, @gb_11, @gb_12]
    @gb_sci = [@gb_3, @gb_4, @gb_5, @gb_6, @gb_7, @gb_8]
    puts "grade bands are created for tfv"
    # put in translations for Grade Names
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'grades.tfv.k.name', 'Kindergarten')
    throw "ERROR creating kindergarten translation: #{message}" if status == BaseRec::REC_ERROR
    [1..12].each do |g|
      rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, "grades.tfv.#{g}.name", "Grade #{g}")
      throw "ERROR creating grade #{g} translation: #{message}" if status == BaseRec::REC_ERROR
    end
  end #create_grade_bands


  ###################################################################################
  desc "create the subjects for this tree type (curriculum)"
  task create_subjects: :environment do
    # Set Subject Abbreviations:
    @subjectsHash = {
      bio: {abbr: 'bio', inCurric: true, engName: 'Biology', locAbbr: 'Biy', locName: 'Biyoloji'},
      cap: {abbr: 'cap', inCurric: false, engName: 'Capstones', locAbbr: '', locName: ''},
      che: {abbr: 'Chem', inCurric: true, engName: 'Chemistry', locAbbr: 'Kim', locName: 'Kimya'},
      edu: {abbr: 'edu', inCurric: false, engName: 'Education', locAbbr: '', locName: ''},
      engl: {abbr: 'engl', inCurric: false, engName: 'English', locAbbr: '', locName: ''},
      eng: {abbr: 'eng', inCurric: false, engName: 'Engineering', locAbbr: '', locName: ''},
      mat: {abbr: 'Math', inCurric: true, engName: 'Mathematics', locAbbr: 'Mat', locName: 'Matematik'},
      mec: {abbr: 'mec', inCurric: false, engName: 'Mechanics', locAbbr: '', locName: ''},
      phy: {abbr: 'phy', inCurric: true, engName: 'Physics', locAbbr: 'Fiz', locName: 'Fizik'},
      sci: {abbr: 'sci', inCurric: true, engName: 'Science', locAbbr: 'Bil', locName: 'Bilim'},
      ear: {abbr: 'Ear', inCurric: true, engName: 'Earth, Space, & Environmental Science', locAbbr: 'Dün', locName: 'Dünya, Uzay ve Çevre Bilimi'},
      geo: {abbr: 'geo', inCurric: false, engName: 'Geology', locAbbr: '', locName: ''},
      tech: {abbr: 'tech', inCurric: true, engName: 'Tech Engineering', locAbbr: '', locName: ''}
    }
    # @subjects = []

    @subjectsHash.each do |key, subjHash|


      # create the subject for this tree type
      # note: using default start and end grade
      # - need to be set: set_min_max_grades:run rake task after uploads are done
      puts "find subject tree_type_id: #{@tt.id}, code: #{key}"
      subjs = Subject.where(tree_type_id: @tt.id, code: key)
      if subjs.count < 1
        puts "Creating Subject for #{key}"
        subj = Subject.create(
          tree_type_id: @tt.id,
          code: key,
          base_key: "subject.#{@tt.code}.#{@ver.code}.#{subjHash[:abbr]}"
        )
      else
        subj = subjs.first
      end

      # create english translation for subject name
      rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, "subject.#{@tt.code}.#{@ver.code}.#{subjHash[:abbr]}.name", subjHash[:engName])
      throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

      # create english translation for subject abbreviation
      rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, "subject.#{@tt.code}.#{@ver.code}.#{subjHash[:abbr]}.abbr", subjHash[:abbr])
      throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

      if subjHash[:inCurric]

        if subjHash[:locName].present?
          # create locale's translation for subject name
          rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, "subject.#{@tt.code}.#{@ver.code}.#{subjHash[:abbr]}.name", subjHash[:locName])
          throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
        end

        if subjHash[:locAbbr].present?
          # create locale's translation for subject abbreviation
          rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, "subject.#{@tt.code}.#{@ver.code}.#{subjHash[:abbr]}.abbr", subjHash[:locAbbr])
          throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
        end

        if Upload.where(tree_type_code: @curriculumCode,
          subject_id: subj.id,
          grade_band_id: nil,
          locale_id: @loc_en.id
        ).count < 1
        puts "create Eng upload for subject: #{subj.id} #{subj.code}"
          Upload.create!(
            tree_type_code: @curriculumCode,
            subject_id: subj.id,
            grade_band_id: nil,
            locale_id: @loc_en.id,
            status: 0,
            filename: "#{@tt.code}#{@ver.code}#{subj.code.capitalize}AllEng.csv"
          )
        end
        if Upload.where(tree_type_code: @curriculumCode,
          subject_id: subj.id,
          grade_band_id: nil,
          locale_id: @loc_tr.id
        ).count < 1
          puts "create Tur upload for subject: #{subj.id} #{subj.code}"
          Upload.create!(
            tree_type_code: @curriculumCode,
            subject_id: subj.id,
            grade_band_id: nil,
            locale_id: @loc_tr.id,
            status: 0,
            filename: "#{@tt.code}#{@ver.code}#{subj.code.capitalize}AllTur.csv"
          )
        end
      end
    end

    ##################################################################
    BaseRec::BASE_SUBJECTS.each do |subjCode|
      puts "set up library subject for #{subjCode}"
      # Create the English name and abbreviation for the Subjects in the Library.
      rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, Subject.get_default_abbr_key(subjCode), @subjectsHash[subjCode.to_sym][:abbr])
        throw "ERROR updating subject translation: #{message}" if status == BaseRec::REC_ERROR
        rec, status, message =  Translation.find_or_update_translation(BaseRec::LOCALE_EN, Subject.get_default_name_key(subjCode), @subjectsHash[subjCode.to_sym][:engName])
        throw "ERROR updating subject translation: #{message}" if status == BaseRec::REC_ERROR

      # Create the Locale's name and abbreviation for the Subjects in the Library.
      rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, Subject.get_default_abbr_key(subjCode), @subjectsHash[subjCode.to_sym][:locAbbr])
        throw "ERROR updating subject translation: #{message}" if status == BaseRec::REC_ERROR
        rec, status, message =  Translation.find_or_update_translation(BaseRec::LOCALE_TR, Subject.get_default_name_key(subjCode), @subjectsHash[subjCode.to_sym][:locName])
        throw "ERROR updating subject translation: #{message}" if status == BaseRec::REC_ERROR
    end

  end #create_subjects

  ###################################################################################
  desc "create translations for dimension types"
  task dimension_translations: :environment do
    # essq,bigidea,pract,miscon
    dim_translations_arr = [
      ['essq', 'K-12 Big Idea', 'K-12 Büyük Fikir'],
      ['bigidea', 'Specific Big Idea', 'Belirli Büyük Fikir'],
      ['pract', 'Associated Practice', 'İlişkili Uygulama'],
      ['miscon', 'Misconception', 'Yanlış kanı'],
    ]

    dim_resource_types_arr = [
      ['Second Category', 'İkinci Kategori'],
      ['Correct Understanding', 'Doğru Anlama'],
      ['Possible Source of Misconception', 'Yanlış Anlaşmanın Olası Kaynağı'],
      ['Compiler/Source'],
      ['Primary Research Citation', 'Derleyici / Kaynak'],
      ['Website Link References', 'Web Sitesi Bağlantı Referansları'],
      ['Test Distractor Percent', 'Test Distraktör Yüzdesi'],
      ['Link to Question Item Bank', 'Soru Bağlantısı Bankası'],
      ['Third Category', 'Üçüncü Kategori'],
    ]
    dim_translations_arr.each do |dim|
      dim_name_key = Dimension.get_dim_type_key(
        dim[0],
        @tt.code,
        @ver.code
      )
      rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, dim_name_key, dim[1])
      throw "ERROR updating dimension code translation: #{message}" if status == BaseRec::REC_ERROR
      rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, dim_name_key, dim[2])
      throw "ERROR updating dimension code translation: #{message}" if status == BaseRec::REC_ERROR
    end
    dim_resource_types_arr.each_with_index do |resource, i|
      resource_name_key = Dimension.get_resource_key(
        Dimension::RESOURCE_TYPES[i],
        @tt.code,
        @ver.code
      )
      rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, resource_name_key, resource[0])
      throw "ERROR updating dimension code translation: #{message}" if status == BaseRec::REC_ERROR
      rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, resource_name_key, resource[1])
      throw "ERROR updating dimension code translation: #{message}" if status == BaseRec::REC_ERROR
    end
  end

  ###################################################################################
  desc "create translations for outcome resources"
  task outcome_translations: :environment do
    outc_resource_types_arr = [
      ["Multi, inter or trans disciplinary Grand Challenges based projects", "Çoklu, disiplinler arası veya disiplinler arası Grand Challenges tabanlı projeler"],
      ["Daily Lesson Plans", "Günlük Ders Planları"],
      ["Textbook and Resource Materials to Use in Class", "Sınıfta Kullanılacak Ders Kitabı ve Kaynak Materyaller"],
      ["Suggested Assessment Resources and Activities", "Önerilen Değerlendirme Kaynakları ve Faaliyetleri"],
      ["Additional Background and Resource Materials for the Teacher", "Öğretmen için Ek Arka Plan ve Kaynak Materyalleri"],
      ["Goal behaviour (What students will do, Practical learning targets)","Hedef davranışı (Öğrenciler ne yapacak, Pratik öğrenme hedefleri)"],
      ["Teacher Support", "Öğretmen Desteği"],
      ["Evidence of Learning", "Öğrenmenin Kanıtı"],
      ["Connections", "Bağlantılar"],
    ]

    outc_resource_types_arr.each_with_index do |resource, i|
      resource_name_key = Outcome.get_resource_key(
        Outcome::RESOURCE_TYPES[i],
        @tt.code,
        @ver.code
      )
      rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, resource_name_key, resource[0])
      throw "ERROR updating dimension code translation: #{message}" if status == BaseRec::REC_ERROR
      rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, resource_name_key, resource[1])
      throw "ERROR updating dimension code translation: #{message}" if status == BaseRec::REC_ERROR
    end
  end #create_uploads

  ###################################################################################
  desc "create the upload control files"
  task create_uploads: :environment do

  end #create_uploads

  ###################################################################################
  desc "create the sectors (e.g. Grand Challenges, Future Sectors, ...)"
  task create_sectors: :environment do
    # Populate the Sector table and its translations for all  languages

    # Set Subject Abbreviations:
    @sectorsHash = {
      '1': {code: '1', engName: 'Industry 4.0',locName: 'Endüstri 4.0'},
      '2': {code: '2', engName: 'Sensors and Imaging Technology', locName: 'Sensörler ve Görüntüleme Teknolojisi'},
      '3': {code: '3', engName: 'New Food Technologies', locName: 'Yeni Gıda Teknolojileri'},
      '4': {code: '4', engName: 'Biomedical Technology', locName: 'Biyomedikal Teknoloji'},
      '5': {code: '5', engName: 'Nanotechnology / Space Technology', locName: 'Nanoteknoloji / Uzay Teknolojisi'},
      '6': {code: '6', engName: 'Global Warming', locName: 'Küresel Isınma'},
      '7': {code: '7', engName: 'Internet of Objects / 5G', locName: 'Nesnelerin İnterneti / 5G'},
      '8': {code: '8', engName: 'Population Increase vs Resource Consumption', locName: 'Nüfus artışı karşı Kaynak Tüketimi'}
    }

    @sectorsHash.each do |key, sectHash|

      # create the sector
      puts "create the sector: #{@sectorCode}, #{sectHash[:code]}"
      sectors = Sector.where(sector_set_code: @sectorCode, code: sectHash[:code])
      if sectors.count < 1
        sector = Sector.create(
          sector_set_code: @sectorCode,
          code: sectHash[:code],
          name_key: "sector.#{@sectorCode}.#{sectHash[:code]}.name",
          base_key: "sector.#{@sectorCode}.#{sectHash[:code]}"
        )
      else
        sector = sectors.first
      end

      # create the English translation for the Sector Name
      rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, "sector.#{@sectorCode}.#{sectHash[:code]}.name", sectHash[:engName])
      throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

      # create the Locale's translation for the Sector Name
      rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, "sector.#{@sectorCode}.#{sectHash[:code]}.name", sectHash[:locName])
      throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

    end
    puts "Sector translations are created for sector set: #{@sectorCode}"
  end

end

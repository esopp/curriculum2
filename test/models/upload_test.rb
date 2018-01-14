require 'helpers/test_models_helper'
require 'helpers/seeds_testing_helper'

include SeedsTestingHelper

class TreeTest < ActiveSupport::TestCase

  setup do
    testing_db_seeds
  end

  test "upload missing status should fail" do
    up = Upload.new()
    up.subject_id = @hem.id
    up.grade_band_id = @gb_09.id
    up.locale_id = @loc_en.id
    up.status = nil
    refute up.valid?, 'missing upload status should not be valid'
  end

  test "upload missing locale should fail" do
    up = Upload.new()
    up.subject_id = @hem.id
    up.grade_band_id = @gb_09.id
    # up.locale_id = @loc_en.id
    up.status = BaseRec::UPLOAD_STATUS[BaseRec::UPLOAD_NOT_UPLOADED]
    refute up.valid?, 'missing upload locale should not be valid'
  end

  test "upload missing grade band should fail" do
    up = Upload.new()
    up.subject_id = @hem.id
    # up.grade_band_id = @gb_09.id
    up.locale_id = @loc_en.id
    up.status = BaseRec::UPLOAD_STATUS[BaseRec::UPLOAD_NOT_UPLOADED]
    refute up.valid?, 'missing upload grade band should not be valid'
  end

  test "upload missing subject should fail" do
    up = Upload.new()
    # up.subject_id = @hem.id
    up.grade_band_id = @gb_09.id
    up.locale_id = @loc_en.id
    up.status = BaseRec::UPLOAD_STATUS[BaseRec::UPLOAD_NOT_UPLOADED]
    refute up.valid?, 'missing upload subject should not be valid'
  end

  test "upload with all fields should pass" do
    up = Upload.new()
    up.subject_id = @hem.id
    up.grade_band_id = @gb_09.id
    up.locale_id = @loc_en.id
    up.status = BaseRec::UPLOAD_STATUS[BaseRec::UPLOAD_NOT_UPLOADED]
    assert up.valid?, 'upload with all fields should not be valid'
  end

end

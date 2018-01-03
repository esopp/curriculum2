require 'application_system_test_case'
require 'helpers/seeds_testing_helper'

class UploadsSystemTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  include SeedsTestingHelper

  setup do
    @one = create(:user)
    @one.confirm
    sign_in @one
    testing_db_seeds
  end

  test "upload from index page" do
    visit uploads_url

    # uploads index page
    assert_equal("/uploads", current_path)
    # to do - use translation when title is translated
    assert_equal 'Uploads Listing', page.title
    assert_equal 1, page.all('#uploadsTable tbody tr').count
    page.find("#uploadsTable tbody tr#id_#{@hem_09.id} a").click

    # uploads page, with status not uploaded
    assert_equal("/uploads/#{@hem_09.id}/start_upload", current_path)
    within('h4') do
      assert page.has_content?("Status: #{ApplicationRecord::UPLOAD_STATUS[ApplicationRecord::UPLOAD_STATUS_NOT_UPLOADED]}")
    end

    # do upload
    assert_equal(ApplicationRecord::UPLOAD_STATUS_NOT_UPLOADED, @hem_09.status)
    assert_equal(0, Tree.count)
    page.find('#upload_file').set(Rails.root.join('test/fixtures/files/Hem_09_transl_Eng.csv'))
    find('button').click
    assert_equal("/uploads/#{@hem_09.id}/do_upload", current_path)
    refute_equal(0, Tree.count)
    # confirm
    # 4 area records were added
    # 16 components (4 per area +(4*4 = 16)
    # 48 outcomes (avg. 3 per component)
    assert_equal(68, Tree.where(parent_id: nil).count)
    puts "@hem_09 status: #{@hem_09.status}"
    @hem_09.reload
    assert_equal(ApplicationRecord::UPLOAD_STATUS_TREE_UPLOADING, @hem_09.status)
    # confirm number of records returned is 4 (4 area records)
    rpt_rows = page.find_all('#uploadReport tbody tr .colStatusMsg')
    assert_equal rpt_rows.count, 68
    rpt_rows.each do |r|
      assert_equal r.text, 'Added'
    end


    # run it again, and should have the same report
    page.find('#upload_file').set(Rails.root.join('test/fixtures/files/Hem_09_transl_Eng.csv'))
    find('button').click
    assert_equal("/uploads/#{@hem_09.id}/do_upload", current_path)
    @hem_09.reload
    assert_equal(ApplicationRecord::UPLOAD_STATUS_TREE_UPLOADING, @hem_09.status)
    assert_equal 68, page.find_all('#uploadReport tbody tr').count

    check_curriculum_page_after_upload

  end

  def check_curriculum_page_after_upload
    visit trees_url
    # uploads index page
    assert_equal("/trees", current_path)
    page.find("form.new_tree input[type='submit']").click
    # uploads page, with status not uploaded
    assert_equal("/trees/index_listing", current_path)
    tree_nodes = page.all('#tree .node-tree')
    assert_equal 4, tree_nodes.count
    idas = []
    tree_nodes.each do |n|
      id = n['data-nodeid']
      idas << id
    end
    within('#tree') do
      idas.each do |id|
        page.find("li[data-nodeid='#{id}'] .glyphicon-plus").click
      end
    end
    puts "area ids: #{idas.inspect}"
    idcs = []
    tree_nodes = page.all('#tree .node-tree')
    puts "tree_nodes.count: #{tree_nodes.count}"
    tree_nodes.each do |o|
      idcs << o['data-nodeid']
    end
    puts "area & component ids: #{idcs.inspect}"

    within('#tree') do
      idcs.each do |id|
        icon = page.first("li[data-nodeid='#{id}'] .glyphicon-plus")
        icon.click if icon.present?
      end
    end
    tree_nodes = page.all('#tree .node-tree')
    # sleep 5
    # save_and_open_page
    assert_equal 68, tree_nodes.count
  end

end

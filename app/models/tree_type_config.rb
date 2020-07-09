# <!-- Supporting Resources Table -->
# <!--
#   Generic Table, can be used to build expandable header tables (set expandable to true), or tables as part of the main section of the detail page.
#     locals:
#       table: {
#         table_partial_name: str,
#         expandable : Boolean,
#         code: Integer,
#         depth: nil || Integer,
#         num_rows: Integer,
#         by_resource_code: {
#           resourceCode1 : {
#             label_transl_key: str,
#             content_array : [
#               {
#                 rec: rec,
#                 label_key: nil,
#                 transl_key: str,
#                 detail_href: nil || path
#                 edit: nil || { path, options: {} },
#                 delete: nil || { path, options: {} },
#               },
#               {...}
#             ],
#             add: nil || {path, options: {}},
#           }
#         }
#             - shuffle contents_array into left-to-right order while building data.
#             e.g., if col_nums = 3, we alternate content types (each type has its own column) in the content_array:
#             [{type1 item}, {type2 item}, {type3 item}, {type1 item}, {...}, ...]
#       }
# -->


# <!--
#   Generic Table, can be used to build expandable header tables (set expandable to true), or tables as part of the main section of the detail page.
#     locals:
#       table: {
#         expandable : Boolean,
#         code: Integer,
#         depth: nil || Integer,
#         num_rows: Integer,
#         headers_array: [{
#             parent_transl_key: nil || str,
#             transl_key: str,
#             add: nil || {path, options: {}},
#             class: Class # (for cancan)
#           }]
#         content_array: [
#             {
#               rec: rec,
#               label_key: nil,
#               transl_key: str,
#               detail_href: nil || path
#               edit: nil || { path, options: {} },
#               delete: nil || { path, options: {} },
#             },
#             {...}
#           ]
#             - shuffle contents_array into left-to-right order while building data.
#             e.g., if col_nums = 3, we alternate content types (each type has its own column) in the content_array:
#             [{type1 item}, {type2 item}, {type3 item}, {type1 item}, {...}, ...]
#       }
# -->


# <!--
#   Simple header Table, can be used to build expandable header tables (set expandable to true), or tables as part of the main section of the detail page.
#     local:
#       table: {
#         headers_array: [{  //should only have one entry for partial
#             transl_key: str,
#           }]
#         content_array: [ //should only have one entry for partial
#             {
#               rec: rec,
#               transl_key: str,
#               detail_href: nil || path
#               edit: nil || { path, options: {} },
#               delete: nil || { path, options: {} },
#             },
#             {...}
#           ]
#       }
# -->

# <!--
#   Generic Table, can be used to build expandable header tables (set expandable to true), or tables as part of the main section of the detail page.
#     locals:
#       table: {
#         tree: treeRec,
#         num_rows: Integer,
#         headers_array: [{
#             parent_transl_key: nil || str,
#             transl_key: str,
#             add: nil || {path, options: {}}, //only set for first header
#             class: Class # (for cancan)
#           }]
#         content_array: [ //should be sorted by subject_id of rec
#             {
#               rec: rec, #build this info, don't just pass a record
#               edit: nil || {
#                 path: edit_tree_path(@tree.id, tree: { edit_type: 'treetree', attr_id: r[:ttid]}),
#                 options: {:remote => true, :class => "fa-lg pull-right", 'data-toggle' =>  "modal", 'data-target' => '#modal_popup'},
#               },
#               delete: {
#                 path: tree_path(@tree.id, tree: { edit_type: 'treetree', attr_id: r[:ttid], active: false}, tree_tree: {active: false}),
#                 options: {:class => "fa-lg pull-right", 'data-confirm' => I18n.t('app.labels.confirm_deactivate', item: I18n.t("trees.labels.#{subj}") + ": " + r[:code]), method: :patch}
#               }
#             },
#             {...}
#           ]
#             - shuffle contents_array into left-to-right order while building data.
#             e.g., if col_nums = 3, we alternate content types (each type has its own column) in the content_array:
#             [{type1 item}, {type2 item}, {type3 item}, {type1 item}, {...}, ...]
#       }
# -->

class TreeTypeConfig < BaseRec
end
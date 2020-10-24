# module ReturnCrudObjectHelper

#     def return_edit_object(edit_data)
#         object = edit_data[:object]
#         association = edit_data[:association_data]
#         type = edit_data[:data_type]
#         case type
#         #edit NovelsデータをEditする場合
#         when "novel"
#             {
#                 novel_id: object.id,
#                 user_id: object.user_id,
#                 novel_title: object.novel_title,
#                 novel_description: object.novel_description,
#                 novel_content: object.novel_content,
#                 release: object.release,
#             }
#         #edit NovelSeriesデータをEditする場合
#         #! association = series_tags
#         when "series"
#             #Stag Seriesの持つタグを取得
#             @tags = generate_object_from_array(association, "Series_edit")
#             {
#                 series_id: object.id,
#                 user_id: object.user_id,
#                 series_title: object.series_title,
#                 series_description: object.series_description,
#                 release: object.release,
#                 series_tags: @tags
#             }
#         when "user"
#             #Utag Userの持つタグを取得
#             @tags = generate_object_from_array(association, "User_edit")
#             {
#                 user_id: object.id,
#                 nickname: object.nickname,
#                 profile: object.profile,
#                 user_tags: @tags,
#             }
#         end
#     end

# end
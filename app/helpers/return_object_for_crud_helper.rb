# module ReturnObjectForCrudHelper

#     #! Reactから送られてくるパラメータを基にデータをCreate・Save・Update、Editする
#     #! object = CRUDするオブジェクト
#     #! params = パラメータ
#     #! association_data = オブジェクトとアソシエーションされたデータ
#     #! data_type = どのモデルを扱うか
#     #! crud_type = どのCRUDなのか判別
#     def pass_object_to_crud(**crud_data)
#         if authorized?(crud_data, crud_data[:data_type])
#             crud_object(crud_data)
#         else
#             handle_unauthorized()
#         end
#     end

#     #! オブジェクトをCreate, Edit, Update, Destroyするそれぞれのメソッドへ渡す
#     def crud_object(crud_data)
#         case crud_data[:crud_type]
#         # Create・Save
#         when "create"
#             # create_and_save_object(object, association_data, data_type)
#             create_and_save_object(crud_data)
#         # Edit
#         when "edit"
#             edit_object_to_render(crud_data)
#         # Update
#         when "update"
#             update_object(object, params, association_data, data_type)
#         # Destroy
#         when "destroy"
#             destroy_object(object)
#         end
#     end

#     #Create オブジェクトをCreate・Save
#     def create_and_save_object(create_data)
#         type = create_data[:data_type]
#         association = create_data[:association_data]
#         #! ここでデータを生成する
#         new_object = create_data[:object].new(create_data[:params])
#         case type
#         #Novels ユーザーとの関連付けを行う
#         when "novel_for_create"
#             new_object.novel_series_id = association.id
#             new_object.author = association.author
#         #Comment Novelとの関連付け
#         when "comment"
#             new_object.novel_id = association.id
#         when "favorites"
#             if favorited_by?(association)
#                 return already_existing_favorites()
#             end
#         end
#         #validates 保存
#         if new_object.save
#             #auth ログイン
#             login! if type === "user"
#             #Stag NovelSeriesオブジェクトにNovelTagを登録
#             new_object.save_tag(association) if type === "series"
#             #! 保存されたオブジェクトを渡す
#             create_and_save_object_to_render(object: new_object, data_type: type)
#         #validates 保存失敗
#         else
#             failed_to_crud_object(new_object)
#         end
#     end

#     #Update オブジェクトをUpdate
#     def update_object(object, params, association_data, data_type)
#         #validates データを更新
#         if object.update(params)
#             case data_type
#             when "series"
#                 object.save_tag(association_data)
#                 update_object_to_render(object, "update_of_series" )
#             when "novel"
#                 update_object_to_render(object, "update_of_novels" )
#             when "user"
#                 object.save_user_tag(association_data)
#                 update_object_to_render(object, "User_update" )
#             end
#         #validates 更新失敗
#         else
#             # render_json この時点でJSONデータがレンダリングされる
#             failed_to_crud_object(object)
#         end
#     end

#     #Destroy オブジェクトをDestroy
#     def destroy_object(object)
#         #validates データを削除
#         if object.destroy
#             destroy_object_to_render()
#         #validates 削除失敗
#         else
#             # render_json この時点でJSONデータがレンダリングされる
#             failed_to_crud_object(object)
#         end
#     end

# end
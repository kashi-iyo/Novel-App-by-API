module ReturnJsonShowObject

    def show_object(object)
        {
            "status"=>200,
            "selection"=>nil,
            "object"=>{
                "user"=>{
                    "user_id"=>object[:id],
                    "nickname"=>object[:nickname],
                    "profile"=>object[:profile]
                    },
                "user_tags"=>object[:user_tags],
                "user_relationships"=>{
                    "followings_count"=>object[:followings_count],
                    "followers_count"=>object[:followers_count],
                    "following_status"=>object[:followings_status],
                },
                "user_series_count"=>object[:user_series_count],
                "user_series"=>object[:user_series],
                "user_favorites_series_count"=>object[:user_favorites_series_count],
                "user_favorites_series"=>object[:user_favorites_series]
            },
            "data_type"=>object[:data_type],
            "crud_type"=>"show"
        }

    end

end
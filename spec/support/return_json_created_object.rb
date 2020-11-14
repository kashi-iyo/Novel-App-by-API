module ReturnJsonCreatedObject

    def created_object(object)
        {
            "status"=>"created",
            "object"=>{
                "id"=> object[:id],
                "nickname"=> object[:nickname]
            },
            "successful"=>"正常に保存されました。",
            "data_type"=> object[:data_type],
            "crud_type"=>"create"
        }
    end

    def not_created_object(object)
    {
        "status"=> "unprocessable_entity",
        "errors"=> object[:errors]
    }
    end

end
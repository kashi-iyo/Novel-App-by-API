class UsersController < ApplicationController

    before_action :logged_in_user, only: [:edit, :update]
    before_action :set_user, only: [:show, :edit, :update]
    before_action :set_user_tags, only: [:update]

    #Read
    def index
        @users = User.all
        if @users
            render json: { users: @users }
        else
            render json: { status: 500, errors: ['ユーザーが存在しません'] }
        end
    end

    #Read
    def show
        read_object_to_render(@user, {}, "Users#show")
    end

    #Edit
    def edit
        #! 引数に渡されるデータに基づいて、Edit用のオブジェクトを取得する
        helpers.pass_object_to_crud(
            @user,              #object
            {},                 #params
            @user.user_tags,    #association_data
            "user",             #data_type
            "edit"              #crud_type
        )
    end

    #Update
    def update
        helpers.pass_object_to_crud(
            @user,                  #object
            update_user_params,     #params
            @user_tags,             #association_data
            "user",                 #data_type
            "update"                #crud_type
        )
    end

    #Create
    def create
        @user = User.new(user_params)
        helpers.crud_object(
            @user,      #object
            {},         #params
            {},         #association_data
            "user",     #data_type
            "create"    #crud_type
        )
    end

    private

        def user_params
            params.require(:user).permit(:nickname, :account_id, :email, :password, :password_confirmation)
        end

        def update_user_params
            params.require(:user).permit(:nickname, :profile)
        end

        #! NovelSeriesオブジェクト作成時に一緒に送られてくるNovelTagのデータを取得
        def set_user_tags
            @user_tags = params[:user][:user_tag_name].split(",") unless params[:user][:user_tag_name].nil?
        end

        def set_user
            if User.find(params[:id]).nil?
                return_not_present_data()
            else
                @user = User.find(params[:id])
            end
        end
end
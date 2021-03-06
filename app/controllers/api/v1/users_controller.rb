class Api::V1::UsersController < ApplicationController

    # logged_in_user()メソッド：authentication_features_concern.rb内に定義

    before_action :logged_in_user, only: [:edit, :update]
    before_action :set_user, only: [:show, :edit, :update, :destroy]
    before_action :set_user_tags, only: [:update]

    # crud_objecgt()メソッド：application_controller.rb内に定義
    # pass_object_to_crud()メソッド：application_controller.rb内に定義

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
        crud_object(
            object: @user,
            data_type: "user",
            crud_type: "show",
        )
    end

    #Edit
    def edit
        pass_object_to_crud(
            object: @user,
            association_data: @user.user_tags,
            data_type: "user",
            crud_type: "edit"
        )
    end

    #Update
    def update
        pass_object_to_crud(
            object: @user,
            params: update_user_params,
            association_data: @user_tags,
            data_type: "user",
            crud_type: "update"
        )
    end

    #Create
    def create
        crud_object(
            object: User,
            params: user_params,
            data_type: "user",
            crud_type: "create"
        )
    end

    #Destroy NovelSeriesを削除
    def destroy
        pass_object_to_crud(
            object: @user,
            data_type: "user",
            crud_type: "destroy"
        )
    end

    private

        # check_existing?()メソッド：validates_features_concern.rb内に定義

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
            @user = check_existing?(
                object: User,
                params: params[:id],
                data_type: "user")
        end
end
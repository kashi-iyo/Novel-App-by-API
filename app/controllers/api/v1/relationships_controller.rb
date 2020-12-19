class Api::V1::RelationshipsController < ApplicationController

    # logged_in_user()メソッド：authentication_features_concern.rb内に定義

    before_action :logged_in_user, only: [:create, :destroy]
    before_action :set_user, only: [:create]
    before_action :for_users_followings_or_followers, only: [:followings, :followers]
    before_action :set_relationship, only: [:destroy]


    # crud_objecgt()メソッド：application_controller.rb内に定義
    # pass_object_to_crud()メソッド：application_controller.rb内に定義

    def create
        pass_object_to_crud(
            object: current_user.relationships,
            params: relationship_params,
            association_data: @user,
            data_type: "relationship",
            crud_type: "create"
        )
    end

    def destroy
        crud_object(
            object: @relationship,
            data_type: "relationship",
            crud_type: "destroy"
        )
    end

    def followings
        crud_object(
            object: @user2,
            data_type: "followings",
            crud_type: "show"
        )
    end

    def followers
        crud_object(
            object: @user2,
            data_type: "followers",
            crud_type: "show"
        )
    end

    private

    # check_existing?()メソッド：validates_features_concern.rb内に定義

        def relationship_params
            params.require(:relationship).permit(:follow_id)
        end

        def set_user
            @user = check_existing?(
                object: User,
                params: params[:relationship][:follow_id],
                data_type: "user")
        end

        # あるユーザーのフォローユーザー／フォロワーデータを取得するため
        def for_users_followings_or_followers
            @user2 = check_existing?(
                object: User,
                params: params[:id],
                data_type: "user")
        end

        def set_relationship
            @relationship = check_existing?(
                object: current_user.relationships,
                params: params[:id],
                data_type: "relationship")
        end

end
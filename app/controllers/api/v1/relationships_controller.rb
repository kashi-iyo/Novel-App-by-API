class Api::V1::RelationshipsController < ApplicationController

    before_action :set_user, only: [:create]
    before_action :set_relationship, only: [:destroy]

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

    private

    def relationship_params
        params.require(:relationship).permit(:follow_id)
    end

    def set_user
        @user = User.find(params[:relationship][:follow_id])
        check_existing?(@user, "relationship")
    end

    def set_relationship
        @relationship = current_user.relationships.find_by(follow_id: params[:id])
        check_existing?(@relationship, "relationship")
            # → validates_features_concern.rb
    end

end
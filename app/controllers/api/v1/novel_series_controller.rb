class Api::V1::NovelSeriesController < ApplicationController

    before_action :set_novel_series, only: [:show, :edit, :update, :destroy]

    def index
        @all_novel_series = NovelSeries.all
        render json: { status: "ok" , novel_series: @all_novel_series}
    end

    def show
        
    end

    def create
        
    end

    def update
        
    end

    def destroy
        
    end

    private

        def set_novel_series
            @novel_series = NovelSeries.find(params[:id])
        end

end
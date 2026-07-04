# frozen_string_literal: true

module Api
  class PatternsController < ApplicationController
    def index
      render json: Pattern.all
    end

    def create
      new_pattern = Pattern.new(pattern_params)
      if new_pattern.save
        render json: new_pattern, status: :created
      else
        render json: new_pattern.errors, status: :unprocessable_entity
      end
    end

    def update
      if pattern.update(pattern_params)
        render json: pattern, status: :ok
      else
        render json: pattern.errors, status: :unprocessable_entity
      end
    end

    def destroy
      pattern.destroy
      head :no_content
    end

    private

    def pattern
      @pattern ||= Pattern.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def pattern_params
      params.require(:pattern).permit(:match_text, :notes, :category_id, :subcategory_id)
    end
  end
end

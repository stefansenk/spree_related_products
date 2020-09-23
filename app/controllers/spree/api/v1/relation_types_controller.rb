module Spree
  module Api
    module V1
      class RelationTypesController < Spree::Api::BaseController

        def index
          scope = RelationType.accessible_by(current_ability, :read)
          @relation_types = if params[:ids]
             scope.where(id: params[:ids])
           else
             scope.ransack(params[:q]).result.distinct
           end
          respond_with(@relation_types)
        end

        def show
          @relation_type = RelationType.accessible_by(current_ability, :read).find(params[:id])
          respond_with(@relation_type)
        end

        def new; end

        def create
          authorize! :create, RelationType
          @relation_type = RelationType.new(relation_type_params)
          if @relation_type.save
            respond_with(@relation_type, status: 201, default_template: :show)
          else
            invalid_resource!(@relation_type)
          end
        end

        def update
          @relation_type = RelationType.accessible_by(current_ability, :update).find(params[:id])
          if @relation_type.update_attributes(relation_type_params)
            respond_with(@relation_type, default_template: :show)
          else
            invalid_resource!(@relation_type)
          end
        end

        def destroy
          @relation_type = RelationType.accessible_by(current_ability, :destroy).find(params[:id])
          @relation_type.destroy
          respond_with(@relation_type, status: 204)
        end

        private

        def relation_type_params
          params.require(:relation_type).permit(:name, :description, :applies_to)
        end

      end
    end
  end
end

module Spree
  module Api
    module V1
      class RelationsController < Spree::Api::BaseController

        def index
          @relations = if params[:ids]
             scope.relations.accessible_by(current_ability, :read).where(id: params[:ids])
           else
             scope.relations.accessible_by(current_ability, :read).ransack(params[:q]).result.distinct
           end
          respond_with(@relations)
        end

        def show
          @relation = scope.relations.accessible_by(current_ability, :read).find(params[:id])
          respond_with(@relation)
        end

        def new; end

        def create
          authorize! :create, Relation
          @relation = scope.relations.new(relation_params)
          if @relation.save
            respond_with(@relation, status: 201, default_template: :show)
          else
            invalid_resource!(@relation)
          end
        end

        def update
          @relation = scope.relations.accessible_by(current_ability, :update).find(params[:id])
          if @relation.update_attributes(relation_params)
            respond_with(@relation, default_template: :show)
          else
            invalid_resource!(@relation_params)
          end
        end

        def destroy
          @relation = scope.relations.accessible_by(current_ability, :destroy).find(params[:id])
          @relation.destroy
          respond_with(@relation, status: 204)
        end

        private

        def relation_params
          params.require(:relation).permit(:relation_type_id, :related_to_type, :related_to_id, :discount_amount, :position)
        end

        def scope
          if params[:product_id]
            Spree::Product.friendly.find(params[:product_id])
          end
        end

      end
    end
  end
end

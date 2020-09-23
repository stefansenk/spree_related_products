require 'spec_helper'

module Spree
  describe Api::V1::RelationsController do

    render_views

    let!(:relation_type) { create(:relation_type) }
    let!(:product) { create(:product) }
    let!(:attributes) { [:id, :relation_type_id, :related_to_type, :related_to_id, :discount_amount, :position] }

    context "as an admin" do
      let!(:current_api_user) do
        role = create :role, name: 'admin'
        user = create :user, spree_roles: [role]
        allow(Spree.user_class).to receive(:find_by).with(hash_including(:spree_api_key)) { current_api_user }
        user
      end

      it "can learn how to create a new relation" do
        api_get :new, product_id: product.id
        expect(response.status).to eq(200)
        expect(json_response["attributes"]).to eq(attributes.map(&:to_s))
        expect(json_response["required_attributes"]).to eq([:relation_type_id, :related_to_type, :related_to_id].map(&:to_s))
      end

      it "can create a new relation for a product" do
        product2 = create(:product)
        expect do
          api_post :create,
            relation: {
              relation_type_id: relation_type.id,
              related_to_type: 'Spree::Product',
              related_to_id: product2.id,
              discount_amount: 2,
              position: 5,
            },
            product_id: product.id
          expect(response.status).to eq(201)
          attributes.each{|attribute| expect(json_response.keys).to include(attribute.to_s) }
          expect(json_response['relation_type_id']).to eq(relation_type.id)
          expect(json_response['related_to_type']).to eq('Spree::Product')
          expect(json_response['related_to_id']).to eq(product2.id)
          expect(json_response['position']).to eq(5)
        end.to change(Relation, :count).by(1)
      end

      context "working with an existing relation" do
        let!(:product2) { create(:product) }
        let!(:relation) { product.relations.create!(relation_type: relation_type, related_to: product2) }

        it "can get a single product relation" do
          api_get :show, id: relation.id, product_id: product.id
          expect(response.status).to eq(200)
          attributes.each{|attribute| expect(json_response.keys).to include(attribute.to_s) }
        end

        it "can get a single product relation" do
          api_get :show, id: relation.id, product_id: product.id
          expect(response.status).to eq(200)
          attributes.each{|attribute| expect(json_response.keys).to include(attribute.to_s) }
        end

        it "can get a list of product relations" do
          api_get :index, product_id: product.id
          expect(response.status).to eq(200)
          expect(json_response).to have_key("relations")
          attributes.each{|attribute| expect(json_response["relations"].first.keys).to include(attribute.to_s) }
        end

        it "can get a list of product relations" do
          api_get :index, product_id: product.id
          expect(response.status).to eq(200)
          expect(json_response).to have_key("relations")
          attributes.each{|attribute| expect(json_response["relations"].first.keys).to include(attribute.to_s) }
        end

        it "can update relation data" do
          relation.update_attributes(position: 1)
          expect(relation.position).to eq(1)
          api_post :update, relation: { position: 2 }, id: relation.id, product_id: product.id
          expect(response.status).to eq(200)
          attributes.each{|attribute| expect(json_response.keys).to include(attribute.to_s) }
          expect(relation.reload.position).to eq(2)
        end

        it "can't update a relation without relation type and related_to" do
          api_post :update, id: relation.id, product_id: product.id
          expect(response.status).to eq(422)
        end

        it "can delete a relation" do
          api_delete :destroy, id: relation.id, product_id: product.id
          expect(response.status).to eq(204)
          expect { relation.reload }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

    end

    it "without authentication rejects the request" do
      api_get :new, product_id: product.id
      expect(response.status).to eq(401)
    end

  end
end

require 'spec_helper'

module Spree
  describe Api::V1::RelationTypesController do

    render_views

    let!(:relation_type) { create(:relation_type) }
    let!(:attributes) { [:id, :name, :applies_to, :description] }

    context "as an admin" do
      let!(:current_api_user) do
        role = create :role, name: 'admin'
        user = create :user, spree_roles: [role]
        allow(Spree.user_class).to receive(:find_by).with(hash_including(:spree_api_key)) { current_api_user }
        user
      end

      it "can learn how to create a new relation type" do
        api_get :new
        expect(response.status).to eq(200)
        expect(json_response["attributes"]).to eq(attributes.map(&:to_s))
        expect(json_response["required_attributes"]).to eq(["name", "applies_to"])
      end

      it "can create a new relation type" do
        expect do
          api_post :create, relation_type: { name: 'test56757', applies_to: 'Spree::Product'}
          expect(response.status).to eq(201)
          attributes.each{|attribute| expect(json_response.keys).to include(attribute.to_s) }
        end.to change(RelationType, :count).by(1)
      end

      it "can't create a relation type without a name" do
        api_post :create,
                 relation_type: {
                    name: nil,
                    applies_to: 'Spree::Product'
                  }
        expect(response.status).to eq(422)
      end

      it "can delete a relation_type" do
        api_delete :destroy, :id => relation_type.id
        expect(response.status).to eq(204)
        expect { relation_type.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

    end

    it "without authentication rejects the request" do
      api_get :new
      expect(response.status).to eq(401)
    end

  end
end

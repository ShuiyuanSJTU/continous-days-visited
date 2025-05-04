# frozen_string_literal: true

require "rails_helper"

describe ::DiscourseContinousDaysVisited::ContinousDaysVisited do
  describe "stored value" do
    describe "user -> custom_fields -> continous_days_visited" do
      let(:user) { Fabricate(:user) }
      let(:cdv) { described_class.new user }
      before(:example) {}

      it "should be nil at first" do
        expect(user.custom_fields[:continous_days_visited]).to be_nil
      end

      it "test save_continous_days_visited" do
        cdv.save_continous_days_visited(0)
        expect(user.custom_fields[:continous_days_visited]).to eq(0)
        expect(user.reload.custom_fields[:continous_days_visited]).to eq(0)
        cdv.save_continous_days_visited(1)
        expect(user.custom_fields[:continous_days_visited]).to eq(1)
        expect(user.reload.custom_fields[:continous_days_visited]).to eq(1)
        cdv.save_continous_days_visited(100)
        expect(user.custom_fields[:continous_days_visited]).to eq(100)
        expect(user.reload.custom_fields[:continous_days_visited]).to eq(100)
      end

      it "test reset_continous_days_visited" do
        cdv.save_continous_days_visited(100)
        cdv.reset_continous_days_visited
        expect(user.custom_fields[:continous_days_visited]).to eq(0)
      end

      it "test clean_stored_continous_days_visited" do
        cdv.save_continous_days_visited(100)
        cdv.clean_stored_continous_days_visited
        expect(user.custom_fields[:continous_days_visited]).to be_nil
        expect(user.reload.custom_fields[:continous_days_visited]).to be_nil
      end
    end
  end
end

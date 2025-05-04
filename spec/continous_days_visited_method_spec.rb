# frozen_string_literal: true

require "rails_helper"

describe ::DiscourseContinousDaysVisited::ContinousDaysVisited do
  describe "when invoked from UserSummary" do
    let(:user) { Fabricate(:user) }
    let(:cdv) { described_class.new user }

    def create_visit_record(user, visit_array)
      visit_array.each do |visit|
        UserVisit.create(user_id: user.id, visited_at: visit.days.ago.to_date)
      end
    end

    describe "recompute" do
      it "should recompute if custom field is nil" do
        cdv.expects(:recompute_continous_days_visited).once
        cdv.continous_days_visited
      end

      it "should not recompute if custom field is not nil" do
        user.custom_fields[:continous_days_visited] = 100
        user.save_custom_fields
        cdv.expects(:recompute_continous_days_visited).never
        cdv.continous_days_visited
      end
    end

    describe "can get correct value with no custom field" do
      it "should set custom field to 0 from nil if no vistit" do
        expect(user.custom_fields[:continous_days_visited]).to be_nil
        expect(cdv.continous_days_visited).to eq(0)
        expect(user.reload.custom_fields[:continous_days_visited]).to eq(0)
      end

      it "should set custom field to 1 from nil if visited today" do
        create_visit_record(user, [0])
        expect(user.custom_fields[:continous_days_visited]).to be_nil
        expect(cdv.continous_days_visited).to eq(1)
        expect(user.reload.custom_fields[:continous_days_visited]).to eq(1)
      end

      it "should set custom field to 1 from nil if visited yesterday" do
        create_visit_record(user, [1])
        expect(user.custom_fields[:continous_days_visited]).to be_nil
        expect(cdv.continous_days_visited).to eq(1)
        expect(user.reload.custom_fields[:continous_days_visited]).to eq(1)
      end

      it "should return recompute value if custom field is nil and visited yesterday" do
        cdv.stubs(:recompute_continous_days_visited).returns(345)
        expect(user.custom_fields[:continous_days_visited]).to be_nil
        create_visit_record(user, [1])
        expect(cdv.continous_days_visited).to eq(345)
        expect(user.reload.custom_fields[:continous_days_visited]).to eq(345)
      end
    end

    describe "can get correct value with custom field" do
      it "should set custom field to 0 if no visit yesterday" do
        user.custom_fields[:continous_days_visited] = 100
        user.save_custom_fields
        expect(cdv.continous_days_visited).to eq(0)
        expect(user.reload.custom_fields[:continous_days_visited]).to eq(0)
      end

      it "should return custom field if visited yesterday" do
        user.custom_fields[:continous_days_visited] = 100
        user.save_custom_fields
        create_visit_record(user, [1])
        expect(cdv.continous_days_visited).to eq(100)
        expect(user.reload.custom_fields[:continous_days_visited]).to eq(100)
      end
    end
  end
end

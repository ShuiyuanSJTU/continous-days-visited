# frozen_string_literal: true

require "rails_helper"

describe ::DiscourseContinousDaysVisited::ContinousDaysVisited do
  describe "test recompute_continous_days_visited" do
    describe "recompute_continous_days_visited" do
      let(:user) { Fabricate(:user) }
      let(:cdv) { described_class.new user }
      before(:example) {}

      def create_visit_record(user, visit_array)
        visit_array.each do |visit|
          UserVisit.create(user_id: user.id, visited_at: visit.days.ago.to_date)
        end
      end

      it "should be 0 if no visit" do
        expect(cdv.recompute_continous_days_visited).to eq(0)
      end

      it "should be 1 if visited today" do
        create_visit_record(user, [0])
        expect(cdv.recompute_continous_days_visited).to eq(1)
      end

      it "should be 1 if visited yesterday" do
        create_visit_record(user, [1])
        expect(cdv.recompute_continous_days_visited).to eq(1)
      end

      it "should be 2 if visited yesterday and today" do
        create_visit_record(user, [0, 1])
        expect(cdv.recompute_continous_days_visited).to eq(2)
      end

      it "should correctly compute continous visit" do
        create_visit_record(
          user,
          [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20],
        )
        expect(cdv.recompute_continous_days_visited).to eq(21)
      end

      it "should correctly compute continous visit if today not visited" do
        create_visit_record(
          user,
          [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20],
        )
        expect(cdv.recompute_continous_days_visited).to eq(20)
      end

      it "should correctly compute continous visit if yeserday not visited" do
        create_visit_record(
          user,
          [0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20],
        )
        expect(cdv.recompute_continous_days_visited).to eq(1)
      end

      it "should correctly compute continous visit if today and yesterday not visited" do
        create_visit_record(
          user,
          [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20],
        )
        expect(cdv.recompute_continous_days_visited).to eq(0)
      end

      it "should correctly compute if visited every other day" do
        create_visit_record(user, [0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20])
        expect(cdv.recompute_continous_days_visited).to eq(1)
      end

      it "should correctly compute if there is a gap" do
        create_visit_record(
          user,
          [0, 1, 2, 3, 4, 5, 6, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20],
        )
        expect(cdv.recompute_continous_days_visited).to eq(7)
        create_visit_record(user, [7])
        expect(cdv.recompute_continous_days_visited).to eq(21)
      end

      it "should correctly compute if there is a gap and today not visited" do
        create_visit_record(
          user,
          [1, 2, 3, 4, 5, 6, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20],
        )
        expect(cdv.recompute_continous_days_visited).to eq(6)
        create_visit_record(user, [7])
        expect(cdv.recompute_continous_days_visited).to eq(20)
      end

      it "should correctly compute if there is more gaps" do
        create_visit_record(
          user,
          [0, 1, 2, 3, 4, 5, 6, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20],
        )
        expect(cdv.recompute_continous_days_visited).to eq(7)
        create_visit_record(
          user,
          [7, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40],
        )
        expect(cdv.recompute_continous_days_visited).to eq(21)
      end

      it "should correctly compute if there is a long ago visit" do
        create_visit_record(user, [1000])
        expect(cdv.recompute_continous_days_visited).to eq(0)
        create_visit_record(
          user,
          [0, 1, 2, 3, 4, 5, 6, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20],
        )
        expect(cdv.recompute_continous_days_visited).to eq(7)
      end
    end
  end
end

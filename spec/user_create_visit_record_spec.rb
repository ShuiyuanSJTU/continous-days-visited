# frozen_string_literal: true

require "rails_helper"

describe ContinousDaysVisited do
  describe "invoked from create_visit_record" do
    context "shoud correcty handle when created some day" do
      let(:user) { Fabricate(:user) }

      it "should invoke increase_continous_days_visited if created for today" do
        ContinousDaysVisited.expects(:increase_continous_days_visited).once
        ContinousDaysVisited.expects(:clean_stored_continous_days_visited).never
        user.create_visit_record!(Time.new.to_date)
      end

      it "should invoke clean_stored_continous_days_visited if not created for today" do
        ContinousDaysVisited.expects(:increase_continous_days_visited).never
        ContinousDaysVisited.expects(:clean_stored_continous_days_visited).once
        user.create_visit_record!(1.day.ago.to_date)
      end
    end

    context "should get correct value" do
      let(:user) { Fabricate(:user) }
      let(:cdv) { ContinousDaysVisited.new user }
      
      def create_visit_record( user, visit_array )
        visit_array.each do |visit|
          UserVisit.create(user_id: user.id, visited_at: visit.days.ago.to_date)
        end
      end

      before(:example) { 
        create_visit_record(user, [2,3,4,5,6,7,8,9,11,12,13,14,15,16,17,18,19])
      }

      it "not visited yesterday, no stored, guest first" do
        expect(cdv.continous_days_visited).to eq(0)
        user.update_posts_read!(1)
        expect(ContinousDaysVisited.continous_days_visited(
            User.find_by(id:user.id))).to eq(1)
      end

      it "visited yesterday, no stored, guest first" do
        create_visit_record(user, [1])
        expect(cdv.continous_days_visited).to eq(9)
        user.update_posts_read!(1)
        expect(ContinousDaysVisited.continous_days_visited(
            User.find_by(id:user.id))).to eq(10)
      end

      it "not visited yesterday, no stored, self first" do
        user.update_posts_read!(1)
        expect(ContinousDaysVisited.continous_days_visited(
            User.find_by(id:user.id))).to eq(1)
      end

      it "visited yesterday, no stored, self first" do
        create_visit_record(user, [1])
        user.update_posts_read!(1)
        expect(ContinousDaysVisited.continous_days_visited(
            User.find_by(id:user.id))).to eq(10)
      end

      it "not visited yesterday, stored, self first" do
        cdv.recompute_and_store
        user.update_posts_read!(1)
        expect(ContinousDaysVisited.continous_days_visited(
            User.find_by(id:user.id))).to eq(1)
      end

      it "visited yesterday, stored, self first" do
        create_visit_record(user, [1])
        cdv.recompute_and_store
        user.update_posts_read!(1)
        expect(ContinousDaysVisited.continous_days_visited(
            User.find_by(id:user.id))).to eq(10)
      end
    end
  end
end
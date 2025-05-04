# frozen_string_literal: true

require "rails_helper"

describe ContinousDaysVisitedController do
  describe "shoud correcty handle when created some day" do
    let(:user) { Fabricate(:user) }

    it "admin can access" do
      ::DiscourseContinousDaysVisited::ContinousDaysVisited.expects(:continous_days_visited).once
      sign_in(Fabricate(:admin))
      get "/continous_days_visited/#{user.id}.json"
      expect(response.status).to eq(200)
      delete "/continous_days_visited/#{user.id}.json"
      expect(response.status).to eq(200)
    end

    it "staff cannot access" do
      ::DiscourseContinousDaysVisited::ContinousDaysVisited.expects(:continous_days_visited).never
      sign_in(Fabricate(:moderator))
      get "/continous_days_visited/#{user.id}.json"
      expect(response.status).not_to eq(200)
      delete "/continous_days_visited/#{user.id}.json"
      expect(response.status).not_to eq(200)
    end

    it "normal user cannot access" do
      ::DiscourseContinousDaysVisited::ContinousDaysVisited.expects(:continous_days_visited).never
      sign_in(user)
      get "/continous_days_visited/#{user.id}.json"
      expect(response.status).not_to eq(200)
      delete "/continous_days_visited/#{user.id}.json"
      expect(response.status).not_to eq(200)
    end
  end

  describe "can get correct value" do
    let(:user) { Fabricate(:user) }

    def create_visit_record(user, visit_array)
      visit_array.each do |visit|
        UserVisit.create(user_id: user.id, visited_at: visit.days.ago.to_date)
      end
    end

    before(:example) do
      create_visit_record(user, [1, 2, 3, 4, 5, 6, 7, 8, 9, 11, 12, 13, 14, 15, 16, 17, 18, 19])
    end

    it "could get correct value" do
      sign_in(Fabricate(:admin))
      get "/continous_days_visited/#{user.id}.json"
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json["continous_days_visited"]).to eq(9)
      user.update_posts_read!(1)
      get "/continous_days_visited/#{user.id}.json"
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json["continous_days_visited"]).to eq(10)
    end

    it "could deleted stored value" do
      user.custom_fields[:continous_days_visited] = 100
      user.save_custom_fields
      sign_in(Fabricate(:admin))
      get "/continous_days_visited/#{user.id}.json"
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json["continous_days_visited"]).to eq(100)
      delete "/continous_days_visited/#{user.id}.json"
      expect(response.status).to eq(200)
      expect(user.reload.custom_fields[:continous_days_visited]).to be_nil
      get "/continous_days_visited/#{user.id}.json"
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json["continous_days_visited"]).to eq(9)
    end
  end
end

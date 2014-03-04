require 'spec_helper'

describe "Static pages" do

  subject { page }

  describe "Home page" do
    before { visit root_path }

    let(:submit) { 'Apply for beta access' }

    describe "should show beta application field" do
      it { should have_content("List") }
    end

    describe "with invalid information" do
      it "should not create a user" do
        expect { click_button submit }.not_to change(User, :count)
      end
    end

    describe "with valid information" do
      before do
        fill_in "Email",    with: "user@example.com"
      end

      it "should create a beta user" do
        expect { click_button submit }.to change(User, :count).by(1)

        @user = User.find_by(email: 'user@example.com')

        expect(@user.role).to eq("beta")
      end

      describe "should show success after beta application" do
        before { click_button submit }
        let(:user) { User.find_by(email: 'user@example.com') }

        it { should have_selector('div.alert.alert-success', text: 'Thank you for submitting your application! The Showboarder team will contact you soon with more information about the beta!') }
      end
    end
  end
end
require 'spec_helper'
require 'support/feature_helpers'

def create_attachment_activities space, space2, user, user2
  space.update_attributes repository: true
  atts = [
    FactoryGirl.create(:attachment_with_associations, space: space, author: user),
    FactoryGirl.create(:attachment_with_associations, space: space, author: user),
    FactoryGirl.create(:attachment_with_associations, space: space, author: user),  # One which will be destroyed
    FactoryGirl.create(:attachment_with_associations, space: space, author: user2), # one with the disabled user
    FactoryGirl.create(:attachment_with_associations, space: space, author: user2), # one with the disabled and no username in recent activity
    FactoryGirl.create(:attachment_with_associations, space: space2, author: user)  # One in a disabled space
  ]
  atts[2].destroy
  atts[3].author.disable
  RecentActivity.where(trackable_id: atts[4].id).first.update_attributes(parameters: {})
  atts[5].space.disable

  atts
end

feature 'Viewing activities' do

  context 'attachment activities on a user homepage' do
    let(:user) { FactoryGirl.create(:user) }
    let(:user2) { FactoryGirl.create(:user) }
    let(:space) { FactoryGirl.create(:space_with_associations) }
    let(:space2) { FactoryGirl.create(:space_with_associations) }

    before do
      space.add_member!(user)
      space2.add_member!(user)

      login_as(user, :scope => :user)

      @atts = create_attachment_activities space, space2, user, user2

      visit my_activity_path
    end

    context 'inside #users-recent-activity' do
      subject { page.find('#users-recent-activity') }

      it {
        # 5 attachments created + 1 attachment removed
        should have_selector('.single-activity', count: 6)
      }
      it { should have_selector('.attachment', count: 4) }
      it { should have_selector('.removed-object', count: 2) }

      # Valid usernames
      it { should have_content(user.name, count: 4) }
      it { should have_content(user2.name, count: 1) }
      it { should have_content(I18n.t("activities.other.someone_html"), count: 1) }

      it { should have_content(space.name, count: 6) }

      # Valid attachments with names
      it { should have_content(I18n.t('activities.attachment.create_html', name: 'test-attachment.txt')) }
      it { should have_content(I18n.t('activities.attachment.create_html', name: 'test-attachment_1.txt')) }

      # save_page Rails.root.join( 'public', 'capybara.html' )

      # TODO: see #1953
      skip { should have_content(I18n.t('activities.attachment.create_html', name: 'test-attachment_2.txt')) }

      context 'in a database where :filename wasnt stored' do
        before {
          RecentActivity.where(trackable_id: @atts[2].id).first.update_attributes(parameters: {})
          visit my_activity_path
        }
        it { should have_content(I18n.t('activities.attachment.create_html', name: I18n.t('activities.attachment.deleted'))) }
        it { should_not have_content(I18n.t('activities.attachment.create_html', name: 'test-attachment_2.txt')) }
      end

      it { should have_content(I18n.t('activities.attachment.create_html', name: 'test-attachment_3.txt')) }
      it { should have_content(I18n.t('activities.attachment.create_html', name: 'test-attachment_4.txt')) }

      # Link to correct place when user/attachments are present
      it { should have_selector("a[href='#{user_path(user)}']", count: 4) }
      it { should_not have_selector("a[href='#{user_path(user2)}']") }

      it { should have_selector("a[href='#{space_attachment_path(space, @atts[0])}']") }
      it { should have_selector("a[href='#{space_attachment_path(space, @atts[1])}']") }
      it { should_not have_selector("a[href='#{space_attachment_path(space, @atts[2])}']") }
      it { should have_selector("a[href='#{space_attachment_path(space, @atts[3])}']") }
      it { should have_selector("a[href='#{space_attachment_path(space, @atts[4])}']") }
    end
  end

end

require 'rails_helper'

RSpec.describe 'Comments CRUD', type: :feature do
  let!(:user) { create(:user) }
  let!(:article) { create(:article) }
  let!(:comment) { create(:comment, article: article, user: user) }

  before do
    login_as(user, scope: :user)
  end

  it "allows the user to create a new comment" do
    visit article_path(article)
    within(".comment-form.top-level") do
      fill_in 'Body', with: 'Sample comment text body'
      click_button 'Add Comment'
    end

    expect(page).to have_content('Sample comment text body')
    expect(page).to have_content(user.username)
  end

  it 'allows the user to edit a comment' do
    visit edit_article_comment_path(article, comment)

    fill_in 'Body', with: 'Updated comment body'
    click_button 'Update Comment'

    expect(page).to have_content('Comment was successfully updated')
    expect(page).to have_content('Updated comment body')
  end

  it 'does not allow invalid comment update' do
    visit edit_article_comment_path(article, comment)

    fill_in 'Body', with: ''
    click_button 'Update Comment'

    expect(page).to have_content('prohibited this comment from being saved')
  end

  it 'allows the user to delete a comment' do
    visit article_path(article)

    click_button 'Delete'

    expect(page).to have_content('Comment was successfully destroyed')
    expect(page).not_to have_content(comment.body)
  end
end

RSpec.describe "Comment User Authentication Edit/Delete", type: :system do
  let(:owner) { create(:user) }
  let(:other_user) { create(:user) }
  let!(:article) { create(:article, user: owner, title: "Secret Stuff") }
  let!(:comment) { create(:comment, article: article, user: owner, body: "Top secret comment") }

  it "does not allow a different user to see edit/delete for a comment" do
    login_as(other_user, scope: :user)
    visit article_path(article)

    expect(page).not_to have_link("Edit", href: edit_article_comment_path(article, comment))
    expect(page).not_to have_button("Delete")
  end

  it "allows the comment owner to see edit/delete links" do
    login_as(owner, scope: :user)
    visit article_path(article)

    expect(page).to have_link("Edit", href: edit_article_comment_path(article, comment))
    expect(page).to have_button("Delete")
  end

  it "redirects unauthorized user when trying to edit comment directly" do
    login_as(other_user, scope: :user)
    visit edit_article_comment_path(article, comment)

    expect(current_path).to eq(articles_path)
    expect(page).to have_content("You are not authorized")
  end
end

RSpec.describe "Comments", type: :request do
  let!(:user) { create(:user) }
  let!(:article) { create(:article) }

  before do
    login_as(user, scope: :user)
  end
  it "returns unprocessable_entity for invalid comment" do
    post article_comments_path(article), params: { comment: { body: "" } }
    expect(response).to have_http_status(:unprocessable_entity)
  end
end

RSpec.describe 'Comment Replies', type: :feature do
  let!(:user) { create(:user) }
  let!(:article) { create(:article) }
  let!(:parent_comment) { create(:comment, article: article, user: user, body: "Parent comment") }

  before do
    login_as(user, scope: :user)
  end

  it 'allows a user to reply to a comment' do
    visit article_path(article)
    save_and_open_page
    puts page.body
    click_link 'Reply'

    within(".comment-form.reply") do
      fill_in 'Body', with: 'This is a reply'
      click_button 'Add Reply'
    end

    expect(page).to have_content('This is a reply')
    expect(page).to have_content(user.username)
  end
end

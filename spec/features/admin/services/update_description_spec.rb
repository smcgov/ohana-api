require 'rails_helper'

feature 'Update description' do
  background do
    create_service
    login_super_admin
    visit '/admin/locations/vrs-services'
    click_link 'Literacy Program'
  end

  scenario 'with empty description and location kind is human_services' do
    @location.update!(kind: 'human_services')
    fill_in 'service_description', with: ''
    click_button I18n.t('admin.buttons.save_changes')
    expect(page).to have_content "Description can't be blank for Service"
  end

  scenario 'with empty description and location kind is not human_services' do
    fill_in 'service_description', with: ''
    click_button 'Save changes'
    expect(page).to have_content 'successfully updated'
  end

  scenario 'with valid description' do
    fill_in 'service_description', with: 'Youth Counseling'
    click_button I18n.t('admin.buttons.save_changes')
    expect(page).to have_content 'Service was successfully updated.'
    expect(find_field('service_description').value).to eq 'Youth Counseling'
  end
end

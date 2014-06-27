require 'rails_helper'

describe 'GET /organizations/:id' do
  context 'with valid id' do
    before :each do
      @org = create(:location).organization
      get api_endpoint(path: "/organizations/#{@org.id}")
    end

    it 'includes the organization id' do
      expect(json['id']).to eq(@org.id)
    end

    it 'includes the name attribute' do
      expect(json['name']).to eq(@org.name)
    end

    it 'includes the slug attribute' do
      expect(json['slug']).to eq(@org.slug)
    end

    it 'includes the correct url attribute' do
      org_url = json['url']
      get org_url
      json = JSON.parse(response.body)
      expect(json['name']).to eq(@org.name)
    end

    it 'includes the correct locations_url attribute' do
      locations_url = json['locations_url']
      get locations_url
      json = JSON.parse(response.body)
      expect(json.first['organization']['name']).to eq(@org.name)
    end

    it 'is json' do
      expect(response.content_type).to eq('application/json')
    end

    it 'returns a successful status code' do
      expect(response).to have_http_status(200)
    end
  end

  context 'with invalid id' do
    before :each do
      get api_endpoint(path: '/organizations/1')
    end

    it 'returns a status key equal to 404' do
      expect(json['status']).to eq(404)
    end

    it 'returns a helpful message' do
      expect(json['message']).
        to eq('The requested resource could not be found.')
    end

    it 'returns a 404 status code' do
      expect(response).to have_http_status(404)
    end

    it 'is json' do
      expect(response.content_type).to eq('application/json')
    end
  end

  context 'with nil fields' do
    before(:each) do
      @org = create(:organization)
    end

    it 'returns nil fields when visiting one organization' do
      get api_endpoint(path: "/organizations/#{@org.id}")
      expect(json.keys).to include('urls')
    end
  end
end

Rails.application.routes.draw do
  root to: 'application#health'
  scope '/api' do
    scope '/v1' do
      get '/' => 'application#health'
      post '/search' => 'application#search'
    end
  end
end

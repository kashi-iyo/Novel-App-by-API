if Rails.env === 'production'
    Rails.application.config.session_store :cookie_store, key: '_Novel-App-by-API', domain: :all
else
    Rails.application.config.session_store :cookie_store, key: '_novel-app-api'
end
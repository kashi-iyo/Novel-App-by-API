if Rails.env === 'production'
    Rails.application.config.session_store :cookie_store, key: '_novel-app-api', domain: 'http://54.65.39.121', expire_after: 20.years
else
    Rails.application.config.session_store :cookie_store, key: '_novel-app-api'
end
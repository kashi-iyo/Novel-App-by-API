if Rails.env === 'production'
    Rails.application.config.session_store :cookie_store, key: '_novel-app-api', expire_after: 20.years
else
    Rails.application.config.session_store :cookie_store, key: '_novel-app-api'
end
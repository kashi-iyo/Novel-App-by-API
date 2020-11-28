if Rails.env === 'production'
    Rails.application.config.session_store :cookie_store, key: '_Novel-App-by-API', domain: 'http://novel-app-client.s3-website-ap-northeast-1.amazonaws.com'
else
    Rails.application.config.session_store :cookie_store, key: '_novel-app-api'
end
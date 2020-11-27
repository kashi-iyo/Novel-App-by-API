Rails.application.config.middleware.insert_before 0, Rack::Cors do
    allow do
        origins 'http://localhost:3000', 'http://novel-app-client.s3-website-ap-northeast-1.amazonaws.com'

        resource '*',
            headers: :any,
            methods: [:get, :post, :put, :patch, :delete, :options, :head],
            credentials: true
    end
end
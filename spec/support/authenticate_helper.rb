module AuthenticateHelper

    # extend ActiveSupport::Concern

    def is_logged_in?
        !session[:user_id].nil?
    end

    # ログインさせる
    def login!(user)
        session[:user_id] = user.id
    end

    # ログインしているかどうかをbool値で返す
    def logged_in?
        !!session[:user_id]
    end

    # 現在ログインしているユーザーを返す
    def current_user
        @current_user ||= User.find_by(id: session[:user_id]) if logged_in?
    end

    def login
        credentials = {
            nickname: "ログインユーザー",
            email: "authorization@example.com",
            password: "password",
            password_confirmation: "password"}
        @user = FactoryBot.create(:user, credentials)
        post "/login", params: {user: credentials}
    end
end
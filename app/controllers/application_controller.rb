class ApplicationController < ActionController::Base

    skip_before_action :verify_authenticity_token


    # 渡す配列データをtypeに応じた繰り返し処理してくれるメソッド
    include LoopArray
    # デフォルトのモデルデータを適切な形式にしたデータ
    include ReturnDefaultModelDataConcern
    # index / showで取得したいオリジナルのオブジェクトを生成する
    include GenerateOriginalObjectConcern
    # CRUDを実行するメソッド
    include ExecuteCrudMethodConcern
    # CRUD処理後に返すオブジェクト
    include ReturnDoneCrudObjectConcern
    # 認証系の機能
    include AuthenticationFeaturesConcern
    # 認可系の処理を行う
    include ValidatesFeaturesConcern
    # エラーメッセージJSONデータでレンダリング
    include ReturnErrorMessagesConcern
    # index/show/create/edit/udpate/destroy処理後のオブジェクトをJSONとしてレンダリングする
    include RenderJsonCrudObjectConcern


end

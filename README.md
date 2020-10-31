<h2>Client側: https://github.com/kashi-iyo/Novel-App-by-Client</h2>

<h4>Controllersに共通のメソッドを定義: controllers/concern</h4>
        authentication_features_concern.rb: 認可チェックメソッドを定義<br>
        index_and_show_action_concern.rb: 一覧表示・詳細表示したいオブジェクトを取得するメソッドを定義<br>
        create_action_concern.rb: オブジェクトを生成・保存するメソッドを定義<br>
        edit_action_concern.rb: 編集用のオブジェクトを取得するメソッドを定義<br>
        update_action_concern.rb: オブジェクトを更新するメソッドを定義<br>
        destroy_action_concern.rb: オブジェクトを削除するメソッドを定義<br>
        session_concern.rb: 認証系メソッドを定義<br>
        generate_original_object_concern.rb: index/showアクションにて取得したいオリジナルのオブジェクトを構築するメソッドを定義<br>
        loop_array_concern.rb: 様々な配列データをループ処理するメソッドを定義<br>
        validates_features_concern.rb: データが不正でないかどうかをチェックするメソッドを定義<br>
        return_error_messages_concern.rb: エラーメッセージを返すメソッドを定義<br>
        return_various_data_concern.rb: 各モデルのデフォルトのデータを返すメソッドを定義<br>
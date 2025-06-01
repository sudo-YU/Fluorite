モデル
======

.. note::
   このプロジェクトでは、最新のSQLAlchemy構文を採用しています。
   具体的には、レガシーな ``Model.query`` パターンではなく、
   ``session.execute(select(Model))`` パターンを使用しています。

   自動生成されたモデルドキュメントには ``query`` 属性の警告が表示されますが、
   これはSQLAlchemyが自動的に追加する属性に関するものです。
   実際のコードでは新しいスタイルを使用してください。

ユーザーモデル
--------------

.. automodule:: src.models.user
   :members:
   :undoc-members:
   :show-inheritance:

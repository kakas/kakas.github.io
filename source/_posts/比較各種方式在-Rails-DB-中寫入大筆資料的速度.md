title: 比較各種方式在 Rails DB 中寫入大筆資料的速度
author: kakas
tags:
  - DB
  - Rails
  - gem
categories:
  - Rails
date: 2016-10-25 23:25:00
---


這幾天在練習寫爬蟲，一開始我的做法是每爬到一筆資料，就把它存到 DB 裡面，但是若爬了一萬筆資料，就表示你要做一萬次 DB transaction，這些時間累積下來也是很可觀的，因此本篇將來探討不同的多筆資料寫入 DB 的方式，會有什麼樣的差異

<!-- more -->

PS：本文實驗的方式都是從 CSV 讀取資料再存到 DB



## 方法 A：一次寫入一筆資料

```ruby
def perform
  Pokemon.delete_all

  CSV.foreach(csv_path, headers: true) do |row|
    Pokemon.create(
      name:     row["Name"],
      location: row["Location"],
      level:    row["Level"].to_i
    )
  end
end
```

```shell
   (0.1ms)  begin transaction
  SQL (0.3ms)  INSERT INTO "pokemons" ("name", "location", "level", "created_at", "updated_at") VALUES (?, ?, ?, ?, ?)  [["name", "Meowth"], ["location", "Cerulean City"], ["level", 44], ["created_at", 2016-07-22 08:00:54 UTC], ["updated_at", 2016-07-22 08:00:54 UTC]]
   (0.8ms)  commit transaction

   (0.1ms)  begin transaction
  SQL (0.3ms)  INSERT INTO "pokemons" ("name", "location", "level", "created_at", "updated_at") VALUES (?, ?, ?, ?, ?)  [["name", "Bulbasaur"], ["location", "Verdanturf Town"], ["level", 33], ["created_at", 2016-07-22 08:00:54 UTC], ["updated_at", 2016-07-22 08:00:54 UTC]]
   (0.9ms)  commit transaction
...
```

可以很清楚的看出，每次寫入一筆資料就要做一次 transaction



## 方法 B：用 ActiveRecord::Base.transaction 把資料寫入的程式包起來

程式同方法 A，但是用 ActiveRecord::Base.transaction 把它包起來

```ruby
def perform
  Pokemon.delete_all

  ActiveRecord::Base.transaction do
    CSV.foreach(csv_path, headers: true) do |row|
      Pokemon.create(
        name:     row["Name"],
        location: row["Location"],
        level:    row["Level"].to_i
      )
    end
  end
end
```

```shell
   (0.1ms)  begin transaction
  SQL (0.3ms)  INSERT INTO "pokemons" ("name", "location", "level", "created_at", "updated_at") VALUES (?, ?, ?, ?, ?)  [["name", "Meowth"], ["location", "Cerulean City"], ["level", 44], ["created_at", 2016-07-22 08:00:54 UTC], ["updated_at", 2016-07-22 08:00:54 UTC]]

  SQL (0.1ms)  INSERT INTO "pokemons" ("name", "location", "level", "created_at", "updated_at") VALUES (?, ?, ?, ?, ?)  [["name", "Bulbasaur"], ["location", "Verdanturf Town"], ["level", 33], ["created_at", 2016-07-22 08:00:54 UTC], ["updated_at", 2016-07-22 08:00:54 UTC]]
   (0.6ms)  commit transaction
...
```

可以看到與方法 A 不同的方在於，雖然一樣有多筆 INSERT，但只有一次 transaction



## 方法 C：把資料存成 Hash 陣列，再一次寫到 DB 裡

```ruby
def perform
  Pokemon.delete_all

  data_array = CSV.foreach(csv_path, headers: true).map do |row|
    {
      name:     row["Name"],
      location: row["Location"],
      level:    row["Level"].to_i
    }
  end

  Pokemon.create(data_array)
end
```

```shell
   (0.1ms)  begin transaction
  SQL (0.4ms)  INSERT INTO "pokemons" ("name", "location", "level", "created_at", "updated_at") VALUES (?, ?, ?, ?, ?)  [["name", "Meowth"], ["location", "Cerulean City"], ["level", 44], ["created_at", 2016-07-22 08:00:54 UTC], ["updated_at", 2016-07-22 08:00:54 UTC]]
   (1.7ms)  commit transaction

   (0.1ms)  begin transaction
  SQL (0.2ms)  INSERT INTO "pokemons" ("name", "location", "level", "created_at", "updated_at") VALUES (?, ?, ?, ?, ?)  [["name", "Bulbasaur"], ["location", "Verdanturf Town"], ["level", 33], ["created_at", 2016-07-22 08:00:54 UTC], ["updated_at", 2016-07-22 08:00:54 UTC]]
   (0.6ms)  commit transaction
...
```

可以看的出來，居然跟方法 A 一樣，多筆 INSERT 加多個 transaction，還要另外把資料處理成 Hash Array 囧，如果只看程式很容易以為一次會把全部資料 INSERT 進去阿，這個方法也是實測中最慢的。



## 方法 D：利用 gem activerecord-import，把資料包成對應 Model 的 object Array 一次存進去

activerecord-import 這個 gem 就是專門用來處理大筆資料 import 的 gem，其實就是對大筆資料輸入的 ORM 語法做優化，他提供了兩種方式 import（請參閱下方連結），所以在這邊我們也都來試一試

[Github: zdennis/activerecord-import](https://github.com/zdennis/activerecord-import)
[Examples](https://github.com/zdennis/activerecord-import/wiki/Examples)

```ruby
def perform
  Pokemon.delete_all

  data_array = CSV.foreach(csv_path, headers: true).map do |row|
    Pokemon.new(
      name:     row["Name"],
      location: row["Location"],
      level:    row["Level"].to_i
    )
  end

  columns = [:name, :location, :level]
  Pokemon.import columns, data_array, validate: true
end
```

```shell
   (0.1ms)  select sqlite_version(*)
  Class Create Many Without Validations Or Callbacks (1.0ms)  INSERT INTO "pokemons" ("name","location","level","created_at","updated_at") VALUES ('Meowth','Cerulean City',44,'2016-07-22 08:00:54.781875','2016-07-22 08:00:54.782056'),('Bulbasaur','Verdanturf Town',33,'2016-07-22 08:00:54.781875','2016-07-22 08:00:54.782056')
...
```

一個 SQL 指令就把資料存進去了。
另外實測的結果，若資料沒過 validation，資料並不會被存進去，安心使用。
他也提供 `validate` 選項，讓你決定是否要執行 validate



## 方法 E：利用 gem activerecord-import，把 CSV 處理成 Array 一次存進去

利用 CSV.read 就可以把 CSV 處理成 Array（請參閱下方連結）
[Class: CSV (Ruby 2.0.0)](http://ruby-doc.org/stdlib-2.0.0/libdoc/csv/rdoc/CSV.html#method-c-read)

PS：因為我用的 CSV 有包含 header，所以要另外處理掉，避免把 header 也存進資料庫。

```ruby
def perform
  Pokemon.delete_all

  data_array = CSV.read(csv_path)
  data_array.shift # 刪除 CSV 的 header

  columns = [:name, :location, :level]
  Pokemon.import columns, data_array, validate: true
end
```

```shell
  Class Create Many Without Validations Or Callbacks (0.8ms)  INSERT INTO "pokemons" ("name","location","level","created_at","updated_at") VALUES ('Meowth','Cerulean City',44,'2016-07-22 08:00:54.788196','2016-07-22 08:00:54.788283'),('Bulbasaur','Verdanturf Town',33,'2016-07-22 08:00:54.788196','2016-07-22 08:00:54.788283')
...
```

結果跟方法 D 差不多。



## 方法 F：跟方法 E 一樣，但是不做 validate

```ruby
def perform
  Pokemon.delete_all

  data_array = CSV.read(csv_path)
  data_array.shift # 刪除 CSV 的 header

  columns = [:name, :location, :level]
  Pokemon.import columns, data_array, validate: false
end
```

```shell
  Class Create Many Without Validations Or Callbacks (5.3ms)  INSERT INTO "pokemons" ("name","location","level","created_at","updated_at") VALUES ('Meowth','Cerulean City',44,'2016-07-22 08:00:54.795553','2016-07-22 08:00:54.795693'),('Bulbasaur','Verdanturf Town',33,'2016-07-22 08:00:54.795553','2016-07-22 08:00:54.795693')
...
```

看起來跟方法 D 差不多。



## 速度比較

再回顧一下每個方法
方法 A：一次寫入一筆資料
方法 B：用 ActiveRecord::Base.transaction 把資料寫入的程式包起來
方法 C：把資料存成 Hash 陣列，再一次寫到 DB 裡
方法 D：利用 gem activerecord-import，把資料包成對應 Model 的 object Array 一次存進去
方法 E：利用 gem activerecord-import，把 CSV 處理成 Array 一次存進去
方法 F：跟方法 E 一樣，但是不做 validate

以五萬筆資料寫入實驗，下面速度比較結果的單位是秒

```shell
       user     system      total        real
A: 59.070000  16.060000  75.130000 ( 95.070092)
B: 43.950000   6.010000  49.960000 ( 53.466195)
C: 61.740000  18.710000  80.450000 (102.408476)
D: 24.960000   0.380000  25.340000 ( 26.322362)
E: 20.840000   0.230000  21.070000 ( 21.729201)
F:  4.040000   0.090000   4.130000 (  4.339140)
```

小結：如果你已經確保你要 import 的資料都正確無誤，就可以用 F 的方法去做，因為其他方法根本就看不到 F 的車尾燈惹 QQ，另外 D 跟 E 有差了一點點時間，我想那是因為 D 還要額外花一點時間把 CSV 處理成 obj array 吧，所以D 跟 E 其實是差不多的。

程式在這裡：https://github.com/kakas/activerecord_import_example



### 自己玩：
1. clone 下來
2. bundle install
3. rake db:migrate
4. rails console
5. 執行 `DataImportBenchmarkJob.new.perform` 即可



#### 2016/07/23 補充
使用 activerecord_import 並不會執行 callback，所以若是你有 callback 的需求可以參考以下連結

[Callbacks · zdennis/activerecord-import Wiki](https://github.com/zdennis/activerecord-import/wiki/Callbacks)



## 參考資料

1. [zdennis/activerecord-import: Extraction of the ActiveRecord::Base#import functionality from ar-extensions for Rails 3 and beyon](https://github.com/zdennis/activerecord-import)
2. [Examples · zdennis/activerecord-import Wiki](https://github.com/zdennis/activerecord-import/wiki/Examples)
3. [Speeding Up Bulk Imports in Rails - via @codeship | via @codeship](https://blog.codeship.com/speeding-up-bulk-imports-in-rails/)

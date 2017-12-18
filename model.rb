DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/webtoon.db")

  class Webtoon
    include DataMapper::Resource # DataMapper 객체로 Question클래스를 만들겠다.
    property :id, Serial
    property :name, String
    property :desc, String
    property :score, Float
    property :image_url, String
    property :url, String
    property :created_at, DateTime
  end

DataMapper.finalize
Webtoon.auto_upgrade!

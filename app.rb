require 'sinatra'
require 'sinatra/reloader'
require 'httparty'
require 'json'
require 'date'
require 'data_mapper'
require './model.rb' # 데이터베이스 관련 파일 (model)

set :bind, '0.0.0.0'

get '/' do
  erb :index
end

get '/scrap' do
  # 월요일~금요일의 웹툰을 긁어온다.
 days = ["mon", "tue", "wed", "thu", "fri", "sat", "sun"]
 @webtoons = Array.new
 days.each do |day|
   url = "http://webtoon.daum.net/data/pc/webtoon/list_serialized/#{day}"
   response = HTTParty.get(url)
   doc = JSON.parse(response.body)

   doc["data"].each do |webtoon|
     toon = {
       name: webtoon["title"],
       desc: webtoon["introduction"],
       score: webtoon["averageScore"],
       img_url: webtoon["appThumbnailImage"]["url"],
       url: "http://webtoon.daum.net/webtoon/view/#{webtoon['nickname']}"
     }
     @webtoons << toon
   end
 end

  @webtoons.each do |webtoon|
    Webtoon.create{
      name: webtoon[:name],
      desc: webtoon[:desc],
      score: webtoon[:score].to_f,
      img_url: webtoon[:img_url],
      url: webtoon[:url]
    }
  end
end

get '/week/:day' do
  day = params[:day]
  url = "http://webtoon.daum.net/data/pc/webtoon/list_serialized/#{day}"
  response = HTTParty.get(url)
  doc = JSON.parse(response.body)
  # puts doc.class

  @webtoons = Array.new
  doc["data"].each do |webtoon|
    toon = {
      name: webtoon["title"],
      desc: webtoon["introduction"],
      score: webtoon["averageScore"],
      img_url: webtoon["appThumbnailImage"]["url"],
      url: "http://webtoon.daum.net/webtoon/view/#{webtoon['nickname']}"
    }
    @webtoons << toon

end

  erb :day
end
get '/today' do
# 1. url을 만든다. 오늘의 요일, 시간을 알아야 한다.
# Time.now은 현재시간을 알려주는 메소드. 그것을 integer로 변환
# 현재시간을 내가 원하는 형식으로 보내준다.
  time = Time.now.to_i
# 현재시간을 알려주는 메소드 DateTime.now
# Time을 String Foramt으로 보내준다 라는 메소드 strftime
  week =  DateTime.now.strftime("%a").downcase
  url = "http://webtoon.daum.net/data/pc/webtoon/list_serialized/#{week}?timeStamp=#{time}"
  # puts url
# 2. 해당 url에 요청을 보내고 데이터를 받는다.
  response = HTTParty.get(url)
# 3. json으로 날아온 데이터는 바로 사용 불가. hash형식으로 바꿔야 한다.
  doc = JSON.parse(response.body)
  puts doc.class
# 4. Key를 이용해서 원하는 데이터만 수집한다.
# 원하는 데이터 : 제목, 이미지, 웹툰 링크, 소개, 평점
# 평점 averageScore
# 제목 title
# 소개 introduction
# 이미지 appThumbnailImage["url"]
# 링크 "http://webtoon.daum.net/webtoon/view/#{nickname}"
  @webtoons = Array.new
  doc["data"].each do |webtoon|

    toon = {
      name: webtoon["title"],
      desc: webtoon["introduction"],
      score: webtoon["averageScore"],
      img_url: webtoon["appThumbnailImage"]["url"],
      url: "http://webtoon.daum.net/webtoon/view/#{webtoon['nickname']}"
    }
    @webtoons << toon
  end
  puts @webtoons


# 5. view에서 보여주기 위해 @webtoons 라는 변수에 담는다.

  # erb :webtoon_list
end

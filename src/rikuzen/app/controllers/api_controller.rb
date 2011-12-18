require 'net/http'
require 'pp'

class ApiController < ApplicationController
  respond_to :json, :xml

  def initialize
    # 公開レポジトリにcommitするため隠蔽を行う
    # OSの環境変数 YJDN_KEY にあらかじめ YJDN の appkey を設定しておくこと
    # $ export YJDN_KEY='appkeyhogehogehogheoge--'
    # 本番運用時は変更する予定
    @yjdn_key = ENV['YJDN_KEY']
    @response = { :data => '', :status => 200}
  end

  def kiznap_image
    hostname = 'shinsai.yahooapis.jp'
    api_method = '/v1/Archive/search'
    res_data = {}

    query_params = {
      :appid => @yjdn_key,
      :output => 'xml',
      :start  => 1,
      :results  => 1,
      :period => 'after',
    }

    query_string = (query_params||{}).map{|k,v|
          URI.encode(k.to_s) + "=" + URI.encode(v.to_s)
            }.join("&")

    Net::HTTP.start(hostname) do |http|
      p 'Access: ' + hostname + api_method + '?' + query_string
      yjdn_response = http.get(api_method + '?' + query_string)
      yjdn_hash = Hash.from_xml(yjdn_response.body)
      res_data = { 'kiznap_url' =>  yjdn_hash['ArchiveData']['Result']['PhotoData']['OriginalUrl'] }
    end

    @response[:data] = res_data
    pp @response

    respond_with @response
  end
end

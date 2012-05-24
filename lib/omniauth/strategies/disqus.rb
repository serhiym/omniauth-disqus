require 'omniauth-oauth'
require 'multi_json'
require 'httparty'

module OmniAuth
  module Strategies
    class Disqus < OmniAuth::Strategies::OAuth2
      option :name, 'disqus'
      option :client_options, {
        :site => 'https://disqus.com',
        :authorize_url => '/api/oauth/2.0/authorize/',
        :token_url      => '/api/oauth/2.0/access_token/'
        }
      uid { access_token.params['user_id'] }

      info do
        {
          :name => raw_info['name'],
          :nickname => raw_info['username'],
          :urls => { 'profileUrl' => raw_info['profileUrl'] },
          :location => raw_info['location'],
          :image => raw_info['avatar']['small']['permalink'],
        }
      end

      extra do
        { :raw_info => raw_info }
      end
      
      def raw_info
        begin
          res = HTTParty.get("http://disqus.com/api/3.0/users/details.json?api_key=#{access_token.client.id}&user=#{access_token.params['user_id']}")
        rescue => e
          e # what should be done with this?
        end
        res = Hashie::Mash.new(res.to_hash['response'])
        @raw_info ||= res
      end
    end
  end
end
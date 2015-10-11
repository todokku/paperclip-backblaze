require "backblaze/b2/base"
require "backblaze/b2/account"
require "backblaze/b2/bucket"
require "backblaze/b2/file"

module Backblaze::B2
  SUBCLASSES = [Account, Bucket, File].freeze

  class << self
    attr_reader :account_id, :token, :api_url, :download_url

    ##
    # Authenticates with the server to get the authorization data. Raises an error if there is a problem
    #
    # @param [#to_s] account_id the account id
    # @param [#to_s] application_key the private app key
    # @raise [Backblaze::AuthError] when unable to authenticate
    # @return [void]
    def login(account_id:, application_key:)
      options = {
        basic_auth: {username: account_id, password: application_key}
      }
      response = HTTParty.get("https://api.backblaze.com/b2api/v1/b2_authorize_account", options)
      raise Backblaze::AuthError.new(response) unless response.code == 200

      @account_id = response['accountId']
      @token = response['authorizationToken']
      @api_url = response['apiUrl']
      @download_url = response['downloadUrl']

      Backblaze::B2::Base.base_uri @api_url
    end
  end
end
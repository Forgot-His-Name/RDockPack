class RDockPack

  private

  def make_request(url, first = true, io = false)
    uri = URI.parse url
    puts "<< #{uri.to_s}" if @debug_https

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    options = { 'headers' => { 'Content-Type' => 'application/json' } }

    request = Net::HTTP::Get.new(uri.request_uri, options['headers'])

    if @priv_tokens[uri.host]
      puts "  set basic auth header" if @debug_https

      encoded = Base64.strict_encode64(@priv_tokens[uri.host])
      request['Authorization'] = "Basic #{encoded}" #$basic_auth_encoded
    end

    if url.include? 'manifests'
      request['Accept'] = 'application/vnd.docker.distribution.manifest.list.v2+json'
    else
      request['Accept'] = 'application/vnd.docker.distribution.manifest.v2+json'
    end

    if @token
      puts "  set bearer header" if @debug_https
      request['authorization'] = "Bearer #{@token}" if @token
    end

    begin
      http.request(request) do |response|

        if response.is_a? Net::HTTPRedirection
          new_uri = response['location']
          puts "  redirected to #{new_uri}" if @debug_https

          return make_request(new_uri, first, io)
        end

        if response.is_a? Net::HTTPSuccess
          if io
            puts "-- got io, write to it" if @debug_https
            puts "   len is #{response["Content-Length"]}" if @debug_https
            response.read_body do |chunk|
              io.write chunk
            end
            return true
          else
            return response.body
          end
        end

        if response.is_a? Net::HTTPUnauthorized
          hint = response['Www-Authenticate']

          if first && hint
            realm = /realm="(.+?)"/.match(hint)[1]
            service = /service="(.+?)"/.match(hint)[1]
            scope = /scope="(.+?)"/.match(hint)[1]
            get_token realm, service, scope

            return make_request(url, false, io)
          else
            puts "\tauth failed"
            return nil
          end
        end

        if response.is_a? Net::HTTPNotFound
          puts "  not found"

          return nil
        end

        if response.is_a? Net::HTTPForbidden
          puts "  forbidden"

          pp response.body

          return nil
        end

        puts "\tunexpected response code #{response.code}"
        pp response

        response
      end
    rescue OpenSSL::SSL::SSLError
      puts "\topenssl error"
      return nil
    rescue Net::ReadTimeout
      puts "\ttimeout"
      return nil
    rescue Net::OpenTimeout
      puts "\ttimeot"
      return nil
    end

    return nil
  end

  def get_token(realm, service, scope)
    url = "#{realm}?service=#{service}&scope=#{scope}"

    resp = make_request url, false
    raise 'failed request' unless resp

    data = JSON.parse resp
    raise 'failed get token' unless data['token']

    @token = data['token']
  end

end

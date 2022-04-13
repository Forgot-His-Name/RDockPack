class RDockPack

  private

  def fetch_config(reg_name, img_name, digest, image_path)
    fname = 'config.json'
    target_path = "#{image_path}/#{fname}"
    uri = "https://#{reg_name}/v2/#{img_name}/blobs/#{digest}"

    fetch_blob uri, target_path

    fname
  end

  def fetch_layers(reg_name, img_name, layers, image_path)
    fetched_layers = []

    layers.each do |layer|
      case layer['mediaType']
      when 'application/vnd.docker.image.rootfs.diff.tar.gzip'
        digest = layer['digest']

        alg, hash = digest.split(':', 2)

        fname = "#{hash}.tar.gz"
        target_path = "#{image_path}/#{fname}"
        uri = "https://#{reg_name}/v2/#{img_name}/blobs/#{digest}"

        fetch_blob uri, target_path

        fetched_layers << fname
      else
        puts "skip unknown layer media type: #{layer['mediaType']}"
        next
      end
    end

    fetched_layers
  end

  def fetch_json(url)
    resp = make_request url
    return nil unless resp

    data = JSON.parse resp
  end

  def fetch_blob(uri, fname)
    r = nil

    File.open(fname, 'wb') do |f|
      r = make_request(uri, true, f)
    end

    r
  end

end

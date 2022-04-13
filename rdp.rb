class RDockPack

  def run(imglist)
    puts "target platform"
    puts "arch: #{@target_arch}"
    puts "variant: #{@target_variant}" if @target_variant

    imglist.each do |image_uri|
      reg_name, img_name, tag = parse_image_uri image_uri
      raise 'reg_name is nil' unless reg_name
      raise 'img_name is nil' unless img_name

      puts "\ndownloading\t#{image_uri}"
      puts "registry:\t#{reg_name}"
      puts "image:\t\t#{img_name}:#{tag}"

      image_path = "#{@target_path}/#{img_name.gsub('/', '_')}"

      unless File.exists?(image_path)
        system 'mkdir', '-p', image_path
      end

      puts "path:\t\t#{image_path}"

      load_image reg_name, img_name, tag, image_path
    end
  end

  def find_manifest(reg_name, img_name, tag)
    url = "https://#{reg_name}/v2/#{img_name}/manifests/#{tag}"
    manifest = fetch_json url

    if manifest['mediaType'] == @mtype_list
      manifest['manifests'].each do |candidate|
        next unless candidate['platform']['architecture'] == @target_arch
        next unless candidate['platform']['variant'] == @target_variant

        digest = candidate['digest']
        url = "https://#{reg_name}/v2/#{img_name}/manifests/#{digest}"
        manifest = fetch_json url
        break
      end
    end

    unless manifest['mediaType'] == @mtype_mani
      puts "!! unexpected manifest type"
      pp manifest

      return nil
    end

    manifest
  end

  def load_image(reg_name, img_name, tag, image_path)
    @token = nil
    new_manifest = {}
    new_manifest['RepoTags'] = [ "#{img_name}:#{tag}" ]

    manifest = find_manifest reg_name, img_name, tag
    return nil unless manifest

    digest = manifest['config']['digest']
    conf_name = fetch_config(reg_name, img_name, digest, image_path)
    new_manifest['Config'] = conf_name

    layers = manifest['layers']
    new_layers = fetch_layers(reg_name, img_name, layers, image_path)
    new_manifest['Layers'] = new_layers

    #pp [ new_manifest ]

    manifest_path = "#{image_path}/manifest.json"
    File.open(manifest_path, 'wb') do |f|
      data = [ new_manifest ].to_json
      f.write data
    end

  end

end

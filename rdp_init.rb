class RDockPack

  def initialize
    @def_reg = 'registry-1.docker.io'

    @target_arch = 'amd64'
    @target_variant = nil
    @target_path = '/tmp/images'

    @mtype_mani = 'application/vnd.docker.distribution.manifest.v2+json'
    @mtype_list = 'application/vnd.docker.distribution.manifest.list.v2+json'

    @debug_https = false

    load_private_tokens
  end

  def arch=(value)
    @target_arch = value
  end

  def variant=(value)
    @target_variant = value
  end

  def path=(value)
    @target_path = value
  end

  def debug=(value)
    @debug_https=value
  end

  private

  def load_private_tokens
    path = '~/privtokens.yml'
    full_path = File.expand_path path

    begin
      @priv_tokens = YAML.load_file full_path
    rescue
      @priv_tokens = {}
    end
  end

end

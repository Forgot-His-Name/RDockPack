class RDockPack

  private

  def parse_image_uri(image_uri)
    head, tail = image_uri.split('/', 2)

    if tail
      if head.include? '.'
        # registry name must have dots
        # got registry/image
        regname = head
        imgname = tail
      else
        # got repo/image
        regname = @def_reg
        imgname = image_uri
      end
    else
      # got only image name
      regname = @def_reg
      imgname = "library/#{head}"
    end

    if imgname.include? ':'
      imgname, tag = imgname.split(':')
    else
      tag = 'latest'
    end

    [regname, imgname, tag]
  end

end

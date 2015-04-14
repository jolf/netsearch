module ApplicationHelper

  def get_simple_context_text args
    text = args[:document][args[:field]].first
    if text
      text = text[0..255] + '...' unless text.length < 255
    end
    text
  end

  def get_url_link args
    url = args[:document][args[:field]]
    short_url = url
    if short_url.length > 50
      short_url = short_url[0..20] + '...' + short_url[-20..-1]
    end

    link_to short_url, url
  end

  def get_id_show_link args
    id = args[:document][args[:field]]

    # Encodes the id: '/' transformed to '&#47;' -> needed to avoid rails 
    # from expecting a route from the sub-parts of the id 
    # (e.g. id = '20110224111443/jcIZ7TNodzqOtB2rez8/Ug==' will have paths: '20110224111443' -> 'jcIZ7TNodzqOtB2rez8' -> 'Ug=='
    # where it is encoded as: id = '20110224111443&%2347;jcIZ7TNodzqOtB2rez8&%2347;Ug==', which just needs to be decoded when received.
    link_to 'index', catalog_path(id.gsub('/', '&#47;'))
  end

  def get_wayback_link args
    url = get_wayback_url(args[:document])
    link_to url, url, :target => "_blank"
  end

end

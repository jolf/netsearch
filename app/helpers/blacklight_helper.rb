require 'cgi'

module BlacklightHelper
  include Blacklight::BlacklightHelperBehavior

  def application_name
    "NetSearch"
  end

  def link_to_document (doc, field, opts={:label=>nil, :counter => nil})
    url = get_wayback_url(doc)

    title = 'No title found'
    if doc[field] != nil
      title = doc[field]
    elsif doc['url'] != nil
      title = doc['url']
    end
    if title.is_a? Array
      title = title[0]
    end

    link_to title, url , :target => "_blank"
  end

  def get_wayback_url(doc)
    waybackBaseURL = blacklight_config.wayback_url || doc['url']

    # run through all keys in the configured URL and replace them
    # with values from the current document 
    resURL = waybackBaseURL;
    expando = waybackBaseURL.scan(/\{\w+\}/)
    expandoURLEncode = waybackBaseURL.scan(/\[\w+\]/)

    # replace ordinary keys
    expando.each do
        |exp|
        key = exp.gsub(/[{}]/, '')
        value = doc[key]
        resURL = actualURL.gsub('{'+key+'}', value)
    end

    # replace keys that need to be url encoded
    expandoURLEncode.each do
        |exp|
        key = exp.gsub(/[\[\]]/, '')
        value = doc[key]
        value = CGI::escape(value)
        resURL = resURL.gsub('['+key+']', value)
    end
   
    resURL
  end
end

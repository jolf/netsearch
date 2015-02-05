# -*- encoding : utf-8 -*-
#
class CatalogController < ApplicationController  
  include Blacklight::Marc::Catalog

  include Blacklight::Catalog

  configure_blacklight do |config|
    # keys in {} will be substituted by the value from looking up the key in the current document
    # if key is in [] the value will be url encoded before being inserted. Example:
    #  config.wayback_url = 'http://elara.statsbiblioteket.dk/wayback/{wayback_date}/{url}'
    config.wayback_url = WAYBACK_CONFIG['base_url'] #'http://kb-test-way-001.kb.dk:8080/jsp/QueryUI/Redirect.jsp?url=[url]&time=[wayback_date]'

    ## Default parameters to send to solr for all search-like requests. See also SolrHelper#solr_search_params
    config.default_solr_params = { 
      :qt => 'search',
      :rows => 10, 
      :defType => 'edismax',
      
#      :hl => true,
#      :'hl.field' => 'content_text'

      ## grouping should work but if group.format is 'simple' then blacklight crashes due to problems finding facets ('')
      ## and if group.format is unspecified then the facets are okay but blacklight fails to show the results.
      ## group.ngroups has a potential performance problem with large result sets as it has to counts all groups.
      ## the correct solution would probably be to modify the pager and other items when grouping is enabled so as
      ## not to need/display the count.
      #:group => true,
      #:'group.field' => 'url',
      #:'group.ngroups' => true,
      #:'group.limit' => 2,
      #:'group.format' => 'simple'
    }
    
    # solr path which will be added to solr base url before the other solr params.
    # config.solr_path = 'edismax' 
    
    # items to show per page, each number in the array represent another option to choose from.
    config.per_page = [10,20,50,100]

    # solr field configuration for search results/index views
    config.index.title_field = 'title'
    config.index.domain_field = 'domain'

    # solr field configuration for document/show views
    config.show.title_field = 'title'
    config.show.domain_field = 'domain'

    # solr fields that will be treated as facets by the blacklight application
    # The ordering of the field names is the order of the display
    #config.add_facet_field 'crawl_year', :label => 'Crawl Year', :range => true, :single => true, sort: 'index', solr_params: { 'facet.mincount' => 1 }
    config.add_facet_field 'crawl_year', :label => 'Crawl Year', :single => true, sort: 'index', solr_params: { 'facet.mincount' => 1 }
    config.add_facet_field 'domain', :label => 'Domain', :single => true, :limit => 10, solr_params: { 'facet.mincount' => 1 } 
    config.add_facet_field 'content_type_norm', :label => 'Content Type', :single => true, :limit => 10, solr_params: { 'facet.mincount' => 1 } 
#    config.add_facet_field 'content_type', :label => 'Mimetype', :single => true, :limit => 10, solr_params: { 'facet.mincount' => 1 } 
#    config.add_facet_field 'host', :label => 'Host', :limit => 10, :single => true, solr_params: { 'facet.mincount' => 1 }
    config.add_facet_field 'public_suffix', :label => 'Public Suffix', :single => true, :limit => 10, solr_params: { 'facet.mincount' => 1 }
#    config.add_facet_field 'url', :label => 'URL', :single => true, :limit => 10, solr_params: { 'facet.mincount' => 1 }

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    # The ordering of the field names is the order of the display 
    config.add_index_field 'id', :label => 'Complete index', :helper_method => :get_id_show_link
    config.add_index_field 'content_type', :label => 'MimeType'
    config.add_index_field 'content_type_full', :label => 'Full Content Type'
    config.add_index_field 'crawl_date', :label => 'Crawl Date'
    config.add_index_field 'content_text', :label => 'Content', :helper_method => :get_simple_context_text
    config.add_index_field 'domain', :label => 'Domain'
    config.add_index_field 'url', :label => 'Harvested URL', :helper_method => :get_url_link

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display 
    config.add_show_field 'crawl_year', :label => 'Wayback URL', :helper_method => :get_wayback_link
    config.add_show_field 'title', :label => 'Title'
    config.add_show_field 'crawl_date', :label => 'Crawl Date'
    config.add_show_field 'url', :label => 'Harvested URL'

    # "fielded" search configuration. Used by pulldown among other places.
    config.add_search_field 'all_fields', :label => 'All Fields' do |field|
      field.solr_local_parameters = { 
        :qf => 'title^100 content_text^10 url^3 text',
        :pf => 'title^100 content_text^10 url^3 text'
      }
    end
    
    config.add_search_field('text', :label => 'Text') do |field|
      field.solr_parameters = { :'spellcheck.dictionary' => 'text' }
      field.solr_local_parameters = { 
        :qf => 'title^5 content_text',
        :pf => 'title^5 content_text'
      }
    end

    config.add_search_field('url', :label => 'URL/domain') do |field|
      field.solr_parameters = { :'spellcheck.dictionary' => 'url' }
      field.solr_local_parameters = { 
        :qf => 'url^2 domain',
        :pf => 'url^2 domain'
      }
    end

    config.add_search_field('links', :label => 'Links') do |field|
      field.solr_parameters = { :'spellcheck.dictionary' => 'links' }
      field.solr_local_parameters = { 
        :qf => 'links_hosts links_domains',
        :pf => 'links_hosts links_domains'
      }
    end

    # Now we see how to over-ride Solr request handler defaults, in this
    # case for a BL "search field", which is really a dismax aggregate
    # of Solr search fields. 
    
    #config.add_search_field('title') do |field|
    #  # solr_parameters hash are sent to Solr as ordinary url query params. 
    #  field.solr_parameters = { :'spellcheck.dictionary' => 'title' }

    #  # :solr_local_parameters will be sent using Solr LocalParams
    #  # syntax, as eg {! qf=$title_qf }. This is neccesary to use
    #  # Solr parameter de-referencing like $title_qf.
    #  # See: http://wiki.apache.org/solr/LocalParams
    #  field.solr_local_parameters = { 
    #    :qf => '$title_qf',
    #    :pf => '$title_pf'
    #  }
    #end
    
    #config.add_search_field('author') do |field|
    #  field.solr_parameters = { :'spellcheck.dictionary' => 'author' }
    #  field.solr_local_parameters = { 
    #    :qf => '$author_qf',
    #    :pf => '$author_pf'
    #  }
    #end

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    config.add_sort_field 'score desc', :label => 'relevance'
    config.add_sort_field 'crawl_date desc', :label => 'crawl date (decending)'
    config.add_sort_field 'crawl_date asc', :label => 'crawl date (ascending)'
    config.add_sort_field 'url desc, crawl_date desc', :label => 'URL (decending)'
    config.add_sort_field 'url asc, crawl_date desc', :label => 'URL (ascending)'
    config.add_sort_field 'content_type_norm asc', :label => 'content type (a-z)'
    config.add_sort_field 'content_type_norm desc', :label => 'content type (z-a)'
  end

  # get single document from the solr index
  def show
    # Decodes the id: '/' transformed from '&#47;'
    id = params[:id].gsub('&#47;', '/')
    @response, @document = get_solr_response_for_doc_id id, {:q => "id:#{id}"}
    respond_to do |format|
      format.html {setup_next_and_previous_documents}
      format.json { render json: {response: {document: @document}}}
      # Add all dynamically added (such as by document extensions)
      # export formats.
      @document.export_formats.each_key do | format_name |
        # It's important that the argument to send be a symbol;
        # if it's a string, it makes Rails unhappy for unclear reasons.
        format.send(format_name.to_sym) { render :text => @document.export_as(format_name), :layout => false }
      end
    end
  end
end 

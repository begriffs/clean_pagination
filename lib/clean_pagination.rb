module CleanPagination

  def paginate total_items, max_range_size
    headers['Accept-Ranges'] = 'items'
    headers['Range-Unit'] = 'items'

    requested_from, requested_to = 0, total_items - 1

    if request.headers['Range-Unit'] == 'items' &&
       request.headers['Range'].present?
      if request.headers['Range'] =~ /(\d+)-(\d+)/
        requested_from, requested_to = $1.to_i, $2.to_i
      end
    end

    if requested_from >= requested_to
      response.status = 416
      headers['Content-Range'] = "*/#{total_items}"
      return
    end

    available_to = [requested_to,
                    total_items - 1,
                    requested_from + max_range_size - 1
                   ].min
    headers['Content-Range'] = "#{
        requested_from
      }-#{
        available_to
      }/#{
        total_items < Float::INFINITY ? total_items : '*'
      }"

    available_limit = available_to - requested_from + 1
    yield available_limit, requested_from
    if available_limit < total_items && response.status == 200
      response.status = 206
    end

    requested_limit = requested_to - requested_from + 1

    links = []
    links << "<#{request.path}>; rel=\"first\"; items=\"0-#{requested_limit-1}\""
    links << "<#{request.path}>; rel=\"last\"; items=\"#{
      # let rounding do the work
      ((total_items-1) / available_limit) * available_limit
    }-#{
      (((total_items-1) / available_limit) * available_limit) + requested_limit - 1
    }\""
    if available_to < total_items - 1
      links << "<#{request.path}>; rel=\"next\"; items=\"#{
          available_to + 1
        }-#{
          available_to + requested_limit
        }\""
    end
    if requested_from > 0
      previous_from = [0, requested_from - [requested_limit, max_range_size].min].max
      links << "<#{request.path}>; rel=\"prev\"; items=\"#{
          previous_from
        }-#{
          previous_from + requested_limit - 1
        }\""
    end

    headers['Link'] = links.join ', '
  end

end

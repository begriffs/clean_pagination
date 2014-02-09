module CleanPagination
  def paginate total_items, max_range_size
    headers['Accept-Ranges'] = 'items'
    headers['Range-Unit'] = 'items'

    from  = 0
    to    = total_items - 1
    limit = to - from + 1


    if request.headers['Range-Unit'] == 'items' &&
       request.headers['Range'].present?
      if request.headers['Range'] =~ /(\d+)-(\d+)/
        from, to = $1.to_i, $2.to_i
      end
    elsif limit > max_range_size
      response.status = 413
      headers['Content-Range'] = "*/#{total_items}"
      return
    end

    to     = [total_items - 1, to].min
    limit  = [to - from + 1, max_range_size].min
    offset = from

    if from >= to
      response.status = 416
      headers['Content-Range'] = "*/#{total_items}"
      return
    end

    display_total =
      total_items < Float::INFINITY ? total_items : '*'
    headers['Content-Range'] =
      "#{from}-#{from+limit-1}/#{display_total}"

    yield limit, offset
    response.status = 206 if limit < total_items && response.status == 200

    links = []
    links << "<#{request.path}>; rel=\"first\"; items=\"0-#{limit-1}\""
    links << "<#{request.path}>; rel=\"last\"; items=\"#{
      ((total_items-1) / limit) * limit  # let rounding do the work
    }-#{
      (((total_items-1) / limit) * limit) + limit - 1
    }\""
    links << "<#{request.path}>; rel=\"next\"; items=\"#{to + 1}-#{to + limit}\""
    links << "<#{request.path}>; rel=\"prev\"; items=\"#{[0, from - limit].max}-#{[from - 1, limit-1].max}\""

    headers['Link'] = links.join ', '

  end
end

module CleanPagination
  def paginate total_items, max_range_size
    headers['Accept-Ranges'] = 'items'

    from = 0
    to   = total_items - 1

    if request.headers['Range-Unit'] == 'items' &&
       request.headers['Range'].present?
      if request.headers['Range'] =~ /(\d+)-(\d+)/
        from, to = $1.to_i, $2.to_i
      end
    end

    to     = [total_items - 1, to].min
    limit  = to - from + 1
    offset = from

    if from >= to
      response.status = 416
      headers['Content-Range'] = "*/#{total_items}"
      return
    end

    if limit <= max_range_size
      display_total = if total_items < Float::INFINITY
                        total_items
                      else
                        '*'
                      end
      headers['Range-Unit'] = 'items'
      headers['Content-Range'] =
        "#{from}-#{to}/#{display_total}"

      yield limit, offset
      response.status = 206 if limit < total_items && response.status == 200

      links = []
      links << "<#{request.path}>; rel=\"first\"; items=\"0-#{limit-1}\""
      links << "<#{request.path}>; rel=\"last\"; items=\"#{[to + 1, total_items - limit].max}-#{total_items - 1}\""
      links << "<#{request.path}>; rel=\"next\"; items=\"#{to + 1}-#{[total_items - 1, to + limit].min}\""
      links << "<#{request.path}>; rel=\"prev\"; items=\"#{[0, from - limit].max}-#{[from - 1, limit-1].max}\""

      headers['Link'] = links.join ', '
    else
      response.status = 413
      headers['Content-Range'] = "*/#{total_items}"
    end

  end
end

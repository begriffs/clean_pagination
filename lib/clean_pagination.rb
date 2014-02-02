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

    limit  = to - from + 1
    offset = from

    if limit > max_range_size
      response.status = 416
      return
    end

    yield limit, offset

    if limit < total_items
      headers['Range-Unit'] = 'items'
      headers['Content-Range'] = "#{from}-#{to}/#{total_items}"
      response.status = 206 if response.status == 200
    end
  end
end

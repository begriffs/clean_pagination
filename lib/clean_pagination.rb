module CleanPagination
  def paginate total_items, max_range_size
    if request.headers['Range-Unit'] == 'items'
      range = request.headers['Range']

      headers['Range-Unit'] = 'items'
      headers['Content-Range'] = "#{range}/#{total_items}"
      response.status = 206
    else
      response.status = 200
    end

    yield 0, 0
  end
end

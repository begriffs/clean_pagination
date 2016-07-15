module CleanPagination
  class << self
    DEFAULT_CONFIG = OpenStruct.new({
      allow_render: true,
      raise_errors: false
    })

    def setup
      yield config
    end

    def config
      @__config__ ||= DEFAULT_CONFIG.dup
    end
  end

  def paginate total_items, max_range_size, options = {}
    options = CleanPagination::config.to_h.merge(options)

    headers['Accept-Ranges'] = 'items'
    headers['Range-Unit'] = 'items'

    requested_from, requested_to = 0, [0, total_items - 1].max

    if request.headers['Range-Unit'] == 'items' &&
       request.headers['Range'].present?
      if request.headers['Range'] =~ /(\d+)-(\d*)/
        requested_from, requested_to = $1.to_i, ($2.present? ? $2.to_i : Float::INFINITY)
      end
    end

    if (requested_from > requested_to) ||
       (requested_from > 0 && requested_from >= total_items)
      response.status = 416
      headers['Content-Range'] = "*/#{total_items}"
      message = 'invalid pagination range'
      raise RangeError, message if options[:raise_errors]
      render text: message if options[:allow_render]
      return
    end

    available_to = [requested_to,
                    total_items - 1,
                    requested_from + max_range_size - 1
                   ].min
    available_limit = available_to - requested_from + 1

    if available_limit == 0
      headers['Content-Range'] = "*/0"
    else
      headers['Content-Range'] = "#{
          requested_from
        }-#{
          available_to
        }/#{
          total_items < Float::INFINITY ? total_items : '*'
        }"
    end

    yield available_limit, requested_from
    if available_limit < total_items && response.status == 200
      response.status = 206
    end

    requested_limit = requested_to - requested_from + 1

    links = []
    if available_to < total_items - 1
      links << "<#{request.url}>; rel=\"next\"; items=\"#{
          available_to + 1
        }-#{
          suppress_infinity(available_to + requested_limit)
        }\""

      if total_items < Float::INFINITY
        links << "<#{request.url}>; rel=\"last\"; items=\"#{
          # let rounding do the work
          ((total_items-1) / available_limit) * available_limit
        }-#{
          (((total_items-1) / available_limit) * available_limit) + requested_limit - 1
        }\""
      end
    end
    if requested_from > 0
      previous_from = [0, requested_from - [requested_limit, max_range_size].min].max

      links << "<#{request.url}>; rel=\"prev\"; items=\"#{
          previous_from
        }-#{
          suppress_infinity(previous_from + requested_limit - 1)
        }\""

      links << "<#{request.url}>; rel=\"first\"; items=\"0-#{suppress_infinity(requested_limit-1)}\""
    end

    headers['Link'] = links.join ', ' unless links.empty?
  end

  private

  def suppress_infinity n
    n < Float::INFINITY ? n : ''
  end

end

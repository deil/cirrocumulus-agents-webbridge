require_relative 'config/webbridge_config'
require_relative 'ontologies/webbridge/api_request'

class CirrocumulusApi
  def initialize(options = {})
    ApiRequest.connect()
    @timeout = options.has_key?(:timeout) ? options[:timeout] : 60
    @parser = Sexpistol.new
  end

  def process(act, ontology, content, receiver = nil)
    request = ApiRequest.new(nil, ontology, act, content)
    ApiRequest.create(request)

    if request.id && request.id > 0
      id = request.id
      resolution = 1 / 10.0
      timeout = @timeout / resolution
      while request.is_finished != 1 && timeout > 0 do
        sleep(resolution)
        timeout -= resolution
        request = ApiRequest.find_by_id(id)
      end
    end

    return request.is_finished != 1 ? nil : request
  end

  def query_free_ram(node = nil)
    result = process('query', 'hypervisor', 'free_memory', node)
    if result
      return @parser.parse_string(result.reply)[0][1]
    end

    nil
  end

end

require_relative '../config/webbridge_config'
require_relative 'webbridge/api_request'
require_relative 'webbridge/perform_request_saga'

class WebBridgeOntology < Ontology

  ontology 'webbridge'

  def restore_state
    ApiRequest.connect()
  end

  def tick
    requests = ApiRequest.list_new_requests()
    logger.info "got %d new requests" % requests.size
    requests.each do |request|
      create_saga(PerformRequestSaga).start(request)
    end
  end

  def handle_message(message, kb)
    if message && message.in_reply_to
      request_id = message.in_reply_to.gsub('api-request-', '').to_i
      request = ApiRequest.find_by_id(request_id)

      if request
        request.reply = Sexpistol.new.to_sexp(message.content)
        request.reply_action = message.act
        request.reply_agent = message.sender
        request.updated_at = Time.now
        logger.info "request %d completed" % request.id
        ApiRequest.mark_request_complete(request)
      end
    end
  end

  private

  def logger
    Log4r::Logger['ontology::bridge']
  end

end

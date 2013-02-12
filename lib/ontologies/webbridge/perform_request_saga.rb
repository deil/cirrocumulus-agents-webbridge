class PerformRequestSaga < Saga
  def start(api_request)
    @request = api_request

    send_request()
  end

  def handle_reply(sender, contents, options = {})
    @request.reply_agent = sender.to_s
    @request.reply_action = options[:action].to_s if options[:action]
    @request.reply = Sexpistol.new.to_sexp(contents)
    ApiRequest.mark_request_complete(@request)
    finish()
  end

  private

  def send_request
    logger.info "sending request #{@request.inspect}"
    @ontology.query(Agent.all, Sexpistol.new.parse_string(@request.content), {:ontology => @request.ontology, :conversation_id => self.id})
    ApiRequest.mark_request_sent(@request)
  end

  def logger
    Log4r::Logger['ontology::bridge']
  end

end

require 'rubygems'
require 'awesome_print'

require File.join(AGENT_ROOT, 'config/webbridge_config.rb')
require File.join(AGENT_ROOT, 'ontologies/webbridge/api_request.rb')

class WebbridgeOntology < Ontology::Base
  def initialize(agent)
    super('cirrocumulus-webbridge', agent)
  end
  
  def restore_state()
    ApiRequest.connect()
  end

  def tick()
    requests = ApiRequest.list_new_requests()
    requests.each do |request|
      msg = Cirrocumulus::Message.new(nil, request.action, request.content)
      msg.ontology = request.ontology
      msg.reply_with = "api-request-" + request.id.to_s
      self.agent.send_message(msg)
      ApiRequest.mark_request_sent(request)
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

end

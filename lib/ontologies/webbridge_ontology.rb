require 'rubygems'
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
      msg.ontology = "zalupa" #request.ontology
      msg.reply_with = "api-request-" + request.id.to_s
      self.agent.send_message(msg)
      ApiRequest.mark_request_sent(request)
    end
  end

  def handle_message(message, kb)
  end

  private

end

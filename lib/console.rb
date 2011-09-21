require 'rubygems'
require 'bundler/setup'

require 'lib/config/webbridge_config.rb'
require 'lib/ontologies/webbridge/api_request.rb'

require 'cirrocumulus'
require 'cirrocumulus/engine'
require 'awesome_print'

def greeting()
  print("cirrocumulus> ")
end

def parse_input(str)
  if str =~ /^(([\w\-])+: )*([\w\-]+)\.(request|query\-if|query\-ref) (.+)$/
    msg = Cirrocumulus::Message.new($2, $4, $5)
    msg.ontology = $3
    #ap msg
    return msg
  else
    nil
  end
end

max_timeout = 30
greeting()
ApiRequest.connect()

while not (str = gets()) =~ /^exit/ do
  msg = parse_input(str)
  if msg.nil?
    puts "=> nil"
  else
    #puts "=> %s" % p(msg)
    r = ApiRequest.new(nil, msg.ontology, msg.act, "(" + msg.content + ")")
    ApiRequest.create(r)
    STDOUT.print "%d =>" % [r.id]
    STDOUT.flush()
    idx = max_timeout
    while idx > 0 do
      req = ApiRequest.find_by_id(r.id)
      if req.is_finished == 1
        print " %s: %s\n" % [req.reply_agent, req.reply]
        break
      else
        idx -= 1
        STDOUT.putc "." if idx % 10 == 0
        STDOUT.flush()
        sleep 1
      end
    end
    
    if idx == 0
      print " request timed out :-(\n"
    end
  end
  
  greeting()
end

ApiRequest.disconnect()

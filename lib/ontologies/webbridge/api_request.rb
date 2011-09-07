require 'mysql2'

class ApiRequest
  attr_reader :id
  attr_reader :ontology
  attr_reader :action
  attr_reader :content
  attr_accessor :reply_agent
  attr_accessor :reply_action
  attr_accessor :reply
  attr_accessor :updated_at

  def initialize(id, ontology, action, content)
    @id = id
    @ontology = ontology
    @action = action
    @content = content
  end

  def self.connect()
    @@client = Mysql2::Client.new(:host => DBSERVER, :username => DBUSER,
                                 :password => DBPASSWORD, :database => DBNAME)
    !!@@client
  end

  def self.list_new_requests()
    results = []
    @@client.query("select id, action, content, ontology from #{DBTABLE} where is_sent = 0 and is_finished = 0").each do |row|
      results << ApiRequest.new(row['id'], row['ontology'], row['action'], row['content'])
    end

    results
  end

  def self.find_by_id(id)
    row = @@client.query("select id, action, content, ontology from #{DBTABLE} where id = " + id.to_s).first
    if row
      return ApiRequest.new(row['id'], row['ontology'], row['action'], row['content'])
    end

    nil
  end


  def self.disconnect()
    @@client.close()
  end

  def self.mark_request_sent(request)
    @@client.query("update #{DBTABLE} set is_sent = 1 where id = " + request.id.to_s)
    true
  end

  def self.mark_request_complete(request)
    @@client.query("update #{DBTABLE} set is_finished = 1, is_sent = 1, reply = '%s', reply_agent = '%s', reply_action = '%s', updated_at = '%s' where id = %d"  % [
        request.reply ? @@client.escape(request.reply) : '',
        request.reply_agent ? @@client.escape(request.reply_agent) : '',
        request.reply_action ? @@client.escape(request.reply_action) : '',
        (request.updated_at || DateTime.now).strftime("%Y-%m-%d %H:%M:%S"),
        request.id
    ])

    true
  end
end

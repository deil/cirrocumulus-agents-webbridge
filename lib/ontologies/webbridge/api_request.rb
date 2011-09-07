require 'mysql2'

class ApiRequest
  attr_reader :id
  attr_reader :ontology
  attr_reader :action
  attr_reader :content

  def initialize(id, ontology, action, content)
    @id = id
    @ontology = ontology
    @action = action
    @content = content
  end

  def self.connect()
    @@client = Mysql2::Client.new(:host => DBSERVER, :username => DBUSER,
                                 :password => DBPASSWORD, :database => DBNAME)
  end

  def self.list_new_requests()
    results = []
    @@client.query('select id, action, content, ontology from api_requests where is_sent = 1').each do |row|
      results << ApiRequest.new(row['id'], row['ontology'], row['action'], row['content'])
    end

    results
  end

  def self.disconnect()
    @@client.close()
  end

  def self.mark_request_sent(request)
    @@client.query('update api_requests set is_sent = 1 where id = ' + request.id.to_s)
  end

  def self.mark_request_complete(request)
    @@client.query('update api_requests set is_finished = 1 where id = ' + request.id.to_s)
  end
end

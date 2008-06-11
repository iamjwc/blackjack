class EventHandler
  def initialize
    @handlers = {}
  end

  # Adds an event handler to the handlers hash.
  def add( event_id, &block )
    @handlers[event_id] = block
  end

  # Invokes a specified event handler with the appropriate arguments if
  # an event handler exists for the event. If a block is passed to this,
  # handle is called for 'pre_'+event_id and 'post_'+event_id.
  def handle( event_id, *args )
    unless block_given?
      @handlers[event_id].call(*args) unless @handlers[event_id].nil?
    else
      handle( ('pre_'+event_id.to_s).to_sym, *args )
      yield
      handle( ('post_'+event_id.to_s).to_sym, *args )
    end
  end

end

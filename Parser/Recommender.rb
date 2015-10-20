

class Node

  def initialize(name, type)
    @name = name
    @type = type
    @input = Array.new
    @output = Array.new
  end
  attr_reader :name, :type, :input, :output

  def link(input, output)
    @input << input
    @output << output
  end
end

class Edge
attr_reader :name, :input, :output, :input

  def initialize(name)
    @name = name
    @input = []
    @output = []
    @distance = 3
  end


  def link(input,output)
    @input << input
    @output << output
  end
end

def link_nodes_by_edge(node1, edge, node2)
  node1.link(nil, edge)
  edge.link(node1, node2)
  node2.link(edge, nil)
end

alex = Node.new('alex', 'user')
soccer = Node.new('alex', 'item')
likes = Edge.new('likes')
likes.link(alex,soccer)

puts alex.name + " " + alex.type


def get_user_info
  #some sql query here
  #for each result
  #username = Node.new
  #some entity = Node.new
  #some user action = Edge.new
  #newedge.link(username, entity)
end

def traverse_graph
#get starting node
  #find all outputs to edges from start node
  #record distances of edges
  #land on node of different type
  #find all inputs(edges) to this node
  #follow to edge to find input here
  #land on node of starting type but different name
  #find outputs to edges from this node
  #record distance
  #land on node of different type
  #repeat
end

def rank_results

end
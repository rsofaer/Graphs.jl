# Graph attributes for any graph.

typealias AttrDict Dict{Any,Any}
type GraphAttributes{V,E}
    graph_attributes::AttrDict
    vertex_attributes::Dict{V,AttrDict}
    edge_attributes::Dict{E,AttrDict}

    GraphAttributes() = new(AttrDict(), Dict{V,AttrDict}(), Dict{E,AttrDict}())
end


# attribute interface
graph_attributes(attrs::GraphAttributes)     = attrs.graph_attributes

function edge_attributes(e, attrs::GraphAttributes)
	if !has(attrs.edge_attributes, e)
		attrs.edge_attributes[e] = AttrDict()
	end
	attrs.edge_attributes[e]
end

function vertex_attributes(v, attrs::GraphAttributes)
	if !has(attrs.vertex_attributes, v)
		attrs.vertex_attributes[v] = AttrDict()
	end
	attrs.vertex_attributes[v]
end

graph_attributes(g::AbstractGraph)     = graph_attributes(attributes(g))
edge_attributes(e, g::AbstractGraph)   = edge_attributes(e, attributes(g))
vertex_attributes(v, g::AbstractGraph) = vertex_attributes(v, attributes(g))

has_attributes(g::AbstractGraph) = method_exists(attributes, (typeof(g),))
# Functions for representing graphs in GraphViz's dot format
# http://www.graphviz.org/
# http://www.graphviz.org/Documentation/dotguide.pdf
# http://www.graphviz.org/pub/scm/graphviz2/doc/info/lang.html

# Write the dot representation of a graph to a file by name.
function to_dot(graph::AbstractGraph, filename::String)
    open(filename,"w") do f
        to_dot(graph, f)
    end
end

# Get the dot representation of a graph as a string.
function to_dot(graph::AbstractGraph)
    str = IOString()
    to_dot(graph, str)
    takebuf_string(str)
end

# Write the dot representation of a graph to a stream.
function to_dot(graph::AbstractGraph, stream::IO)
    write(stream, "$(graph_type_string(graph)) graphname {\n")

    if has_attributes(graph)
        attrs = attributes(graph)

        # Some graphs may have attributes that apply to the whole graph, like size or a preferred layout engine.
        write(stream, "graph $(to_dot(graph_attributes(attrs)))\n")

        for t in attrs.vertex_attributes
            write(stream, "$(vertex_index(t[1])) $(to_dot(t[2]))\n")
        end

        edge_attr_f = e -> edge_attributes(e,attrs)
    end

    if implements_edge_list(graph)
        for edge in edges(graph)
            write(stream,"$(vertex_index(source(edge))) $(edge_op(graph)) $(vertex_index(target(edge))) $(to_dot(edge_attr_f(edge)))\n")
        end
    elseif implements_vertex_list(graph)
        if implements_incidence_list(graph)
            for vertex in vertices(graph)
                for edge in out_edges(vertex, graph)
                    if is_directed(graph) || vertex_index(target(edge)) > vertex_index(source(edge))
                        write(stream,"$(vertex_index(source(edge))) $(edge_op(graph)) $(vertex_index(target(edge))) $(to_dot(edge_attr_f(edge)))\n")
                    end
                end
            end
        elseif implements_adjacency_list(graph)
            for vertex in vertices(graph)
                for n in out_neighbors(vertex, graph)
                    if is_directed(graph) || vertex_index(n) > vertex_index(vertex)
                        write(stream,"$(vertex_index(vertex)) $(edge_op(graph)) $(vertex_index(n))\n")
                    end
                end
            end
        end
    else
        throw(ArgumentError("More graph Concepts needed: dot serialization requires iteration over edges or iteration over vertices and neighbors."))
    end
    write(stream, "}\n")
    stream
end

function to_dot(attrs::Dict{Any,Any})
    if isempty(attrs)
        ""
    else
        f = (t::Tuple) -> "\"$(t[1])\"=\"$(t[2])\""
        string("[",join(map(f,collect(attrs)),","),"]")
    end
end

function graph_type_string(graph::AbstractGraph)
    is_directed(graph) ? "digraph" : "graph"
end

function edge_op(graph::AbstractGraph)
    is_directed(graph) ? "->" : "--"
end

function plot(g::AbstractGraph)
    stdin, proc = writesto(`neato -Tx11`)
    to_dot(g, stdin)
    close(stdin)
end

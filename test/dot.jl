using Graphs
using Base.Test

function has_match(search_str, big_str)
	search(big_str, search_str) != 0:-1
end

function xor(a, b)
	(a || b) && !(a && b)
end

# Attributes get layed out correctly
let g = simple_inclist(2)
    attrs = attributes(g)
    g_attrs = graph_attributes(attrs)
    @test to_dot(g_attrs) == ""

    v::vertex_type(g) = 1
    v_attrs = vertex_attributes(v, attrs)
    @test to_dot(v_attrs) == ""

    v_attrs["foo"] = "bar"
    @test to_dot(v_attrs) == "[\"foo\"=\"bar\"]"
    @test has_match("1 [\"foo\"=\"bar\"]\n", to_dot(g))

    v_attrs["baz"] = "qux"
    @test contains(["[\"foo\"=\"bar\",\"baz\"=\"qux\"]",
                      "[\"baz\"=\"qux\",\"foo\"=\"bar\"]"], to_dot(v_attrs))
end

let g=simple_graph(0, is_directed=false)
    @test to_dot(g) == "graph graphname {\n}\n"
end

let g=simple_graph(0, is_directed=true)
    @test to_dot(g) == "digraph graphname {\n}\n"
end

let g=simple_adjlist(3)
    add_edge!(g, 1, 2)
    add_edge!(g, 1, 3)
    add_edge!(g, 2, 3)
    add_edge!(g, 3, 2)
    str = to_dot(g)
    @test has_match("1 -> 2", str)
    @test has_match("1 -> 3", str)
    @test has_match("2 -> 3", str)
    @test has_match("3 -> 2", str)
    @test !has_match("--", str)    
end

let g=simple_adjlist(3, is_directed=false)
    add_edge!(g, 1, 2)
    add_edge!(g, 1, 3)
    add_edge!(g, 2, 3)
    str = to_dot(g)
    @test xor(has_match("1 -- 2", str), has_match("2 -- 1", str))
    @test xor(has_match("1 -- 3", str), has_match("3 -- 1", str))
    @test xor(has_match("2 -- 3", str), has_match("3 -- 2", str))
    @test !has_match("->", str)
end

# I don't know a clean way to make this work, as the dot output edge order changes with every run.
#let g=read_edgelist(joinpath("test", "data", "graph1.edgelist"))
#    f = open(joinpath("test","data","graph1.dot"))
#    str = readall(f)
#    close(f)
#    println(str)
#    println(to_dot(g))
#    @test to_dot(g) == str
#end
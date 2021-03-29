######################################################################
# Macros UTs
# -----
# Licensed under MIT License
module TestMacros
using Test
using ExtraFun
import ..Helpers: testmultiply

struct Resource
    open::Mutable{Bool}
end
Resource() = Resource(Mutable(true))
Base.close(res::Resource) = res.open[] = false

function foo(n::Integer)
    @once n > 512 throw("triggered once")
    nothing
end

@testset "ExtraFun Macros" begin
    @testset "@curry" begin
        @test(@curry(42, truncate=true, testmultiply(2.1)) == 88)
    end
    
    @testset "@once" begin
        @test foo(512) === nothing
        @test_throws "triggered once" foo(513)
        @test foo(514) === nothing
    end
    
    @testset "@sym_str" begin
        @test sym"foobar" === :foobar
        @test sym"hello, world!" === Symbol("hello, world!")
    end
    
    @testset "@with" begin
        @test begin
            res = Resource()
            @with res begin end
            !res.open[]
        end
    end
end
end # module TestMacros

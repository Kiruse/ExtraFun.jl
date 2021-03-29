######################################################################
# Macros UTs
# -----
# Licensed under MIT License
module TestMacros
import Helpers: testmultiply

struct Resource
    open::Mutable{Bool}
end
Resource() = Resource(Mutable(true))
Base.close(res::Resource) = res.open[] = false

@testset "ExtraFun Macros" begin
    @testset "@curry" begin
        @test(@curry(42, truncate=true, testmultiply(2.1)) == 88)
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

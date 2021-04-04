######################################################################
# Macros UTs
# -----
# Licensed under MIT License
module TestMacros
using Test
using ExtraFun
import ..Helpers: testmultiply

struct Resource1
    open::Mutable{Bool}
end
Resource1() = Resource1(Mutable(true))
Base.close(res::Resource1) = res.open[] = false

struct Resource2 end
Base.close(::Resource2) = throw("closed")

function foo(n::Integer)
    @once n > 512 throw("triggered once")
    nothing
end

@testset "ExtraFun Macros" begin
    @testset "@await" begin
        let t0 = time()
            @test @await(sleep(0.2), 42) == 42
            @test isapprox(time()-t0, 0.2, atol=0.05)
        end
    end
    
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
            res = Resource1()
            @with res begin end
            !res.open[]
        end
        
        @test_throws "closed" @with Resource2() begin end
        @test_throws "closed" @with res = Resource2() begin end
    end
end
end # module TestMacros

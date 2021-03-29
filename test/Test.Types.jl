######################################################################
# Types UTs
# -----
# Licensed under MIT License
module TestTypes
import ..Helpers: Immutable

@testset "ExtraFun Types" begin
    @testset "Ident" begin
        identtest(::Ident{:foo}) = 42
        identtest(::Ident{:bar}) = 69.69
        identtest(ident::Symbol) = identtest(Ident{ident}())
        
        @test identtest(:foo) == 42
        @test identtest(:bar) == 69.69
    end
    
    @testset "Mutable" begin
        let immutable = Immutable(42, false)
            immutable.mutable[] = 42
            @test immutable.mutable[] == 42
        end
    end
    
    @testset "Dirty" begin
        let dirty = Dirty(42)
            @test !isdirty(dirty)
            dirty[] += 1
            @test isdirty(dirty)
            @test dirty[] == 43
        end
    end
end
end # module TestTypes

######################################################################
# Functionals UTs
# -----
# Licensed under MIT License
module TestFunctionals
using Test
using ExtraFun
import ..Helpers: Immutable

@testset "ExtraFun Functionals" begin
    @testset "indexed" begin
        let ary = [1, 2, 3]
            @test indexed(ary) === ary
        end
        let tpl = (1, 2, 3)
            @test indexed(tpl) === tpl
        end
        let set = Set((1, 2, 3)), idxed = indexed(set)
            @test 1 ∈ idxed && 2 ∈ idxed && 3 ∈ idxed
            @test set !== idxed
        end
    end
    
    @testset "iterable" begin
        @test iterable(42) === 42
        let ary = [1, 2, 3]
            @test iterable(ary) === ary
        end
        let tpl = (1, 2, 3)
            @test iterable(tpl) === tpl
        end
        let set = Set((1, 2, 3))
            @test iterable(set) === set
        end
        let itr = iterable(Ident{42}())
            @test itr isa Tuple
            @test hassignature(iterate, typeof(itr))
        end
    end
    
    @testset "split collections" begin
        @test split(iseven, collect(1:10)) == (collect(2:2:10), collect(1:2:9))
        @test split(iseven, tuple(1:10...)) == (tuple(2:2:10...), tuple(1:2:9...))
    end
    
    @testset "functional Base.insert!" begin
        let ary = [1, 3, 5]
            @test insert!(ary, 2, before=3) == [1, 2, 3, 5]
            @test insert!(ary, 4, after=3) == [1, 2, 3, 4, 5]
        end
        
        let ary = Immutable.([1, 4, 6])
            @test insert!(ary, Immutable(5), before=6, by=(im)->im.mutable[]) == Immutable.([1, 4, 5, 6])
        end
    end
    
    @testset "functionals" begin
        @test !isathing(nothing)
        @test isathing(42)
        
        @test negate(isodd)(42) == iseven(42)
        @test negate(iseven)(42) == isodd(42)
        
        @test truthy(true)
        @test truthy(42)
        @test truthy(69.69)
        @test truthy(1//2)
        @test falsy(false)
        @test falsy(0)
        @test falsy(0.0)
        @test !falsy(-1)
        @test !falsy(1//1)
    end
end
end # module TestFunctionals

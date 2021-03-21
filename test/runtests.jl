######################################################################
# ExtraFun unit tests
# -----
# Licensed under MIT License.
using ExtraFun
using Test

struct Immutable
    mutable::Mutable{Int}
    flag::Bool
end
Immutable(mutable, flag) = Immutable(Mutable(mutable), flag)
Immutable(mutable) = Immutable(mutable, false)
Base.:(==)(lhs::Immutable, rhs::Immutable) = lhs.mutable == rhs.mutable && lhs.flag == rhs.flag

struct Resource
    open::Mutable{Bool}
end
Resource() = Resource(Mutable(true))
Base.close(res::Resource) = res.open[] = false

function testmultiply(base::Integer, factor::Number; truncate::Bool = false)
    if truncate
        floor(base*factor)
    else
        base*factor
    end
end

@testset "ExtraFun Functions" begin
    @testset "curry" begin
        let curried = curry(testmultiply, 42, truncate=true)
            @test curried(2.1) == 88
            @test curried(0.4) == 16
        end
    end
    
    @testset "indexof" begin
        @test indexof([1, 2, 3], 2) == 2
        @test indexof([1, 2, 3], 1, offset=2) === nothing
        @test indexof([1, 2, 3], 1, by=(x)->x-2) == 3
    end
    
    @testset "[xv]flip!" begin
        let mat = [1 2 3; 4 5 6; 7 8 9]
            @test vflip!(mat) == [7 8 9; 4 5 6; 1 2 3]
        end
        
        let mat = [1 2 3; 4 5 6; 7 8 9]
            @test hflip!(mat) == [3 2 1; 6 5 4; 9 8 7]
        end
    end
    
    @testset "isinstanceof" begin
        @test isinstanceof(42, Number)
        @test isinstanceof(42, Integer)
        @test isinstanceof(42, Int)
        @test !isinstanceof(42, Unsigned)
        @test !isinstanceof(42, AbstractFloat)
        @test isinstanceof(Immutable(42, false), Immutable)
    end
end

@testset "ExtraFun Macros" begin
    @testset "@sym_str" begin
        @test sym"foobar" === :foobar
        @test sym"hello, world!" === Symbol("hello, world!")
    end
    
    @testset "@curry" begin
        @test(@curry(42, truncate=true, testmultiply(2.1)) == 88)
    end
    
    @testset "@with" begin
        @test begin
            res = Resource()
            @with res begin end
            !res.open[]
        end
    end
end

@testset "ExtraFun Functions" begin
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

include("./Test.XCopy.jl")

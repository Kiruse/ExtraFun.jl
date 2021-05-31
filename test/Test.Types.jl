######################################################################
# Types UTs
# -----
# Licensed under MIT License
module TestTypes
using Test
using ExtraFun
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
    
    @testset "Optional" begin
        @testset "explicit" begin
            struct WithExplicitOptional{T}
                opt::Optional{:explicit, T}
            end
            WithExplicitOptional{T}() where T = WithExplicitOptional{T}(unknown)
            
            @test WithExplicitOptional{Real}().opt[] === unknown
            @test WithExplicitOptional{Real}(Optional()).opt[] === unknown
            @test WithExplicitOptional{Integer}(24).opt[] == 24
            @test WithExplicitOptional{Integer}(42.).opt[] == 42
            @test WithExplicitOptional{Integer}(Optional(42.)).opt[] == 42
            let obj = WithExplicitOptional{Real}(24)
                obj.opt[] = 69.69
                @test obj.opt[] == 69.69
            end
            let obj = WithExplicitOptional{Integer}()
                obj.opt[] = 420
                @test obj.opt[] == 420
            end
        end
        
        @testset "generic" begin
            struct WithGenericOptional
                opt::Optional{:generic}
            end
            WithGenericOptional() = WithGenericOptional(unknown)
            
            @test WithGenericOptional().opt[] === unknown
            @test WithGenericOptional(24).opt[] == 24
            @test WithGenericOptional(Optional(24)).opt[] == 24
            let obj = WithGenericOptional()
                obj.opt[] = 24
                @test obj.opt[] == 24
            end
        end
        
        @testset "symbolless" begin
            struct WithSymbollessOptional{T}
                opt::Optional{S, T} where S
            end
            WithSymbollessOptional{T}() where T = WithSymbollessOptional{T}(unknown)
            
            @test WithSymbollessOptional{Real}().opt[] === unknown
            @test WithSymbollessOptional{Real}(Optional(42)).opt[] == 42
            @test WithSymbollessOptional{Integer}(Optional(42.)).opt[] == 42
        end
        
        @testset "implicit load" begin
            ExtraFun.load(opt::Optional{:implicit_load}) = opt.value = 42
            let opt = Optional{:implicit_load}()
                @assert isunknown(opt)
                @test opt[] == 42
                @test !isunknown(opt)
            end
        end
        
        @testset "explicit load" begin
            ExtraFun.load(io::IO, opt::Optional{:explicit_load, T}) where T = opt.value = read(io, T)
            let buff = IOBuffer(), opt = Optional{:explicit_load, Int}()
                write(buff, 42)
                seek(buff, 0)
                @test load(buff, opt) == 42
                @test opt[] == 42
            end
            let buff = IOBuffer(), opt = Optional{:explicit_load, Float32}()
                write(buff, 24.f0)
                seek(buff, 0)
                @test load(buff, opt) ≈ 24
                @test opt[] ≈ 24
            end
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

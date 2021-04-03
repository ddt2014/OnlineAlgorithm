using Test

include("src/Base.jl")
include("src/Stats.jl")

x_data_path = "./test/data/x_data.txt"
y_data_path = "./test/data/y_data.txt"

open(x_data_path) do x_stream

    sum = Sum(Float64)
    min = Min(Float64)
    max = Max(Float64)
    mean = Mean(Float64)
    variance = Variance(Float64)
    covariance = Covariance(Float64)
    ci = ConfidenceInterval(Float64, z=1.96)

    for x in eachline(x_stream)
        x = parse(Float64, x)
        min = update!(min, x)
        max = update!(max, x)
        sum = update!(sum, x)
        mean = update!(mean, x)
        variance = update!(variance, x)
        ci = update!(ci, x)

    end

#------------------------------------------------------------#  min
    @testset "Min" begin
        println(min)
        @test value(min) ≈ -4.598116
    end
#------------------------------------------------------------#  max
    @testset "Max" begin
        println(max)
        @test value(max) ≈ 4.637063
    end
#------------------------------------------------------------#  Sum
    @testset "Sum" begin
        println(sum)
        @test value(sum) ≈ -94.27323899999955
    end
#------------------------------------------------------------#  mean
    @testset "Mean" begin
        println(mean)
        @test value(mean) ≈ -9.427323899999954e-05
    end
#------------------------------------------------------------# variance
    @testset "Variance" begin
        println(variance)
        @test value(variance) ≈ 0.9992832212157458
    end
#------------------------------------------------------------# ConfidenceInterval
    @testset "ConfidenceInterval" begin
        println(ci)
        @test value(ci)["lower_bound"] ≈ -0.002054
        @test value(ci)["upper_bound"] ≈ 0.001864
    end

end

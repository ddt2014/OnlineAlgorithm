include("src/Base.jl")
include("src/Stats.jl")

x_data = rand(100)
y_data = rand(100)
#-----------------------------------------------------------------------#  MinMax
# o = fit!(MinMax(Float64), y)
# o = MinMax(Float64)
# fit!(o, y)
#-----------------------------------------------------------------------#  Sum
function foo()
    sum = Sum(Float64)
    min_max = MinMax(Float64)
    mean = Mean(Float64)
    variance = Variance(Float64)
    covariance = Covariance(Float64)
    # ci = ConfidenceInterval(Float64, )
    ci = ConfidenceInterval(Float64, z=1.96)
    for x in x_data
        sum = update!(sum, x)
        min_max = update!(min_max, x)
        mean = update!(mean, x)
        variance = update!(variance, x)
        ci = update!(ci, x)
    end

    for (x, y) in zip(x_data, y_data)
        covariance = update!(covariance, x, y)
    end

    println(sum)
    println(min_max)
    println(mean)
    println(variance)
    println(ci)
    println(covariance)
end

foo()

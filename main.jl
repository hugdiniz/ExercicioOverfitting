
addprocs(5)
@everywhere include("generatorPoints.jl")

@everywhere function polyfit(x, y, n)
  A = [ float(x[i])^p for i = 1:length(x), p = 0:n ]
  A \ y
end

@everywhere function findY(polynomial,x)
  return sum([polynomial[i]*(x^(i-1)) for i = 1:length(polynomial)])
end

@everywhere function execute(numberPointsTrain,noiseLevel,targetComplexity,numberPointsTest = 100)
  legendre = Legendre(targetComplexity,noiseLevel)

  x,y = legendre.generatorPoints(numberPointsTrain)
  x = convert(Array{Float64}, x)
  y = convert(Array{Float64}, y)

  twoPolynomial = polyfit(x,y,2)
  tenPolynomial = polyfit(x,y,10)
  errorFunction  = function(x)
    return findY(tenPolynomial,x) - findY(twoPolynomial,x)
  end

  #legendrePerfect = Legendre(targetComplexity,0)
  #xTests = sort([legendrePerfect.generateXPoint() for i=1:numberPointsTest])
  #yTest = [legendrePerfect.generateYPoint(xTest) for xTest in xTests]
  #yTwo = [findY(twoPolynomial,i) for i in xTests]
  #yTen = [findY(tenPolynomial,i) for i in xTests]
  #eoutTwo = sum((yTest - yTwo).^2)/length(yTest)
  #eoutTen = sum((yTest - yTen).^2)/length(yTest)
  #return eoutTen - eoutTwo
  return quadgk(errorFunction,-1,1)[1]
end

@everywhere function executeAll()

  targetComplexitys = 1:150
  noiseLevels = 0.0:(3/150):3.0
  numberPointsTrains = 1:150
  executeRepetition = 10000
  figure2 = SharedArray(Float64, (length(numberPointsTrains),length(targetComplexitys)))
  x = 1
  @sync @parallel for targetComplexity in targetComplexitys
    y = 1
    for numberPointsTrain in numberPointsTrains
      figure2[y,x] = sum([execute(numberPointsTrain,0.1,targetComplexity) for i=1:executeRepetition])/executeRepetition
      y = y + 1
    end
    x = x + 1
  end
  #figure1 = SharedArray(Float64, (length(numberPointsTrains),length(noiseLevels)))
  #@parallel for noiseLevel in noiseLevels
  #  y = 1
  #  for numberPointsTrain in numberPointsTrains
  #    figure1[y,x] = execute(numberPointsTrain,noiseLevels,20)
  #    y = y + 1
  #  end
  #  x = x + 1
  #end


  println("Waiting ...")
  println("Writing...")
  writecsv("figure2.csv",figure2)
  #writecsv("figure1.csv",figure1)
  return figure2

end



#figure1 = SharedArray(Float64, (length(numberPointsTrains),length(noiseLevels)))
#@parallel for noiseLevel in noiseLevels
#  y = 1
#  for numberPointsTrain in numberPointsTrains
#    figure1[y,x] = execute(numberPointsTrain,noiseLevels,20)
#    y = y + 1
#  end
#  x = x + 1
#end
#sum([execute(15,0.1,20) for i=1:1000])/1000

#@sync print("Writing ...")
#writecsv("figure2.csv",figure2)
#writecsv("figure1.csv",figure1)
#heatmap(numberPointsTrains,targetComplexitys,figure2,aspect_ratio=1)



type Legendre
  coeficienteNormalizados::Array{Float64}
  generatorPoints::Function
  iterativeLegendre::Function
  generateYPoint::Function
  generateXPoint::Function
  qf::Integer
  noiseLevel::Float64

  function Legendre(qf,noiseLevel)
    this = new()
    this.qf = qf
    this.noiseLevel = noiseLevel

    #Normalizacao
    coeficientes = randn(this.qf+1)
    k = 0
    for l = 1:this.qf+1
      k = k + (coeficientes[l]^2) / (2 * l + 1)
    end
    this.coeficienteNormalizados = coeficientes / sqrt(2*k)


    this.iterativeLegendre = function (qf,x)
      if qf==0
          return one(x)
      elseif qf==1
          return(x)
      end
      p = 0
      p0 = one(x)
      p1 = x

      for i = 2:qf
          p = ((2*i - 1) / i ) * x * p1 - ((i-1)/ i) * p0
          p0 = p1
          p1 = p
      end

      return p
    end

    this.generatorPoints =  function (qtd)
      xs = sort([this.generateXPoint() for i=1:qtd])
      ys = [this.generateYPoint(x) for x in xs]
      return xs,ys
    end

    this.generateXPoint = function ()
      return -1 + rand()*(2)
    end

    this.generateYPoint = function (x)
      #println("coeficienteNormalizados: ",this.coeficienteNormalizados)
      #println("iterativeLegendre",[this.iterativeLegendre(this.qf,x) for i in 1:(this.qf+1)])
      f = sum([this.coeficienteNormalizados[i] * this.iterativeLegendre(this.qf,x) for i in 1:(this.qf+1)])
      return f + sqrt(this.noiseLevel) * rand()
    end

    return this
  end
end

function regressionAndErrorCalcLegendreType(numberPointsTrain,legendre,x,y,hipotese)
  e = 0;
  x2 = ones((numberPointsTrain,hipotese+1))
  for l = 1:numberPointsTrain
    for m = 2:hipotese+1
      x2[l,m] = legendre.iterativeLegendre(m-1,x[l])
    end
  end
  w2 = pinv(x2) * y

  a1 = 0
  b1 = 0
  for l = 1:max(hipotese+1,legendre.qf+1)
    if l > legendre.qf+1
      a1 = 0
    else
      a1 = legendre.coeficienteNormalizados[l]
    end

    if l > hipotese+1
      b1 = 0
    else
      b1 = w2[l]
    end
    e = e + ( ( (a1 - b1)^2 ) / (2 * l + 1) )
  end
  return e
end

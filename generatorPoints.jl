using PyCall
@pyimport scipy.special as sp
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

      p0 = one(x)
      p1 = x

      for i = 2:qf
          p2 = ( (2*i - 1) * qf*p1 - (i-1)*p0 ) / i
          p0 = p1
          p1 = p2
      end

      return p1
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
      f = sum([this.coeficienteNormalizados[i] * this.iterativeLegendre(i-1,x) for i in 1:(this.qf+1)])
      return f + sqrt(this.noiseLevel) * rand()
    end

    return this
  end
end
